// How a search query is read, word by word, for the search box to color, and what each word could
// be swapped for. No DOM here, so Node can test it (src/test/js).
//
// Parses with the JavaScript the build generates from the same grammar as the server
// (src/main/antlr4/me/Battletech.g4), and splits equipment names the way QueryVisitor does: a
// leading tech word ("clan"), then a fire control ("artemis"), then the equipment. Keep the two in
// step. The word lists come from GET /api/vocabulary (QueryVocabulary on the server).
import { CharStreams, CommonTokenStream, ErrorListener } from 'antlr4';
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
 * fire-control, equipment, operator, unknown (a weight class that isn't one) or error.
 * Multi-word phrases ("at least", "ultra light", "lrm 20") are one token. Positions are character
 * offsets into text, stop exclusive.
 *
 * @returns {{tokens: {start: number, stop: number, text: string, role: string}[], error: ?{start: number, stop: number, message: string}}}
 */
export function analyze(text, vocabulary = EMPTY_VOCABULARY) {
  const listener = new RecordingErrorListener();
  const lexer = new BattletechLexer(CharStreams.fromString(text));
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
      tokens.push({ start: error.start, stop: error.stop, text: text.slice(error.start, error.stop), role: 'error' });
    }
  }
  tokens.sort((a, b) => a.start - b.start);
  return { tokens, error };
}

function firstError(errors, text) {
  if (errors.length === 0) {
    return null;
  }
  const { symbol, column, message } = errors[0];
  if (!symbol) {
    // the lexer: a character no token can start with
    return { start: column, stop: Math.min(column + 1, text.length), message };
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
  // tech: whole leading words ("inner sphere"), longest first, only if a name follows
  const techs = Object.keys(vocabulary.techs).sort((a, b) => b.split(' ').length - a.split(' ').length);
  for (const tech of techs) {
    const length = tech.split(' ').length;
    if (words.length > length && words.slice(0, length).map(word => word.getText().toLowerCase()).join(' ') === tech) {
      tokens.push(span(words.slice(0, length), text, 'tech'));
      words = words.slice(length);
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
          break found;
        }
      }
    }
  }
  tokens.push(span(words, text, 'equipment'));
}

/**
 * What a token could be swapped for, as {label, text}; text '' removes the token. Empty when there's
 * nothing to offer (quantities, errors, equipment outside the families).
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
      const seen = new Set([current]);
      const options = [];
      for (const [word, tech] of Object.entries(vocabulary.techs)) {
        if (!seen.has(tech)) {
          seen.add(tech);
          options.push({ label: word, text: word });
        }
      }
      return [...options, { label: 'any tech', text: '' }];
    }
    case 'fire-control':
      return [...others(vocabulary.fireControls), { label: 'any fire control', text: '' }];
    case 'equipment':
      return equipmentAlternatives(typed, vocabulary);
    default:
      return [];
  }
}

function equipmentAlternatives(typed, vocabulary) {
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
    return options;
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
  return options;
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
