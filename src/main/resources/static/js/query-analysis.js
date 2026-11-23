// How a search query is read, word by word, for the search box to color, and what each word could
// be swapped for. No DOM here, so Node can test it (src/test/js).
//
// Parses with the JavaScript the build generates from the same grammar as the server
// (src/main/antlr4/me/Battletech.g4), and splits equipment names the way QueryVisitor does: a
// leading tech word ("clan"), then a mount ("turret"), then a fire control ("artemis"), then the
// equipment. Keep the two in step. The word lists come from GET /api/vocabulary (QueryVocabulary on
// the server).
import { CommonTokenStream, ErrorListener, InputStream } from 'antlr4';
import BattletechLexer from './grammar/me/BattletechLexer.js';
import BattletechParser from './grammar/me/BattletechParser.js';

/** Before /api/vocabulary loads: everything still gets a role, nothing has alternatives. */
export const EMPTY_VOCABULARY = Object.freeze({
  weightClasses: [], units: [], comparatorsBefore: [], comparatorsAfter: [], operators: [], withWords: [],
  techs: {}, fireControls: [], families: {}, equipment: {}, omniWords: [], components: {}, fireControlTerms: [],
  turretMounts: [], turretMountTerms: [], unitTechs: {},
});

/**
 * /api/vocabulary with an empty list for anything it lacks: a response cached before a deployment
 * can miss a list this script expects (withWords).
 */
export function withDefaults(loaded) {
  return { ...EMPTY_VOCABULARY, ...loaded };
}

/** Letters and digits only, lowercase: how names are compared ("LRM-20" and "lrm 20" are the same). */
export function key(text) {
  return text.toLowerCase().replace(/[^a-z0-9]/g, '');
}

class RecordingErrorListener extends ErrorListener {
  constructor() {
    super();
    this.errors = [];
  }

  syntaxError(recognizer, offendingSymbol, line, column, msg) {
    this.errors.push({ symbol: offendingSymbol, column, message: msg });
  }
}

/**
 * The query's words with their roles: weight-class, unit, with, comparator, quantity, tech,
 * turret-mount, fire-control, equipment, operator, comma (between weight classes), unknown (a weight
 * class that isn't one), error, or slot (a blank a template left, "<quantity>", with its name in slot).
 * Multi-word phrases ("at least", "ultra light", "lrm 20") are one token. Positions are character
 * offsets into text, stop exclusive.
 *
 * @returns {{tokens: {start: number, stop: number, text: string, role: string}[], error: ?{start: number, stop: number, message: string}}}
 */
export function analyze(text, vocabulary = EMPTY_VOCABULARY) {
  const slots = findSlots(text);
  if (slots.length > 0) {
    return analyzeWithSlots(text, slots, vocabulary);
  }
  const listener = new RecordingErrorListener();
  // UTF-16 code units, not code points: offsets must match slice() and the editor's, even after an emoji
  const lexer = new BattletechLexer(new InputStream(text, false));
  lexer.removeErrorListeners();
  lexer.addErrorListener(listener);
  const parser = new BattletechParser(new CommonTokenStream(lexer));
  parser.removeErrorListeners();
  parser.addErrorListener(listener);
  const tree = parser.query();

  const tokens = [];
  visit(tree, tokens, text, vocabulary);
  const error = firstError(listener.errors, text);
  if (error) {
    // the word the parser gave up on, unless recovery already marked it
    const at = tokens.find(token => token.start === error.start);
    if (at) {
      at.role = 'error';
    } else if (error.stop > error.start) {
      // inside a word ("ppc's"): split the word around it, so no character is in two tokens
      const split = tokens.flatMap(token => outsideOf(token, error, text));
      split.push({ start: error.start, stop: error.stop, text: text.slice(error.start, error.stop), role: 'error' });
      tokens.splice(0, tokens.length, ...split);
    }
  }
  tokens.sort((a, b) => a.start - b.start);
  tokens.forEach((token, index) => {
    const next = tokens[index + 1];
    if (token.role === 'without') {
      // "with no ppcs": swapping the "no" for "with" only has to take it out (see alternatives)
      token.afterWith = tokens[index - 1]?.role === 'with';
    } else if (token.bare && ['tech', 'turret-mount', 'fire-control'].includes(token.role)) {
      // "is vehicle flamer" starting a query: taking out the tech leaves "vehicle flamer" there
      token.exposesUnitWord = next !== undefined && !startsWithWord(next.text);
    }
  });
  return { tokens, error };
}

