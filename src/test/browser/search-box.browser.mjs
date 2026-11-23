// The search box in a real browser: autocomplete, the gray next word, the keys, and server answers that
// arrive late. Not part of ./mvnw test (it needs Chrome and the app running on the full data); run it on
// request, before a pull request that touches the search box:
//
//   BASE_URL=http://localhost:8090 npm run test:browser
//
// against an app on a throwaway database, never the dev one (see the pull-requests skill). CHROME_PATH
// overrides where Chrome is; SCREENSHOTS=<dir> saves a few screenshots. Exits 1 if any check fails.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const BASE_URL = (process.env.BASE_URL ?? 'http://localhost:8080').replace(/\/$/, '');
const CHROME = process.env.CHROME_PATH ?? {
  win32: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
  darwin: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
}[process.platform] ?? 'google-chrome';
const SCREENSHOTS = process.env.SCREENSHOTS;
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

// ---- Chrome over the DevTools protocol, with a throwaway profile

const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'search-box-chrome-'));
const chrome = spawn(CHROME, ['--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`, '--no-first-run',
  '--disable-background-networking', '--disable-sync', '--window-size=1200,900', 'about:blank'], { stdio: 'ignore' });
const portFile = path.join(profile, 'DevToolsActivePort');
for (let i = 0; i < 100 && !fs.existsSync(portFile); i++) await sleep(100);
await sleep(300);
const port = fs.readFileSync(portFile, 'utf8').split('\n')[0];
const target = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()).find(entry => entry.type === 'page');
const socket = new WebSocket(target.webSocketDebuggerUrl);
await new Promise(resolve => { socket.onopen = resolve; });
let nextId = 0;
const waiting = new Map();
const pageErrors = [];
socket.onmessage = event => {
  const message = JSON.parse(event.data);
  if (message.id) {
    waiting.get(message.id)?.(message);
    waiting.delete(message.id);
  }
  if (message.method === 'Runtime.exceptionThrown') pageErrors.push(message.params.exceptionDetails.text);
  if (message.method === 'Runtime.consoleAPICalled' && message.params.type === 'error') {
    pageErrors.push(JSON.stringify(message.params.args.map(arg => arg.value)));
  }
};
const send = (method, params = {}) => new Promise(resolve => {
  const id = ++nextId;
  waiting.set(id, resolve);
  socket.send(JSON.stringify({ id, method, params }));
});
const js = async expression => {
  const reply = await send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true });
  if (reply.result.exceptionDetails) throw new Error(`${expression} -> ${reply.result.exceptionDetails.exception?.description}`);
  return reply.result.result.value;
};
const until = async expression => {
  for (let i = 0; i < 80; i++) {
    try {
      if (await js(expression)) return true;
    } catch {
      // the page is changing
    }
    await sleep(100);
  }
  return false;
};
await send('Page.enable');
await send('Runtime.enable');

// ---- driving the search box

