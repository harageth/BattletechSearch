// The search box's reading of a query. Runs against target/classes, where the build puts the
// scripts next to the parser it generates from the grammar.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { analyze, alternatives, isQuantity, quantityText, replaceToken, templates, addTemplate, fillSlots, EMPTY_VOCABULARY } from '../../../target/classes/static/js/query-analysis.js';

// the shape GET /api/vocabulary returns, cut down
const vocabulary = {
  weightClasses: ['ultra light', 'light', 'medium', 'heavy', 'assault', 'ultra heavy'],
  units: [
    { singular: 'unit', plural: 'units' },
    { singular: 'mech', plural: 'mechs' },
    { singular: 'tank', plural: 'tanks' },
    { singular: 'tracked', plural: 'tracked' },
  ],
  comparatorsBefore: ['at least', 'at most', 'exactly', 'fewer than'],
  comparatorsAfter: ['or more', 'or fewer', 'or less'],
  operators: ['and', 'or'],
  techs: { 'inner sphere': 'INNER_SPHERE', clan: 'CLAN', is: 'INNER_SPHERE' },
  fireControls: ['artemis iv', 'artemis v', 'artemis', 'apollo'],
  families: {
    lrms: ['lrm 10', 'lrm 20', 'streak lrm 20'],
    mrms: ['mrm 40'],
    streaks: ['streak lrm 20', 'streak srm 6'],
    lasers: ['medium laser', 'er medium laser'],
  },
  equipment: {
    'lrm 10': ['lrms'],
    'lrm 20': ['lrms'],
    'streak lrm 20': ['lrms', 'streaks'],
    'streak srm 6': ['streaks'],
    'mrm 40': ['mrms'],
    'medium laser': ['lasers'],
    'er medium laser': ['lasers'],
  },
};

/** "text:role" for each token, to compare readably. */
function roles(query) {
  return analyze(query, vocabulary).tokens.map(token => `${token.text}:${token.role}`);
}

test('colors each part of a query', () => {
  assert.deepEqual(roles('light mechs with at least 2 lrm 20'),
      ['light:weight-class', 'mechs:unit', 'with:with', 'at least:comparator', '2:quantity', 'lrm 20:equipment']);
  assert.equal(analyze('light mechs with at least 2 lrm 20', vocabulary).error, null);
});

test('multi-word weight classes are one token', () => {
  assert.deepEqual(roles('ultra light units with 1 ppc'),
      ['ultra light:weight-class', 'units:unit', 'with:with', '1:quantity', 'ppc:equipment']);
});

test('a weight class that is not one is unknown', () => {
  assert.deepEqual(roles('huge mechs with 1 ppc').slice(0, 1), ['huge:unknown']);
});

test('units in any case and plural, and tanks', () => {
  assert.deepEqual(roles('MECHS with at least 1 ppc').slice(0, 1), ['MECHS:unit']);
  assert.deepEqual(roles('tanks with at least 1 ppc').slice(0, 1), ['tanks:unit']);
  assert.deepEqual(roles('tracked with at least 1 ppc').slice(0, 1), ['tracked:unit']);
});

test('every comparator, before and after the quantity', () => {
  for (const comparator of ['at least', 'at most', 'exactly', '=', 'no more than', 'fewer than', 'less than', 'greater than']) {
    assert.deepEqual(roles(`mechs with ${comparator} 3 ppc`).slice(2, 4), [`${comparator}:comparator`, '3:quantity']);
  }
  for (const comparator of ['or more', 'or fewer', 'or less']) {
    assert.deepEqual(roles(`mechs with 4 ${comparator} ppc`).slice(2, 4), ['4:quantity', `${comparator}:comparator`]);
  }
});

test('quantity words', () => {
  for (const quantity of ['a', 'double', 'four', 'Ten', 'multiple']) {
    assert.deepEqual(roles(`mechs with ${quantity} ppc`).slice(2), [`${quantity}:quantity`, 'ppc:equipment']);
  }
});