// the parts of a token before and after a span, keeping its role
function outsideOf(token, span, text) {
  if (token.stop <= span.start || token.start >= span.stop) {
    return [token];
  }
  const parts = [];
  // an equipment name ends where its piece does, so adding a tech doesn't repeat the rest
  const named = (piece, nameStart) => (token.name === undefined ? piece
    : { ...piece, nameStart, name: text.slice(nameStart, piece.stop) });
  if (token.start < span.start) {
    parts.push(named({ ...token, stop: span.start, text: text.slice(token.start, span.start) }, token.nameStart));
  }
  if (token.stop > span.stop) {
    parts.push(named({ ...token, start: span.stop, text: text.slice(span.stop, token.stop) }, span.stop));
  }
  return parts;
}

/**
 * The blanks a template leaves to fill in, written into the query as "<comparator>", and what each
 * becomes if it isn't filled in ('' leaves it out). Each default fits in its blank, so a query with
 * blanks parses with the defaults padded to the same length.
 */
export const SLOT_DEFAULTS = Object.freeze({
  'weight class': '',
  unit: 'units',
  'and/or': 'and',
  comparator: 'at least',
  quantity: '1',
  weapon: 'lasers',
});

/** The sections the search box can add, each made of blanks. */
export const TEMPLATES = Object.freeze({
  unit: '<weight class> <unit> with <comparator> <quantity> <weapon>',
  weapon: '<comparator> <quantity> <weapon>',
});

function findSlots(text) {
  return [...text.matchAll(/<(weight class|unit|and\/or|comparator|quantity|weapon)>/gi)].map(match => ({
    start: match.index,
    stop: match.index + match[0].length,
    text: match[0],
    role: 'slot',
    slot: match[1].toLowerCase(),
  }));
}

// reads the query as if each blank held its default, then puts the blanks back over those words
function analyzeWithSlots(text, slots, vocabulary) {
  let filled = text;
  for (const slot of slots) {
    filled = filled.slice(0, slot.start) + SLOT_DEFAULTS[slot.slot].padEnd(slot.stop - slot.start) + filled.slice(slot.stop);
  }
  const { tokens, error } = analyze(filled, vocabulary);
  const outside = token => slots.every(slot => token.stop <= slot.start || token.start >= slot.stop);
  const kept = tokens.filter(outside).map(token => ({ ...token, text: text.slice(token.start, token.stop) }));
  return {
    tokens: [...kept, ...slots].sort((a, b) => a.start - b.start),
    error: error && outside(error) ? error : null,
  };
}

/** A number, or the blank for one: typed into a box rather than picked from a list. */
export function isQuantity(token) {
  return token.role === 'quantity' || (token.role === 'slot' && token.slot === 'quantity');
}

/** What was typed in the number box, as query text: a whole number, or null if it isn't one. */
export function quantityText(typed) {
  const number = typed.trim();
  return /^\d{1,3}$/.test(number) ? String(Number(number)) : null;
}

/** The sections that can be added to this query: the unit one only starts a query. */
export function templates(text) {
  return text.trim() === '' ? ['unit', 'weapon'] : ['weapon'];
}

/**
 * The query with a template's blanks added at the end, joined by an "<and/or>" blank when it follows
 * another section. A weapon section starts an empty query with "units with", and follows a query
 * that's only units ("lams", "mechs except lams") with "with".
 */
export function addTemplate(text, name) {
  const before = text.trimEnd();
  if (before === '') {
    return name === 'unit' ? TEMPLATES.unit : `units with ${TEMPLATES.weapon}`;
  }
  const last = analyze(before).tokens.at(-1);
  const joined = last && (last.role === 'with' || last.role === 'operator');
  const join = last && last.role === 'unit' ? 'with ' : joined ? '' : '<and/or> ';
  return `${before} ${join}${TEMPLATES.weapon}`;
}

/** The query with every blank left as its default. */
export function fillSlots(text) {
  let filled = text;
  for (const slot of findSlots(text).reverse()) {
    filled = replaceToken(filled, slot, SLOT_DEFAULTS[slot.slot]).text;
  }
  return filled;
}