/** What the box shows: the query, the gray word, the open list (or the number box), focus, page. */
const state = () => js(`(${(() => {
  const ghost = document.querySelector('.query-ghost');
  const menu = document.querySelector('.query-menu');
  const field = document.querySelector('.query-input');
  return {
    text: document.querySelector('#query').value,
    field: field.textContent.replaceAll('\u00a0', ' '),
    ghost: ghost.hidden ? null : ghost.textContent,
    list: menu.hidden ? null : menu.querySelector('input') ? 'NUMBER BOX' : [...menu.querySelectorAll('li')].map(item => item.textContent.trim()),
    active: menu.hidden ? null : (menu.querySelector('[aria-selected=true]')?.textContent ?? null),
    focus: document.activeElement === field ? 'field' : document.activeElement.tagName,
    path: location.pathname + decodeURIComponent(location.search).replaceAll('+', ' '),
    said: document.querySelector('.query-announcer').textContent,
  };
}).toString()})()`);
const KEY_CODES = { Tab: 9, Enter: 13, Escape: 27, Home: 36, ArrowDown: 40 };
const press = async (key, modifiers = 0) => {
  for (const type of ['keyDown', 'keyUp']) {
    await send('Input.dispatchKeyEvent', { type, key, code: key, windowsVirtualKeyCode: KEY_CODES[key], modifiers,
      text: key === 'Enter' && type === 'keyDown' ? '\r' : undefined });
  }
  await sleep(600);
};
const type = async text => {
  for (const character of text) {
    await send('Input.insertText', { text: character });
    await sleep(15);
  }
  await sleep(700);
};
/** A new page, the mouse out of the way, the text typed into the box. */
const fresh = async text => {
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: 3, y: 600 });
  await send('Page.navigate', { url: `${BASE_URL}/` });
  await sleep(150);
  await until("location.pathname === '/' && document.readyState === 'complete' && !!document.querySelector('.query-input')");
  await sleep(500);
  await js("document.querySelector('.query-input').focus()");
  await type(text);
};
const centerOf = selector => js(`(() => { const r = document.querySelector(${JSON.stringify(selector)}).getBoundingClientRect(); return { x: r.x + r.width / 2, y: r.y + r.height / 2 }; })()`);
/** Moves the mouse onto an element, from somewhere else, so it counts as a hover. */
const hoverOver = async selector => {
  const point = await centerOf(selector);
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: point.x, y: point.y + 80 });
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', ...point });
  await sleep(400);
  return point;
};
const hoverWord = async word => {
  const found = await js(`[...document.querySelectorAll('.query-input .tok')].some(token => token.textContent === ${JSON.stringify(word)})`);
  if (!found) return null;
  await js(`[...document.querySelectorAll('.query-input .tok')].find(token => token.textContent === ${JSON.stringify(word)}).id = 'hovered-word'`);
  await hoverOver('#hovered-word');
  return (await state()).list;
};
const clickAt = async point => {
  for (const type of ['mousePressed', 'mouseReleased']) {
    await send('Input.dispatchMouseEvent', { type, ...point, button: 'left', clickCount: 1 });
  }
  await sleep(700);
};
const optionPoint = text => js(`(() => { const r = [...document.querySelectorAll('.query-menu li')].find(item => item.textContent === ${JSON.stringify(text)})?.getBoundingClientRect(); return r ? { x: r.x + 10, y: r.y + 8 } : null; })()`);
const screenshot = async name => {
  if (!SCREENSHOTS) return;
  fs.mkdirSync(SCREENSHOTS, { recursive: true });
  const reply = await send('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(path.join(SCREENSHOTS, name), Buffer.from(reply.result.data, 'base64'));
};

let failures = 0;
let passes = 0;
const check = (name, ok, details) => {
  if (ok) {
    passes++;
    console.log(`ok   ${name}`);
  } else {
    failures++;
    console.log(`FAIL ${name}\n     ${JSON.stringify(details)}`);
  }
};
// whether an open list (a state's, or a list itself) holds that option
const lists = (s, option) => {
  const list = Array.isArray(s) ? s : s?.list;
  return Array.isArray(list) && list.includes(option);
};
const notSearched = s => s.path === '/';

// ---- the checks

try {
  let s;

  console.log('# completions as you type, and the Tab chain');
  await fresh('hea'); s = await state();
  check('"hea" lists heavy first, nothing chosen', s.list?.[0] === 'heavy' && s.ghost === null && s.active === null, s);
  await screenshot('list.png');
  await press('Tab'); s = await state();
  check('Tab takes heavy', s.text === 'heavy ' && s.ghost === 'units' && notSearched(s), s);
  await press('Tab'); s = await state();
  check('Tab takes units', s.text === 'heavy units ' && s.ghost === 'with', s);
  await press('Tab'); s = await state();
  check('Tab takes with', s.text === 'heavy units with ' && s.ghost === 'at least 1', s);
  await press('Tab'); s = await state();
  check('Tab takes at least 1', s.text === 'heavy units with at least 1 ' && s.ghost === 'weapon', s);
  await press('Tab'); s = await state();
  check('Tab on "weapon" opens the weapons', lists(s, 'lasers') && s.active !== null, s);
  const weapon = s.active;
  await press('Tab'); s = await state();
  check('Tab takes the weapon without searching', s.text === `heavy units with at least 1 ${weapon} ` && s.ghost === 'and' && notSearched(s), s);
  await press('Enter'); await sleep(800); s = await state();
  check('Enter searches without the gray word', s.path.startsWith('/search') && !/ and *$/.test(s.path), s);

  console.log('# the gray next word');
  for (const [typed, gray] of [['clan ', 'units'], ['omni ', 'units'], ['mechs ', 'with'], ['mechs with ', 'at least 1'],
    ['mechs with at least ', '1'], ['mechs with 2 ', 'weapon'], ['mechs with 2 ppc ', 'and'], ['mechs with 2 lrm 20 ', 'and']]) {
    await fresh(typed); s = await state();
    check(`"${typed}" shows ${gray}`, s.ghost === gray && s.field === typed && (s.list === null || s.list[0] === 'and'), s);
  }
  await fresh('heavy '); await screenshot('gray-word.png');
  await fresh('mechs with 2 medium '); s = await state();
  check('an unfinished name lists, no gray word', s.ghost === null && lists(s, 'medium laser'), s);
  await fresh('heavy me'); s = await state();
  check('"heavy me" lists mechs and heavy medium laser', s.list?.[0] === 'mechs' && lists(s, 'heavy medium laser'), s);
  await press('ArrowDown'); await press('ArrowDown'); await press('Enter'); s = await state();
  check('Enter on an arrowed option replaces from its own start', s.text === 'heavy medium laser ' && notSearched(s), s);
  await fresh('heavy me'); await press('Enter'); await sleep(800); s = await state();
  check('plain Enter searches what was typed', s.path.includes('query=heavy me'), s);
  await fresh(''); s = await state();
  check('an empty box shows nothing', s.ghost === null && s.list === null, s);

  console.log('# hover and click');
  await fresh('heavy '); await hoverOver('.query-ghost'); s = await state();
  check('hovering the gray word lists the units', lists(s, 'mechs') && lists(s, 'tanks') && s.text === 'heavy ', s);
  await screenshot('gray-word-list.png');
  const mechs = await optionPoint('mechs');
  if (mechs) { await send('Input.dispatchMouseEvent', { type: 'mouseMoved', ...mechs }); await sleep(200); await clickAt(mechs); }
  s = await state();
  check('clicking in its list takes it and goes on', s.text === 'heavy mechs ' && s.ghost === 'with' && notSearched(s), s);
  await fresh('heavy '); await clickAt(await hoverOver('.query-ghost')); s = await state();
  check('clicking the gray word takes it', s.text === 'heavy units ', s);
  await fresh('heavy '); await hoverOver('.query-ghost'); await press('Tab'); s = await state();
  check('Tab while its list is open takes the gray word', s.text === 'heavy units ', s);
  await fresh('mechs with at least '); await hoverOver('.query-ghost'); s = await state();
  check('hovering the gray number opens the number box', s.list === 'NUMBER BOX', s);
  await js("document.querySelector('.query-menu input')?.focus()"); await send('Input.insertText', { text: '3' }); await press('Enter'); s = await state();
  check('the number box starts empty, and its number goes on', s.text === 'mechs with at least 3 ' && notSearched(s), s);
  await fresh('mechs with 2 ppc '); await hoverOver('.query-ghost'); s = await state();
  check('hovering the gray and lists and / or', lists(s, 'or') && lists(s, 'and'), s);

  console.log('# leaving the box');
  await fresh('heavy '); await press('Escape'); s = await state();
  check('Escape puts the gray word away', s.ghost === null && s.text === 'heavy ', s);
  await press('Tab'); s = await state();
  check('then Tab leaves the box', s.focus !== 'field' && s.text === 'heavy ', s);
  await fresh('heavy '); await press('Tab', 8); s = await state();
  check('Shift+Tab leaves the box', s.focus !== 'field' && s.text === 'heavy ' && s.ghost === null, s);
  await fresh('hea'); await press('Escape'); s = await state();
  check('Escape closes the list', s.list === null && s.text === 'hea', s);
  await type('v'); s = await state();
  check('typing brings it back', lists(s, 'heavy'), s);
  await fresh('heavy mechs ');
  await js("(() => { const range = document.createRange(); range.setStart(document.querySelector('.query-input .tok').firstChild, 2); range.collapse(true); getSelection().removeAllRanges(); getSelection().addRange(range); })()");
  await sleep(300); s = await state();
  check('no gray word with the caret elsewhere', s.ghost === null, s);
  await fresh('heavy '); await js("document.querySelector('.query-input').blur()"); s = await state();
  check('leaving the box hides everything', s.ghost === null && s.list === null, s);
  await fresh('mechs with 2 med'); s = await state();
  check('(a list is open)', lists(s, 'medium laser'), s);
  await press('Home'); s = await state();
  check('moving the caret closes the list', s.list === null && s.text === 'mechs with 2 med', s);
  await press('Tab'); s = await state();
  check('so Tab then leaves the box, the query as it was', s.text === 'mechs with 2 med' && s.focus !== 'field', s);
  await fresh('mechs with 2 med'); await press('ArrowDown'); await sleep(1500); s = await state();
  check('arrowing in the list keeps it open', s.list !== null && s.active !== null, s);

  console.log('# a whole search');
  await fresh('mechs with 2 ppc'); s = await state();
  check('a whole search still lists longer names', lists(s, 'ppc capacitor'), s);
  await press('Tab'); s = await state();
  check('Tab leaves it as it is', s.text === 'mechs with 2 ppc' && s.focus !== 'field' && s.list === null, s);
  await fresh('mechs with 2 ppc'); await press('ArrowDown'); const arrowed = (await state()).active; await press('Tab'); s = await state();
  check('Tab takes an option once arrowed to', s.text === `mechs with 2 ${arrowed} `, s);
  await fresh('mechs with 2 ppc '); await press('Tab'); await press('Tab'); s = await state();
  check('then and, at least 1', s.text === 'mechs with 2 ppc and at least 1 ' && s.ghost === 'weapon', s);
  await type('medi'); s = await state();
  check('typing a second term lists it', lists(s, 'medium laser'), s);

  console.log('# a group name and a space: and, then its longer names');
  await fresh('mechs with 2 lrm '); s = await state();
  check('gray and; the list starts with and, then the sizes', s.ghost === 'and' && s.list?.[0] === 'and' && lists(s, 'lrm 20') && s.active === null, s);
  check('sizes in order', JSON.stringify(s.list.filter(option => /^lrm \d+$/.test(option))) === JSON.stringify(['lrm 5', 'lrm 10', 'lrm 15', 'lrm 20']), s.list);
  await screenshot('group-sizes.png');
  await press('Tab'); s = await state();
  check('Tab takes and', s.text === 'mechs with 2 lrm and ' && s.ghost === 'at least 1', s);
  await fresh('mechs with 2 lrm '); await press('ArrowDown'); s = await state();
  check('the first arrow is on and', s.active === 'and', s);
  await press('Enter'); s = await state();
  check('Enter on it takes and', s.text === 'mechs with 2 lrm and ' && notSearched(s), s);
  await fresh('mechs with 2 lrm '); const lrm10 = await optionPoint('lrm 10');
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', ...lrm10 }); await sleep(200); await clickAt(lrm10); s = await state();
  check('clicking a size takes it', s.text === 'mechs with 2 lrm 10 ', s);
  await fresh('mechs with 2 lrm '); await press('Escape'); s = await state();
  check('Escape puts both away', s.ghost === null && s.list === null, s);
  await fresh('mechs with 2 lrm '); await press('Enter'); await sleep(800); s = await state();
  check('Enter searches 2 lrm', s.path.includes('query=mechs with 2 lrm') && !/ and *$/.test(s.path), s);
  await fresh('clan '); s = await state();
  check('"clan " shows units alone (not a whole search)', s.ghost === 'units' && s.list === null, s);

  console.log('# late and stale answers');
  await fresh(''); for (const character of 'mechs with at least ') await send('Input.insertText', { text: character });
  await sleep(60); await hoverOver('.query-ghost'); await js("document.querySelector('.query-menu input')?.focus()");
  await send('Input.insertText', { text: '7' }); await sleep(1500); s = await state();
  check('the number box survives a late spelling answer', s.list === 'NUMBER BOX', s);
  await fresh(''); for (const character of 'mechs with ') await send('Input.insertText', { text: character });
  await sleep(60); await hoverOver('.query-ghost'); const before = JSON.stringify((await state()).list); await sleep(1500); s = await state();
  check("the gray word's list survives one", JSON.stringify(s.list) === before && s.list !== null, s);
  await fresh('hea'); await press('ArrowDown'); await sleep(1500); s = await state();
  check('the list and its choice survive one', s.active === 'heavy', s);
  await fresh(''); for (const character of 'hea') await send('Input.insertText', { text: character });
  await sleep(160); await send('Input.insertText', { text: 'vy mechs ' }); await sleep(900); s = await state();
  check('an answer for older text opens nothing', s.list === null && s.ghost === 'with', s);
  await fresh(''); await send('Input.insertText', { text: 'hea' }); await js("document.querySelector('.query-input').blur()"); await sleep(700); s = await state();
  check('an answer after leaving opens nothing', s.list === null && s.ghost === null, s);
  // hovering a word before the answer comes: its swaps stay (Sonnet and Codex reviews of PR #31)
  await fresh(''); for (const character of 'mechs with 2 me') await send('Input.insertText', { text: character });
  const swapsBefore = await hoverWord('mechs'); await sleep(1500); s = await state();
  check("a late answer leaves a word's swaps open", Array.isArray(swapsBefore) && lists(swapsBefore, 'tanks') && lists(s, 'tanks') && !lists(s, 'medical'), { swapsBefore, s });
  await fresh(''); for (const character of 'mechs with 2 med') await send('Input.insertText', { text: character });
  await hoverWord('2'); await sleep(1500); s = await state();
  check('a late answer leaves the number box open', s.list === 'NUMBER BOX', s);
  // pasting asks too
  await fresh('');
  await js("(() => { const data = new DataTransfer(); data.setData('text/plain', 'hea'); document.querySelector('.query-input').dispatchEvent(new ClipboardEvent('paste', { clipboardData: data, bubbles: true, cancelable: true })); })()");
  await sleep(700); s = await state();
  check('pasting asks for completions', s.text === 'hea' && lists(s, 'heavy'), s);
  await fresh('');
  const inBox = await js("(() => { const r = document.querySelector('.query-input').getBoundingClientRect(); return { x: r.x + 25, y: r.y + r.height / 2 }; })()");
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', ...inBox }); await type('heavy me'); s = await state();
  check('a still mouse over the box leaves the list alone', s.list?.[0] === 'mechs', s);

  console.log('# odd input');
  await fresh('\u{1F600} hea'); s = await state();
  check('an emoji keeps the offsets', s.field === '\u{1F600} hea' && lists(s, 'heavy'), s);
  await fresh('<img src=x onerror=1> hea');
  check('markup stays text', await js("document.querySelectorAll('.query-editor img').length") === 0, null);
  await fresh('heavy'); await send('Input.imeSetComposition', { text: 'me', selectionStart: 2, selectionEnd: 2 }); await sleep(500); s = await state();
  check('nothing while an IME is composing', s.list === null && s.ghost === null, s);
  await send('Input.imeSetComposition', { text: '', selectionStart: 0, selectionEnd: 0 });

  console.log('# what was there before');
  await fresh('heavy mechs'); await press('Escape'); const swaps = await hoverWord('heavy');
  check('hovering a word still offers swaps', Array.isArray(swaps) && swaps.includes('light'), swaps);
  await fresh('mehcs with 2 ppc'); await sleep(900);
  check('misspellings are still underlined', await js("!!document.querySelector('.tok-misspelled')"), null);
  await fresh(''); await js("document.querySelector('.query-templates button[data-template=unit]').click()"); await sleep(700); s = await state();
  check('template blanks: their own list, no gray word', lists(s, 'light') && s.ghost === null, s);

  console.log('# phone width');
  await send('Emulation.setDeviceMetricsOverride', { width: 360, height: 700, deviceScaleFactor: 2, mobile: true });
  await fresh('clan heavy mechs with at least 2 ');
  check('no sideways scroll', await js('document.documentElement.scrollWidth <= innerWidth'), null);
  await screenshot('phone.png');
  await send('Emulation.clearDeviceMetricsOverride');

  check('no script errors on the page', pageErrors.length === 0, pageErrors);
} catch (error) {
  failures++;
  console.log(`FAIL the run stopped: ${error.stack}`);
} finally {
  await send('Browser.close').catch(() => {});
  await sleep(800);
  chrome.kill();
  try {
    fs.rmSync(profile, { recursive: true, force: true, maxRetries: 5, retryDelay: 300 });
  } catch {
    // Chrome still holds a file; the system cleans its temp folder
  }
}
console.log(`\n${passes} passed, ${failures} failed`);
process.exit(failures === 0 ? 0 : 1);