test('a number ends an equipment name unless another word follows', () => {
  assert.deepEqual(roles('mechs with 2 ppc 3 srm6').slice(2),
      ['2:quantity', 'ppc:equipment', '3:quantity', 'srm6:equipment']);
  assert.deepEqual(roles('mechs with 2 lrm 20 3 srm 6').slice(2),
      ['2:quantity', 'lrm 20:equipment', '3:quantity', 'srm 6:equipment']);
});

test('and / or', () => {
  assert.deepEqual(roles('mechs with at least 2 lrm 20 and at most 1 srm 6 or 2 ac 10').filter(role => role.endsWith(':operator')),
      ['and:operator', 'or:operator']);
});

test('a leading tech word, then a fire control, then the equipment', () => {
  assert.deepEqual(roles('mechs with 2 clan artemis lrm 20').slice(3),
      ['clan:tech', 'artemis:fire-control', 'lrm 20:equipment']);
  assert.deepEqual(roles('mechs with 4 inner sphere ppc').slice(3), ['inner sphere:tech', 'ppc:equipment']);
  assert.deepEqual(roles('mechs with 2 is artemis lrm 20').slice(3),
      ['is:tech', 'artemis:fire-control', 'lrm 20:equipment']);
  assert.deepEqual(roles('mechs with at least 1 Artemis IV SRM 6').slice(4), ['Artemis IV:fire-control', 'SRM 6:equipment']);
  assert.deepEqual(roles('mechs with 1 apollo mrm 40').slice(3), ['apollo:fire-control', 'mrm 40:equipment']);
});

test('a tech word or fire control alone is the equipment', () => {
  // like the server: "clan" alone isn't a tech prefix, and "artemis iv" alone is the system
  assert.deepEqual(roles('mechs with 1 clan').slice(3), ['clan:equipment']);
  assert.deepEqual(roles('mechs with 1 artemis iv').slice(3), ['artemis iv:equipment']);
});

test('works before the vocabulary loads', () => {
  assert.deepEqual(analyze('light mechs with 2 lrm 20', EMPTY_VOCABULARY).tokens.map(token => token.role),
      ['weight-class', 'unit', 'with', 'quantity', 'equipment']);
});

test('marks where the query goes wrong', () => {
  const missing = analyze('mechs with at least 2', vocabulary);
  assert.ok(missing.error);
  assert.equal(missing.error.start, 'mechs with at least 2'.length);

  const extra = analyze('mechs with at least 2 ppc with', vocabulary);
  assert.ok(extra.error);
  assert.deepEqual(extra.tokens.filter(token => token.role === 'error').map(token => token.text), ['with']);

  const character = analyze("mechs with at least 2 ppc's", vocabulary);
  assert.ok(character.error);
  assert.deepEqual(character.tokens.filter(token => token.role === 'error').map(token => token.text), ["'"]);
  // the word around it is split, not overlapped, so each character is drawn once
  assert.deepEqual(character.tokens.slice(-3).map(token => `${token.text}:${token.role}`), ['ppc:equipment', "':error", 's:equipment']);
});

test('the empty query is an error with nothing to mark', () => {
  const empty = analyze('', vocabulary);
  assert.ok(empty.error);
  assert.deepEqual(empty.tokens, []);
});

function token(query, text) {
  return analyze(query, vocabulary).tokens.find(found => found.text === text);
}

const texts = options => options.map(option => option.text);
// the swaps, without the tech and fire control that can be added in front (tested on their own)
const swaps = options => texts(options.filter(option => !option.label.endsWith(' only') && !option.label.startsWith('with ')));

test('weight classes offer the other weight classes', () => {
  assert.deepEqual(texts(alternatives(token('light mechs with 1 ppc', 'light'), vocabulary)),
      ['ultra light', 'medium', 'heavy', 'assault', 'ultra heavy']);
});