function firstError(errors, text) {
  if (errors.length === 0) {
    return null;
  }
  const { symbol, column, message } = errors[0];
  if (!symbol) {
    // the lexer: a character no token can start with; both halves of an emoji
    const length = text.codePointAt(column) > 0xffff ? 2 : 1;
    return { start: column, stop: Math.min(column + length, text.length), message };
  }
  if (symbol.type === BattletechParser.EOF || symbol.start < 0) {
    // something is missing at the end
    return { start: text.length, stop: text.length, message };
  }
  return { start: symbol.start, stop: symbol.stop + 1, message };
}

function isTerminal(node) {
  return node.symbol !== undefined;
}

function span(terminals, text, role) {
  const start = terminals[0].symbol.start;
  const stop = terminals[terminals.length - 1].symbol.stop + 1;
  return { start, stop, text: text.slice(start, stop), role };
}

function visit(context, tokens, text, vocabulary) {
  const children = context.children ?? [];
  if (context.ruleIndex === BattletechParser.RULE_equipmentName || context.ruleIndex === BattletechParser.RULE_bareName
      || context.ruleIndex === BattletechParser.RULE_plainName) {
    equipmentName(children.filter(child => isTerminal(child) && !isError(child)), tokens, text, vocabulary,
        context.ruleIndex === BattletechParser.RULE_plainName);
    children.filter(isError).forEach(node => terminal(node, context, tokens, text));
    return;
  }
  if (context.ruleIndex === BattletechParser.RULE_weightClass) {
    // one weight class, "ultra light" as one; "medium or heavy" is two of these. A unit tech before or after
    // it ("clan heavy", "heavy clan") is its own word, as QueryVisitor.withoutUnitTech reads it
    let words = children.filter(child => isTerminal(child) && !isError(child));
    const unitTechs = Object.keys(vocabulary.unitTechs).sort((a, b) => b.split(' ').length - a.split(' ').length);
    const firstToken = tokens.length;
    let peeled = true;
    while (peeled && words.length > 0) {
      peeled = false;
      for (const tech of unitTechs) {
        const length = tech.split(' ').length;
        const typed = part => part.map(word => word.getText().toLowerCase()).join(' ');
        if (length <= words.length && typed(words.slice(0, length)) === tech) {
          tokens.push({ ...span(words.slice(0, length), text, 'tech'), unitTech: true });
          words = words.slice(length);
        } else if (length <= words.length && typed(words.slice(words.length - length)) === tech) {
          tokens.push({ ...span(words.slice(words.length - length), text, 'tech'), unitTech: true });
          words = words.slice(0, words.length - length);
        } else {
          continue;
        }
        peeled = true;
        break;
      }
    }
    const siblings = context.parentCtx.children.filter(child => child.ruleIndex === BattletechParser.RULE_weightClass);
    if (words.length === 0 && siblings.length > 1) {
      // "heavy or clan mechs": taking the tech out would leave the "or" with nothing to join
      tokens.slice(firstToken).forEach(token => { token.joined = true; });
    }
    if (words.length > 0) {
      const weightClass = span(words, text, 'weight-class');
      // as WeightClass.fromString reads it: any case, but "ultralight" and "ultra-light" aren't one
      const spelled = name => name.toLowerCase().replace(/\s+/g, ' ');
      const known = vocabulary.weightClasses.length === 0
          || vocabulary.weightClasses.some(name => spelled(name) === spelled(weightClass.text));
      tokens.push(known ? weightClass : { ...weightClass, role: 'unknown' });
    }
    children.filter(isError).forEach(node => terminal(node, context, tokens, text));
    return;
  }
  if (context.ruleIndex === BattletechParser.RULE_unit && children.length > 1 && !children.some(isError)) {
    // "tracked vees": one unit word, swapped whole
    tokens.push(span(children, text, 'unit'));
    return;
  }
  for (const child of children) {
    if (!isTerminal(child)) {
      visit(child, tokens, text, vocabulary);
    } else {
      terminal(child, context, tokens, text);
    }
  }
}

function isError(node) {
  return typeof node.isErrorNode === 'function' && node.isErrorNode();
}

