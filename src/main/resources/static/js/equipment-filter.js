// The equipment page's filter box: hides the rows where some typed word doesn't start a word of the
// row's name, tech, terms or groups, and the groups left with nothing; a group with a match opens.
// Without JavaScript the box stays hidden and the whole list shows.
const filter = document.querySelector('.equipment-filter');
const groups = [...document.querySelectorAll('.equipment-list details.equipment-group')];
const rows = [...document.querySelectorAll('.equipment-list tbody tr')];
const wordsOf = text => text.toLowerCase().split(/[\s,()[\]]+/).filter(Boolean);
// a row matches the terms of the groups it's under too, so "lrms" keeps every LRM
const rowWords = rows.map(row => {
  const terms = [];
  for (let group = row.closest('details'); group; group = group.parentElement.closest('details')) {
    terms.push(group.dataset.group);
  }
  return wordsOf(`${row.textContent} ${terms.join(' ')}`);
});
// how the page opened them, for when the box is cleared
const opened = groups.map(group => group.open);

filter.hidden = false;
filter.addEventListener('input', () => {
  // word starts, so "er" finds ER lasers and not every "lasers"
  const typed = wordsOf(filter.value);
  rows.forEach((row, i) => {
    row.hidden = !typed.every(word => rowWords[i].some(rowWord => rowWord.startsWith(word)));
  });
  groups.forEach((group, i) => {
    if (typed.length === 0) {
      group.hidden = false;
      group.open = opened[i];
      return;
    }
    const matches = [...group.querySelectorAll('tbody tr')].some(row => !row.hidden);
    group.hidden = !matches;
    group.open = matches;
  });
});