test('unit words keep the number that was typed', () => {
  assert.deepEqual(texts(alternatives(token('light mechs with 1 ppc', 'mechs'), vocabulary)), ['units', 'tanks', 'tracked']);
  assert.deepEqual(texts(alternatives(token('light mech with 1 ppc', 'mech'), vocabulary)), ['unit', 'tank', 'tracked']);
});

test('comparators offer the others on the same side of the quantity', () => {
  assert.deepEqual(texts(alternatives(token('mechs with at least 1 ppc', 'at least'), vocabulary)),
      ['at most', 'exactly', 'fewer than']);
  assert.deepEqual(texts(alternatives(token('mechs with 1 or more ppc', 'or more'), vocabulary)), ['or fewer', 'or less']);
});

test('operators, tech and fire control', () => {
  assert.deepEqual(texts(alternatives(token('mechs with 1 ppc and 1 srm 6', 'and'), vocabulary)), ['or']);
  // one word per tech, and removing it
  assert.deepEqual(texts(alternatives(token('mechs with 1 clan ppc', 'clan'), vocabulary)), ['inner sphere', '']);
  assert.deepEqual(texts(alternatives(token('mechs with 1 is ppc', 'is'), vocabulary)), ['clan', '']);
  assert.deepEqual(texts(alternatives(token('mechs with 1 artemis lrm 20', 'artemis'), vocabulary)),
      ['artemis iv', 'artemis v', 'apollo', '']);
});

test('equipment offers its families, then the other weapons in them', () => {
  const options = alternatives(token('mechs with 2 lrm 20', 'lrm 20'), vocabulary);
  assert.deepEqual(swaps(options), ['lrms', 'lrm 10', 'streak lrm 20']);
  assert.equal(options[0].label, 'any of the lrms');
  assert.deepEqual(swaps(alternatives(token('mechs with 2 streak lrm 20', 'streak lrm 20'), vocabulary)),
      ['lrms', 'streaks', 'lrm 10', 'lrm 20', 'streak srm 6']);
  // matched on letters and digits
  assert.deepEqual(swaps(alternatives(token('mechs with 2 LRM-20', 'LRM-20'), vocabulary)), ['lrms', 'lrm 10', 'streak lrm 20']);
});

test('plural equipment offers plurals', () => {
  assert.deepEqual(swaps(alternatives(token('mechs with 2 lrm 20s', 'lrm 20s'), vocabulary)),
      ['lrms', 'lrm 10s', 'streak lrm 20s']);
  assert.deepEqual(swaps(alternatives(token('mechs with 4 medium lasers', 'medium lasers'), vocabulary)),
      ['lasers', 'er medium lasers']);
});

test('a family term offers the other families and its weapons', () => {
  assert.deepEqual(swaps(alternatives(token('mechs with 4 lasers', 'lasers'), vocabulary)),
      ['lrms', 'mrms', 'streaks', 'medium laser', 'er medium laser']);
});

test('a family in the singular offers the same, unless a weapon has that name', () => {
  assert.deepEqual(swaps(alternatives(token('mechs with 1 laser', 'laser'), vocabulary)),
      ['lrms', 'mrms', 'streaks', 'lasers', 'medium laser', 'er medium laser']);
  const named = { ...vocabulary, families: { ...vocabulary.families, 'medium lasers': ['medium laser'] } };
  assert.deepEqual(swaps(alternatives(token('mechs with 1 medium laser', 'medium laser'), named)), ['lasers', 'er medium laser']);
});

test('numbers are typed into a box, not picked from a list', () => {
  assert.ok(isQuantity(token('mechs with 2 ppc', '2')));
  assert.ok(isQuantity(analyze('units with <comparator> <quantity> <weapon>', vocabulary).tokens.find(found => found.slot === 'quantity')));
  assert.ok(!isQuantity(token('mechs with 2 ppc', 'ppc')));
  assert.deepEqual(alternatives(token('mechs with 2 ppc', '2'), vocabulary), []);
  assert.equal(quantityText(' 12 '), '12');
  assert.equal(quantityText('007'), '7');
  for (const wrong of ['', 'two', '1.5', '-1', '1000']) {
    assert.equal(quantityText(wrong), null, wrong);
  }
});