function terminal(node, context, tokens, text) {
  const symbol = node.symbol;
  if (symbol.start < 0 || symbol.type === BattletechParser.EOF || symbol.type === BattletechParser.NEWLINE) {
    // missing tokens the parser made up to recover have no text
    return;
  }
  let role;
  if (isError(node)) {
    role = 'error';
  } else if (symbol.type === BattletechParser.STOPWORD) {
    role = 'with';
  } else if (symbol.type === BattletechParser.WITHOUT || symbol.type === BattletechParser.NO) {
    role = 'without';
  } else if (symbol.type === BattletechParser.EXCEPT && context.ruleIndex === BattletechParser.RULE_negation) {
    // "but not lasers" is "without lasers"
    role = 'without';
  } else if (symbol.type === BattletechParser.EXCEPT || symbol.type === BattletechParser.NONUNIT) {
    // "mechs except lams", "non-lam mechs": units left out
    role = 'except';
  } else if (symbol.type === BattletechParser.COMMA) {
    role = 'comma';
  } else if (symbol.type === BattletechParser.QUANTITY) {
    role = 'quantity';
  } else {
    role = {
      [BattletechParser.RULE_unit]: 'unit',
      [BattletechParser.RULE_comparator]: 'comparator',
      [BattletechParser.RULE_logicaloperator]: 'operator',
      [BattletechParser.RULE_omni]: 'omni',
      // "engine rating of"
      [BattletechParser.RULE_ratingChunk]: 'rating',
    }[context.ruleIndex] ?? 'unknown';
  }
  tokens.push(span([node], text, role));
}

// "clan turret artemis iv lrm 20" -> tech "clan", mount "turret", fire control "artemis iv", equipment
// "lrm 20". plainName: no number in front, starting a query with no unit ("endo steel"), so it starts
// with a plain word
function equipmentName(words, tokens, text, vocabulary, plainName) {
  if (words.length === 0) {
    return;
  }
  const nameStart = words[0].symbol.start;
  let hasTech = false;
  let hasMount = false;
  let hasFireControl = false;
  // tech: whole leading words ("inner sphere"), longest first, only if a name follows
  const techs = Object.keys(vocabulary.techs).sort((a, b) => b.split(' ').length - a.split(' ').length);
  for (const tech of techs) {
    const length = tech.split(' ').length;
    if (words.length > length && words.slice(0, length).map(word => word.getText().toLowerCase()).join(' ') === tech) {
      tokens.push({ ...span(words.slice(0, length), text, 'tech'), bare: plainName });
      words = words.slice(length);
      hasTech = true;
      break;
    }
  }
  // mount: like TurretMount.fromSearch, a whole leading word, only if a name follows; not when the whole
  // name is a term looked up whole ("sponson turret", "pintle mount"), its plural too
  const named = key(words.map(word => word.getText()).join(''));
  const isMountTerm = vocabulary.turretMountTerms.some(term => key(term) === named || `${key(term)}s` === named);
  if (words.length > 1 && !isMountTerm && vocabulary.turretMounts.includes(words[0].getText().toLowerCase())) {
    tokens.push({ ...span(words.slice(0, 1), text, 'turret-mount'), bare: plainName && !hasTech });
    words = words.slice(1);
    hasMount = true;
  }
  // fire control: like FireControl.fromSearch, on letters and digits, so "artemisiv lrm 20" too;
  // not when the whole name is the system itself ("artemis iv"), or a term looked up whole, as
  // QueryVisitor does ("artemis lrm ammo", a group of ammo bins), its plural too ("artemis lrm ammos")
  const fireControls = [...vocabulary.fireControls].sort((a, b) => key(b).length - key(a).length);
  const whole = key(words.map(word => word.getText()).join(''));
  const singular = whole.endsWith('s') ? whole.slice(0, -1) : whole;
  if (!fireControls.some(fireControl => key(fireControl) === whole)
      && !vocabulary.fireControlTerms.some(term => key(term) === whole || key(term) === singular)) {
    found: for (const fireControl of fireControls) {
      for (let length = 1; length < words.length; length++) {
        if (key(words.slice(0, length).map(word => word.getText()).join('')) === key(fireControl)) {
          tokens.push({ ...span(words.slice(0, length), text, 'fire-control'), bare: plainName && !hasTech && !hasMount });
          words = words.slice(length);
          hasFireControl = true;
          break found;
        }
      }
    }
  }
  // the whole name too, prefixes and all, for adding a tech in front of it
  const equipment = span(words, text, 'equipment');
  // bare: the name starts the chunk, so whatever replaces it has to start with a plain word too
  const bare = plainName && !hasTech && !hasMount && !hasFireControl;
  tokens.push({ ...equipment, nameStart, name: text.slice(nameStart, equipment.stop), hasTech, hasMount, hasFireControl, bare });
}

