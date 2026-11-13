// What the equipment page's filter box matches each row by (no DOM, so the tests can run it).

export const wordsOf = text => text.toLowerCase().split(/[\s,()[\]]+/).filter(Boolean);

// Each row's words: its own text, plus the terms of the groups above every row of the same item. An
// item in several groups is shown once under each, so a copy under ecm still matches "ecm probes".
// rows: [{ name, text, groups: [term, ...] }]
export function rowWords(rows) {
  const groupsByName = new Map();
  for (const row of rows) {
    const groups = groupsByName.get(row.name) ?? new Set();
    row.groups.forEach(group => groups.add(group));
    groupsByName.set(row.name, groups);
  }
  return rows.map(row => wordsOf(`${row.text} ${[...groupsByName.get(row.name)].join(' ')}`));
}

// word starts, so "er" finds ER lasers and not every "lasers"
export const matches = (typed, words) => typed.every(word => words.some(rowWord => rowWord.startsWith(word)));