test('nothing to offer for equipment outside the families', () => {
  assert.deepEqual(alternatives(token('mechs with 2 jump jet', 'jump jet'), vocabulary), []);
});

test('replacing a token', () => {
  const query = 'light mechs with 2 lrm 20';
  assert.deepEqual(replaceToken(query, token(query, 'light'), 'ultra heavy'),
      { text: 'ultra heavy mechs with 2 lrm 20', caret: 'ultra heavy'.length });
  assert.deepEqual(replaceToken(query, token(query, 'lrm 20'), 'lrms'), { text: 'light mechs with 2 lrms', caret: query.length - 2 });
  // removing takes the space after it
  const clan = 'mechs with 2 clan lrm 20';
  assert.deepEqual(replaceToken(clan, token(clan, 'clan'), ''), { text: 'mechs with 2 lrm 20', caret: 'mechs with 2 '.length });
});

test('family weapons can get a tech, and launchers a fire control, in front', () => {
  const prefixes = (query, text) => alternatives(token(query, text), vocabulary)
      .filter(option => option.label.endsWith(' only') || option.label.startsWith('with '))
      .map(option => `${option.label}=${option.text}`);
  assert.deepEqual(prefixes('mechs with 2 lrm 20', 'lrm 20'),
      ['inner sphere only=inner sphere lrm 20', 'clan only=clan lrm 20', 'with artemis=artemis lrm 20']);
  assert.deepEqual(prefixes('mechs with 2 lasers', 'lasers'), ['inner sphere only=inner sphere lasers', 'clan only=clan lasers']);
  assert.deepEqual(prefixes('mechs with 1 mrm 40', 'mrm 40'),
      ['inner sphere only=inner sphere mrm 40', 'clan only=clan mrm 40', 'with apollo=apollo mrm 40']);
  // Streaks take no Artemis; nothing twice
  assert.deepEqual(prefixes('mechs with 2 streak lrm 20', 'streak lrm 20'),
      ['inner sphere only=inner sphere streak lrm 20', 'clan only=clan streak lrm 20']);
  assert.deepEqual(prefixes('mechs with 2 clan artemis lrm 20', 'lrm 20'), []);
  assert.deepEqual(prefixes('mechs with 2 clan lrm 20', 'lrm 20'), ['with artemis=artemis lrm 20']);
});

test('a tech goes in front of the fire control', () => {
  const query = 'mechs with 2 artemis lrm 20';
  const equipment = token(query, 'lrm 20');
  const clan = alternatives(equipment, vocabulary).find(option => option.label === 'clan only');
  assert.deepEqual(replaceToken(query, { ...equipment, start: clan.start }, clan.text),
      { text: 'mechs with 2 clan artemis lrm 20', caret: query.length + 'clan '.length });
});

test('the unit section starts a query, the weapon section adds to one', () => {
  assert.deepEqual(templates(''), ['unit', 'weapon']);
  assert.deepEqual(templates('mechs with 1 ppc'), ['weapon']);
  assert.equal(addTemplate('', 'unit'), '<weight class> <unit> with <comparator> <quantity> <weapon>');
  assert.equal(addTemplate(' ', 'weapon'), 'units with <comparator> <quantity> <weapon>');
  assert.equal(addTemplate('mechs with 1 ppc ', 'weapon'), 'mechs with 1 ppc <and/or> <comparator> <quantity> <weapon>');
  // no "and" after "with" or another and/or
  assert.equal(addTemplate('mechs with', 'weapon'), 'mechs with <comparator> <quantity> <weapon>');
  assert.equal(addTemplate('mechs with 1 ppc or', 'weapon'), 'mechs with 1 ppc or <comparator> <quantity> <weapon>');
});

