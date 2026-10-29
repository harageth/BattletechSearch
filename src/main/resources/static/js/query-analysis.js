// How a search query is read, word by word, for the search box to color, and what each word could
// be swapped for. No DOM here, so Node can test it (src/test/js).
//
// Parses with the JavaScript the build generates from the same grammar as the server
// (src/main/antlr4/me/Battletech.g4), and splits equipment names the way QueryVisitor does: a
// leading tech word ("clan"), then a fire control ("artemis"), then the equipment. Keep the two in
// step. The word lists come from GET /api/vocabulary (QueryVocabulary on the server).
import { CommonTokenStream, ErrorListener, InputStream } from 'antlr4';
import BattletechLexer from './grammar/me/BattletechLexer.js';
import BattletechParser from './grammar/me/BattletechParser.js';

/** Before /api/vocabulary loads: everything still gets a role, nothing has alternatives. */
export const EMPTY_VOCABULARY = Object.freeze({
  weightClasses: [], units: [], comparatorsBefore: [], comparatorsAfter: [], operators: [],
  techs: {}, fireControls: [], families: {}, equipment: {},
});

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
 * fire-control, equipment, operator, unknown (a weight class that isn't one), error, or slot (a
 * blank a template left, "<quantity>", with its name in slot).
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
  return { tokens, error };
}

