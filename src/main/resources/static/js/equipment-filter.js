// The equipment page's filter box: hides the rows whose name, tech and terms don't all contain the
// typed words. Without JavaScript the box stays hidden and the whole list shows.
const filter = document.querySelector('.equipment-filter');
const rows = [...document.querySelectorAll('.equipment-list tbody tr')];
const texts = rows.map(row => row.textContent.toLowerCase());

filter.hidden = false;
filter.addEventListener('input', () => {
  const words = filter.value.toLowerCase().split(/\s+/).filter(Boolean);
  rows.forEach((row, i) => {
    row.hidden = !words.every(word => texts[i].includes(word));
  });
});