test('blanks are pieces of their own, and the rest still reads', () => {
  assert.deepEqual(roles('<weight class> <unit> with <comparator> <quantity> <weapon>'),
      ['<weight class>:slot', '<unit>:slot', 'with:with', '<comparator>:slot', '<quantity>:slot', '<weapon>:slot']);
  assert.deepEqual(roles('light mechs with at least 2 lrm 20 <and/or> exactly <quantity> clan <weapon>'),
      ['light:weight-class', 'mechs:unit', 'with:with', 'at least:comparator', '2:quantity', 'lrm 20:equipment',
        '<and/or>:slot', 'exactly:comparator', '<quantity>:slot', 'clan:tech', '<weapon>:slot']);
  const blanks = analyze('units with <comparator> <quantity> <weapon>', vocabulary);
  assert.equal(blanks.error, null);
  assert.equal(blanks.tokens.find(found => found.role === 'slot').slot, 'comparator');
});

test('each blank offers what can go there', () => {
  const slot = (query, name) => alternatives(analyze(query, vocabulary).tokens.find(found => found.slot === name), vocabulary);
  const query = '<weight class> <unit> with <comparator> <quantity> <weapon> <and/or> <comparator> <quantity> <weapon>';
  assert.deepEqual(texts(slot(query, 'weight class')), [...vocabulary.weightClasses, '']);
  assert.deepEqual(texts(slot(query, 'unit')), ['units', 'mechs', 'tanks', 'tracked']);
  assert.deepEqual(texts(slot(query, 'and/or')), ['and', 'or']);
  assert.deepEqual(texts(slot(query, 'comparator')), vocabulary.comparatorsBefore);
  assert.deepEqual(texts(slot(query, 'weapon')), ['lrms', 'mrms', 'streaks', 'lasers']);
});

test('blanks left empty become their defaults', () => {
  assert.equal(fillSlots('<weight class> <unit> with <comparator> <quantity> <weapon>'), 'units with at least 1 lasers');
  assert.equal(fillSlots('heavy <unit> with exactly <quantity> lrms <and/or> <comparator> 2 <weapon>'),
      'heavy units with exactly 1 lrms and at least 2 lasers');
  assert.equal(fillSlots('mechs with 1 ppc'), 'mechs with 1 ppc');
});

test('no two tokens share a character', () => {
  for (const query of ["mechs with at least 2 ppc's", "mechs with 2 clan artemis lrm 20's and 1 ppc", 'mechs with 2 ppc with',
    'light mechs with at least 2 lrm 20', 'units with <comparator> 2 <weapon> <and/or> 1 ppc', 'mechs with 1 lrm#20']) {
    const tokens = analyze(query, vocabulary).tokens;
    tokens.slice(1).forEach((token, index) => assert.ok(token.start >= tokens[index].stop, `${query}: ${JSON.stringify(tokens)}`));
  }
});

test('positions count an emoji as two, like the editor', () => {
  const query = '😀mechs with 2 ppc';
  const mechs = token(query, 'mechs');
  assert.equal(mechs.start, 2);
  assert.deepEqual(replaceToken(query, mechs, 'tanks').text, '😀tanks with 2 ppc');
  // the emoji itself is marked whole
  assert.deepEqual(analyze(query, vocabulary).tokens[0], { start: 0, stop: 2, text: '😀', role: 'error' });
});

test('weight classes are spelled as the server reads them', () => {
  assert.deepEqual(roles('Ultra  Light mechs with 1 ppc').slice(0, 1), ['Ultra  Light:weight-class']);
  // the server doesn't know these, so they aren't colored as weight classes
  assert.deepEqual(roles('ultralight mechs with 1 ppc').slice(0, 1), ['ultralight:unknown']);
  assert.deepEqual(roles('ultra-light mechs with 1 ppc').slice(0, 1), ['ultra-light:unknown']);
});

test('adding a tech to a word split by an error keeps the rest once', () => {
  const query = "mechs with 1 medium laser's";
  const laser = token(query, 'medium laser');
  const clan = alternatives(laser, vocabulary).find(option => option.label === 'clan only');
  assert.equal(replaceToken(query, { ...laser, start: clan.start }, clan.text).text, "mechs with 1 clan medium laser's");
});