// the parts of a token before and after a span, keeping its role
function outsideOf(token, span, text) {
  if (token.stop <= span.start || token.start >= span.stop) {
    return [token];
  }
  const parts = [];
  if (token.start < span.start) {
    parts.push({ ...token, stop: span.start, text: text.slice(token.start, span.start) });
  }
  if (token.stop > span.stop) {
    parts.push({ ...token, start: span.stop, text: text.slice(span.stop, token.stop) });
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
 * another section. A weapon section starts an empty query with "units with".
 */
export function addTemplate(text, name) {
  const before = text.trimEnd();
  if (before === '') {
    return name === 'unit' ? TEMPLATES.unit : `units with ${TEMPLATES.weapon}`;
  }
  const last = analyze(before).tokens.at(-1);
  const joined = last && (last.role === 'with' || last.role === 'operator');
  return `${before} ${joined ? '' : '<and/or> '}${TEMPLATES.weapon}`;
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
  if (context.ruleIndex === BattletechParser.RULE_equipmentName) {
    equipmentName(children.filter(child => isTerminal(child) && !isError(child)), tokens, text, vocabulary);
    children.filter(isError).forEach(node => terminal(node, context, tokens, text));
    return;
  }
  for (let i = 0; i < children.length; i++) {
    const child = children[i];
    if (!isTerminal(child)) {
      visit(child, tokens, text, vocabulary);
    } else if (context.ruleIndex === BattletechParser.RULE_line && child.symbol.type === BattletechParser.WORD && !isError(child)) {
      // the weight class: every word before the unit, "ultra light" as one
      const words = [child];
      while (i + 1 < children.length && isTerminal(children[i + 1]) && !isError(children[i + 1])
          && children[i + 1].symbol.type === BattletechParser.WORD) {
        words.push(children[++i]);
      }
      const weightClass = span(words, text, 'weight-class');
      const known = vocabulary.weightClasses.length === 0
          || vocabulary.weightClasses.some(name => key(name) === key(weightClass.text));
      tokens.push(known ? weightClass : { ...weightClass, role: 'unknown' });
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
  } else if (symbol.type === BattletechParser.QUANTITY) {
    role = 'quantity';
  } else {
    role = {
      [BattletechParser.RULE_unit]: 'unit',
      [BattletechParser.RULE_comparator]: 'comparator',
      [BattletechParser.RULE_logicaloperator]: 'operator',
    }[context.ruleIndex] ?? 'unknown';
  }
  tokens.push(span([node], text, role));
}

// "clan artemis iv lrm 20" -> tech "clan", fire control "artemis iv", equipment "lrm 20"
function equipmentName(words, tokens, text, vocabulary) {
  if (words.length === 0) {
    return;
  }
  const nameStart = words[0].symbol.start;
  let hasTech = false;
  let hasFireControl = false;
  // tech: whole leading words ("inner sphere"), longest first, only if a name follows
  const techs = Object.keys(vocabulary.techs).sort((a, b) => b.split(' ').length - a.split(' ').length);
  for (const tech of techs) {
    const length = tech.split(' ').length;
    if (words.length > length && words.slice(0, length).map(word => word.getText().toLowerCase()).join(' ') === tech) {
      tokens.push(span(words.slice(0, length), text, 'tech'));
      words = words.slice(length);
      hasTech = true;
      break;
    }
  }
  // fire control: like FireControl.fromSearch, on letters and digits, so "artemisiv lrm 20" too;
  // not when the whole name is the system itself ("artemis iv")
  const fireControls = [...vocabulary.fireControls].sort((a, b) => key(b).length - key(a).length);
  const whole = key(words.map(word => word.getText()).join(''));
  if (!fireControls.some(fireControl => key(fireControl) === whole)) {
    found: for (const fireControl of fireControls) {
      for (let length = 1; length < words.length; length++) {
        if (key(words.slice(0, length).map(word => word.getText()).join('')) === key(fireControl)) {
          tokens.push(span(words.slice(0, length), text, 'fire-control'));
          words = words.slice(length);
          hasFireControl = true;
          break found;
        }
      }
    }
  }
  // the whole name too, prefixes and all, for adding a tech in front of it
  const equipment = span(words, text, 'equipment');
  tokens.push({ ...equipment, nameStart, name: text.slice(nameStart, equipment.stop), hasTech, hasFireControl });
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
      const current = vocabulary.units.find(unit => unit.singular === typed || unit.plural === typed);
      // keep the number that was typed: "light mechs" -> "light tanks"
      const plural = current ? current.plural === typed && current.plural !== current.singular : typed.endsWith('s');
      return vocabulary.units.filter(unit => unit !== current)
          .map(unit => (plural ? unit.plural : unit.singular))
          .map(word => ({ label: word, text: word }));
    }
    case 'comparator':
      return others(vocabulary.comparatorsAfter.includes(typed) ? vocabulary.comparatorsAfter : vocabulary.comparatorsBefore);
    case 'operator':
      return others(vocabulary.operators);
    case 'tech': {
      // one word per other tech: "clan" offers "inner sphere", not "is" too
      const current = Object.entries(vocabulary.techs).find(([word]) => word === typed)?.[1];
      return [...techWords(vocabulary, current).map(word => ({ label: word, text: word })), { label: 'any tech', text: '' }];
    }
    case 'fire-control':
      return [...others(vocabulary.fireControls), { label: 'any fire control', text: '' }];
    case 'equipment':
      return equipmentAlternatives(token, typed, vocabulary);
    case 'slot':
      return slotAlternatives(token.slot, vocabulary);
    default:
      return [];
  }
}

/** One word for each tech but the one given: "inner sphere" and "clan", not "is" too. */
function techWords(vocabulary, except = undefined) {
  const seen = new Set([except]);
  const words = [];
  for (const [word, tech] of Object.entries(vocabulary.techs)) {
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

// the families whose launchers take Artemis (Streaks don't); MRMs take Apollo
const ARTEMIS_FAMILIES = ['lrms', 'srms', 'mmls'];

// a tech or fire control in front of a family weapon that has none: "clan only", "with artemis"
function prefixAlternatives(token, families, vocabulary) {
  const options = [];
  if (!token.hasTech) {
    techWords(vocabulary).forEach(word =>
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

function equipmentAlternatives(token, typed, vocabulary) {
  const familyTerm = Object.keys(vocabulary.families).find(term => key(term) === key(typed));
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