/**
 * What a token could be swapped for, as {label, text}; text '' removes the token. Empty when there's
 * nothing to offer (errors, equipment outside the families, numbers: see isQuantity). An option with
 * a start replaces from there instead of from the token's start: a tech added in front of a whole
 * equipment name.
 */
export function alternatives(token, vocabulary = EMPTY_VOCABULARY) {
  const typed = token.text.toLowerCase().replace(/\s+/g, ' ');
  const others = words => words.filter(word => key(word) !== key(typed)).map(word => ({ label: word, text: word }));
  switch (token.role) {
    case 'weight-class':
      return others(vocabulary.weightClasses);
    case 'unit': {
      // "support vehicles" is one unit word; "tracked vees" is the unit word "tracked"
      const first = typed.split(' ')[0];
      const exact = vocabulary.units.find(unit => unit.singular === typed || unit.plural === typed);
      const current = exact ?? vocabulary.units.find(unit => unit.singular === first || unit.plural === first);
      // keep the number that was typed: "light mechs" -> "light tanks", "tracked vees" -> "mechs"
      const plural = exact && exact.singular !== exact.plural ? exact.plural === typed : typed.endsWith('s');
      return vocabulary.units.filter(unit => unit !== current)
          .map(unit => (plural ? unit.plural : unit.singular))
          .map(word => ({ label: word, text: word }));
    }
    case 'comparator':
      return others(vocabulary.comparatorsAfter.includes(typed) ? vocabulary.comparatorsAfter : vocabulary.comparatorsBefore);
    case 'operator':
      return others(vocabulary.operators);
    case 'with':
      // "with", "having", "that have", ...
      return others(vocabulary.withWords);
    case 'without':
      // "without ppcs" -> "with ppcs"; the other way a number like "2" would need "fewer than".
      // Right after a "with" ("with no ppcs") taking it out is enough. Anywhere else it becomes "with":
      // taken out, "mechs no ppcs" would lose its "with", and in "without ppcs and no lasers" the
      // lasers would still be left out. After "with" a name can start with a unit word ("with vehicle
      // flamer").
      if (vocabulary.withWords.length === 0) {
        return [];
      }
      return [{ label: 'with', text: token.afterWith ? '' : 'with' }];
    case 'omni':
      return [...others(vocabulary.omniWords), { label: 'omni or not', text: '' }];
    case 'tech': {
      // one word per other tech: "clan" offers "inner sphere", not "is" too; a unit's tech has "mixed tech" too
      const techs = token.unitTech ? vocabulary.unitTechs : vocabulary.techs;
      const current = Object.entries(techs).find(([word]) => word === typed)?.[1];
      const swaps = techWords(techs, current).map(word => ({ label: word, text: word }));
      return token.joined ? swaps : [...swaps, { label: 'any tech', text: orAny(token) }];
    }
    case 'turret-mount':
      return [...others(vocabulary.turretMounts), { label: 'any mount', text: orAny(token) }];
    case 'fire-control':
      return [...others(vocabulary.fireControls), { label: 'any fire control', text: orAny(token) }];
    case 'equipment':
      return equipmentAlternatives(token, typed, vocabulary).map(option => startingAChunk(token, option));
    case 'slot':
      return slotAlternatives(token.slot, vocabulary);
    default:
      return [];
  }
}

/**
 * The server's spellings (GET /api/suggestions, autocorrect) for the misspelled words inside a token, as
 * options that replace just that word: in "mediun lasers", "medium" gives "medium lasers". Empty when the
 * token holds no misspelled word.
 */
export function suggestedAlternatives(token, text, words = []) {
  return words
      .filter(word => word.start >= token.start && word.stop <= token.stop)
      .flatMap(word => word.suggestions.map(suggestion => ({
        label: suggestion,
        text: text.slice(token.start, word.start) + suggestion + text.slice(word.stop, token.stop),
      })));
}

// A name with no number starting a query with no unit has to start with a plain word, so "small cockpit"
// can't become "tripod cockpit" (read as tripods): a swap starting with a unit word gets "any" ("any
// tripod cockpit"), which still means at least one. After "with" it needn't (user, 2026-11-15).
function startingAChunk(token, option) {
  if (!token.bare || option.start !== undefined || option.text === '' || startsWithWord(option.text)) {
    return option;
  }
  return { ...option, text: `any ${option.text}` };
}

