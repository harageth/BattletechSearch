// The equipment page's filter box: what each row matches by.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { wordsOf, rowWords, matches } from '../../../target/classes/static/js/equipment-words.js';

// the Nova CEWS is shown once under each of its groups, as the guide's tree renders it
const rows = [
  { name: 'Nova CEWS', text: 'Nova CEWS Inner Sphere', groups: ['ecm'] },
  { name: 'Nova CEWS', text: 'Nova CEWS Inner Sphere', groups: ['probes'] },
  { name: 'Nova CEWS', text: 'Nova CEWS Inner Sphere', groups: ['c3i', 'c3'] },
  { name: 'Guardian ECM Suite', text: 'Guardian ECM Suite Inner Sphere', groups: ['ecm'] },
];

test('every copy of an item matches all of its groups', () => {
  const words = rowWords(rows);
  const typed = wordsOf('ecm probes');
  assert.deepEqual(words.map(rowWords => matches(typed, rowWords)), [true, true, true, false]);
  assert.ok(matches(wordsOf('nova c3i'), words[0]));
});

test('typed words match word starts', () => {
  const words = rowWords(rows);
  assert.ok(matches(wordsOf('guard'), words[3]));
  assert.ok(!matches(wordsOf('ard'), words[3]));
  assert.ok(matches([], words[3]));
});