// "any" in place of a word taken out in front of a name like that: "is vehicle flamer" -> "any vehicle
// flamer"
function orAny(token) {
  return token.exposesUnitWord ? 'any' : '';
}

// whether the text starts with a plain word, not a unit word or a number; "triple strength" counts, as
// in the grammar's bareName
function startsWithWord(text) {
  const lexer = new BattletechLexer(new InputStream(text, false));
  lexer.removeErrorListeners();
  const type = lexer.nextToken().type;
  return type === BattletechLexer.WORD || type === BattletechLexer.AMMO || type === BattletechLexer.TRIPLESTRENGTH;
}

/** One word for each tech but the one given: "inner sphere" and "clan", not "is" too. */
function techWords(techs, except = undefined) {
  const seen = new Set([except]);
  const words = [];
  for (const [word, tech] of Object.entries(techs)) {
    if (!seen.has(tech)) {
      seen.add(tech);
      words.push(word);
    }
  }
  return words;
}

// what a blank offers; picking one fills it in
function slotAlternatives(slot, vocabulary) {
  const words = list => list.map(word => ({ label: word, text: word }));
  switch (slot) {
    case 'weight class':
      return [...words(vocabulary.weightClasses), { label: 'any weight', text: '' }];
    case 'unit':
      return words(vocabulary.units.map(unit => unit.plural));
    case 'and/or':
      return words(vocabulary.operators);
    case 'comparator':
      return words(vocabulary.comparatorsBefore);
    case 'weapon':
      return words(Object.keys(vocabulary.families));
    default:
      return [];
  }
}

// What can come next (nextWord): the query with the ending has to read without an error, with a word of the role
// where the ending starts, after a word of one of the roles. An unfinished query's own roles can't be used: the
// parser gives up on "mechs with 2 " and "heavy " could be a name.
const NEXT_WORDS = [
  { ending: 'units', role: 'unit', after: ['weight-class', 'tech', 'omni'], slot: 'unit', text: SLOT_DEFAULTS.unit },
  // "heavy or ": a weight class, but which one isn't known
  { ending: 'light units', role: 'weight-class', after: ['operator', 'comma'] },
  // "mechs except ": a unit or a weapon
  { ending: 'units', role: 'unit', after: ['except'] },
  { ending: 'with lasers', role: 'with', after: ['unit'], slot: 'with', text: 'with' },
  { ending: 'at least 1 laser', role: 'comparator', after: ['with', 'operator'], slot: 'comparator',
    text: `${SLOT_DEFAULTS.comparator} ${SLOT_DEFAULTS.quantity}` },
  { ending: '1 laser', role: 'quantity', after: ['comparator'], slot: 'quantity', text: SLOT_DEFAULTS.quantity },
  // no one weapon is likelier than the rest, so there's only its list; not after "lrm 20", where the number is the
  // name's and nothing is missing
  { ending: 'lasers', role: 'equipment', after: ['quantity', 'comparator', 'without'], slot: 'weapon', text: null,
    unfinished: true },
  { ending: 'and lasers', role: 'operator', after: ['equipment', 'quantity'], slot: 'and/or', text: SLOT_DEFAULTS['and/or'],
    needsComplete: true },
];

/**
 * The word that comes next after a query ending in a space, when it's reasonably known (user, 2026-11-22):
 * "heavy " -> units, "mechs " -> with, "mechs with " -> at least 1. Its slot says what its list holds (nextOptions).
 * A null text has only the list ("mechs with 2 ": some weapon). With needsComplete it's only next if the query so
 * far is a whole search, which the server knows ("2 medium " isn't a name yet). Null when it isn't known.
 *
 * @returns {?{text: ?string, slot: string, needsComplete: boolean}}
 */
export function nextWord(text, vocabulary = EMPTY_VOCABULARY) {
  if (text.trim() === '' || !text.endsWith(' ') || findSlots(text).length > 0) {
    return null;
  }
  const unfinished = analyze(text, vocabulary).error !== null;
  for (const next of NEXT_WORDS) {
    if (next.unfinished && !unfinished) {
      continue;
    }
    const { tokens, error } = analyze(text + next.ending, vocabulary);
    const index = tokens.findIndex(token => token.start === text.length);
    if (error || index < 1 || tokens[index].role !== next.role || tokens.some(token => token.role === 'unknown')
        || !next.after.includes(tokens[index - 1].role)) {
      continue;
    }
    return next.slot ? { text: next.text, slot: next.slot, needsComplete: next.needsComplete === true } : null;
  }
  return null;
}

/** What else the next word could be, to pick from; none for a number, which is typed into a box. */
export function nextOptions(next, vocabulary = EMPTY_VOCABULARY) {
  return next.slot === 'with' ? vocabulary.withWords.map(word => ({ label: word, text: word }))
    : slotAlternatives(next.slot, vocabulary);
}

// the families whose launchers take Artemis (Streaks don't); MRMs take Apollo
const ARTEMIS_FAMILIES = ['lrms', 'srms', 'mmls'];

// a tech or fire control in front of a family weapon that has none: "clan only", "with artemis"
function prefixAlternatives(token, families, vocabulary) {
  const options = [];
  if (!token.hasTech) {
    techWords(vocabulary.techs).forEach(word =>
      options.push({ label: `${word} only`, text: `${word} ${token.name}`, start: token.nameStart }));
  }
  if (!token.hasFireControl && !families.includes('streaks')) {
    if (families.some(term => ARTEMIS_FAMILIES.includes(term)) && vocabulary.fireControls.includes('artemis')) {
      options.push({ label: 'with artemis', text: `artemis ${token.text}` });
    }
    if (families.includes('mrms') && vocabulary.fireControls.includes('apollo')) {
      options.push({ label: 'with apollo', text: `apollo ${token.text}` });
    }
  }
  return options;
}

// "atms" -> "atm", "torpedoes" -> "torpedo", as EquipmentNames.familyOfSingular reads them
function singular(term) {
  return term.slice(0, term.endsWith('oes') ? -2 : -1);
}

function equipmentAlternatives(token, typed, vocabulary) {
  // a component ("xl engine"): the other types of its kind, as ComponentNames names them
  const kind = Object.values(vocabulary.components).find(names => names.some(name => key(name) === key(typed)));
  if (kind) {
    return kind.filter(name => key(name) !== key(typed)).map(name => ({ label: name, text: name }));
  }
  let familyTerm = Object.keys(vocabulary.families).find(term => key(term) === key(typed));
  // a family in the singular ("atm") when no weapon has that name: "ppc" is the PPC
  if (!familyTerm && !Object.keys(vocabulary.equipment).some(name => key(name) === key(typed))) {
    familyTerm = Object.keys(vocabulary.families).find(term => key(singular(term)) === key(typed));
  }
  const options = [];
  const add = (word, label = word) => {
    if (key(word) !== key(typed) && !options.some(option => option.text === word)) {
      options.push({ label, text: word });
    }
  };
  if (familyTerm) {
    // "lrms": the other families, then each LRM
    Object.keys(vocabulary.families).forEach(term => add(term, `any of the ${term}`));
    vocabulary.families[familyTerm].forEach(member => add(member));
    return [...options, ...prefixAlternatives(token, [familyTerm], vocabulary)];
  }
  let member = Object.keys(vocabulary.equipment).find(name => key(name) === key(typed));
  // a plural, as the search reads it too: "lrm 20s" offers "lrm 15s"
  const plural = !member && key(typed).endsWith('s');
  if (plural) {
    member = Object.keys(vocabulary.equipment).find(name => key(name) === key(typed).slice(0, -1));
  }
  if (!member) {
    return options;
  }
  // "lrm 20": any LRM first, then the other LRMs
  const families = vocabulary.equipment[member];
  families.forEach(term => add(term, `any of the ${term}`));
  families.forEach(term => vocabulary.families[term].forEach(name => add(plural ? `${name}s` : name)));
  return [...options, ...prefixAlternatives(token, families, vocabulary)];
}

/**
 * The text with the token swapped for the replacement (removed when it's ''), and where the caret
 * goes: after the replacement.
 */
export function replaceToken(text, token, replacement) {
  if (replacement === '') {
    // take one space with it, so "clan lrm 20" -> "lrm 20"
    const stop = text[token.stop] === ' ' ? token.stop + 1 : token.stop;
    return { text: text.slice(0, token.start) + text.slice(stop), caret: token.start };
  }
  return {
    text: text.slice(0, token.start) + replacement + text.slice(token.stop),
    caret: token.start + replacement.length,
  };
}
