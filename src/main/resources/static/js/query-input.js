// The search box: colors each word of the query as you type, and hovering (or tapping) a word
// opens a list of words to swap it for (for a number, a box to type one in). Replaces each <input data-query-input> with an editable
// field and keeps the input, now hidden, in step, so the form submits exactly as before. Without
// JavaScript the plain input still works.
//
// The "+ unit" / "+ weapon" buttons add a section of blanks ("<comparator> <quantity> <weapon>"). Each
// blank's list opens in turn, and the search runs once the last is filled. Escape, or searching early,
// leaves the rest as their defaults.
import { analyze, alternatives, isQuantity, quantityText, replaceToken, templates, addTemplate, fillSlots, EMPTY_VOCABULARY } from './query-analysis.js';

let vocabulary = EMPTY_VOCABULARY;
const editors = [];

fetch('/api/vocabulary')
  .then(response => (response.ok ? response.json() : null))
  .then(loaded => {
    if (loaded) {
      vocabulary = loaded;
      editors.forEach(editor => editor.render());
    }
  })
  // without the word lists the query is still colored, there's just nothing to offer
  .catch(() => {});

class QueryEditor {
  constructor(input) {
    this.input = input;
    this.tokens = [];
    this.menuToken = null;
    this.active = -1;

    this.wrapper = document.createElement('div');
    this.wrapper.className = 'query-editor';
    this.field = document.createElement('div');
    this.field.className = 'query-input';
    this.field.contentEditable = 'true';
    this.field.spellcheck = false;
    this.field.setAttribute('role', 'textbox');
    this.field.setAttribute('aria-label', input.getAttribute('aria-label') || 'Search query');
    this.field.setAttribute('aria-haspopup', 'listbox');
    this.field.setAttribute('autocapitalize', 'off');
    this.field.dataset.placeholder = input.placeholder || '';
    this.menu = document.createElement('ul');
    this.menu.className = 'query-menu';
    this.menu.id = `${input.id || 'query'}-alternatives`;
    this.menu.setAttribute('role', 'listbox');
    this.menu.hidden = true;
    this.field.setAttribute('aria-controls', this.menu.id);

    this.templateButtons = document.createElement('div');
    this.templateButtons.className = 'query-templates';
    this.templateButtons.append(...Object.entries({ unit: '+ unit', weapon: '+ weapon' }).map(([name, label]) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.dataset.template = name;
      button.textContent = label;
      return button;
    }));

    input.type = 'hidden';
    input.after(this.wrapper);
    this.wrapper.append(this.field, this.menu, this.templateButtons);
    this.addThemeSwitch();
    this.listen();
    this.render();
  }

  /**
   * A "Dark mode" checkbox under the form, for the whole page (theme-dark on <html>). The choice is
   * remembered in this browser; a script in the page head applies it before the page is drawn.
   */
  addThemeSwitch() {
    const label = document.createElement('label');
    label.className = 'query-theme';
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.checked = document.documentElement.classList.contains('theme-dark');
    label.append(checkbox, ' Dark mode');
    checkbox.addEventListener('change', () => {
      document.documentElement.classList.toggle('theme-dark', checkbox.checked);
      writeSetting(THEME_KEY, checkbox.checked ? 'dark' : 'light');
    });
    (this.input.form ?? this.wrapper).append(label);
  }

  get text() {
    return this.input.value;
  }

  listen() {
    const field = this.field;
    field.addEventListener('beforeinput', event => {
      // one line of plain text: no line breaks or bold
      if (event.inputType.startsWith('format') || event.inputType === 'insertParagraph'
          || event.inputType === 'insertLineBreak') {
        event.preventDefault();
      } else if (!event.isComposing) {
        this.typeOverSlot(event);
      }
    });
    field.addEventListener('input', event => {
      if (!event.isComposing) {
        this.changed();
      }
    });
    field.addEventListener('compositionend', () => this.changed());
    field.addEventListener('paste', event => {
      event.preventDefault();
      this.insert(event.clipboardData.getData('text/plain'));
    });
    field.addEventListener('drop', event => event.preventDefault());
    field.addEventListener('keydown', event => this.keydown(event));
    field.addEventListener('blur', event => {
      // not when the focus goes to the number box
      if (!this.menu.contains(event.relatedTarget)) {
        this.closeMenu();
      }
    });

    // hover a word, or tap it, for its alternatives
    field.addEventListener('mouseover', event => {
      const span = event.target.closest?.('.tok');
      // the mouse passing over the query doesn't take away a number box being typed in
      if (span && !this.menu.contains(document.activeElement)) {
        this.openMenu(Number(span.dataset.index), span);
      }
    });
    field.addEventListener('click', event => {
      const span = event.target.closest?.('.tok');
      if (span) {
        this.openMenu(Number(span.dataset.index), span);
      }
    });
    this.wrapper.addEventListener('mouseleave', () => {
      // a number box being typed in stays open
      if (!this.menu.contains(document.activeElement)) {
        this.closeMenu();
      }
    });
    // keep the focus (and caret) in the field while picking, except for clicking into the number box
    this.menu.addEventListener('mousedown', event => {
      if (event.target.tagName !== 'INPUT') {
        event.preventDefault();
      }
    });
    this.menu.addEventListener('click', event => {
      const item = event.target.closest('li');
      if (item) {
        this.pick(Number(item.dataset.index));
      }
    });
    this.templateButtons.addEventListener('mousedown', event => event.preventDefault());
    this.templateButtons.addEventListener('click', event => {
      const button = event.target.closest('button');
      if (button) {
        this.addTemplate(button.dataset.template);
      }
    });
    // blanks nobody filled in search as their defaults
    this.input.form?.addEventListener('submit', () => {
      this.input.value = fillSlots(this.text);
    });
  }

  /** Adds a section of blanks to the end and opens the first blank's list. */
  addTemplate(name) {
    this.input.value = addTemplate(this.text, name);
    this.closeMenu();
    this.field.focus();
    this.render(this.text.length);
    this.nextSlot();
  }

  /** Opens the list for the first blank left, with the caret inside it; false if there are none. */
  nextSlot() {
    const index = this.tokens.findIndex(token => token.role === 'slot');
    if (index < 0) {
      return false;
    }
    // inside the blank, so typing replaces it (typeOverSlot)
    setCaret(this.field, this.tokens[index].start + 1);
    this.openMenu(index, this.field.querySelector(`.tok[data-index="${index}"]`));
    this.enterMenu();
    return true;
  }

  /** The keyboard way into an open menu: the first option, or the number box. */
  enterMenu() {
    if (this.menu.hidden) {
      return;
    }
    const box = this.menu.querySelector('input');
    if (box) {
      box.focus();
    } else {
      this.highlight(0);
    }
  }

  /** Done filling in: the blanks left keep their defaults, and it searches. */
  finishSlots() {
    this.input.value = fillSlots(this.text);
    this.closeMenu();
    this.field.focus();
    this.render(this.text.length);
    this.input.form?.requestSubmit();
  }

  /** A blank is one piece: typing in it replaces it, deleting next to it removes it. */
  typeOverSlot(event) {
    const [start, stop] = selectionOffsets(this.field) ?? [];
    if (start === undefined || start !== stop) {
      return;
    }
    const slot = this.tokens.find(token => token.role === 'slot' && (
      event.inputType === 'insertText' ? token.start < start && start < token.stop
        : event.inputType === 'deleteContentBackward' ? token.start < start && start <= token.stop
          : event.inputType === 'deleteContentForward' ? token.start <= start && start < token.stop
            : false));
    if (!slot) {
      return;
    }
    event.preventDefault();
    const replaced = replaceToken(this.text, slot, event.inputType === 'insertText' ? event.data ?? '' : '');
    this.input.value = replaced.text;
    this.closeMenu();
    this.render(replaced.caret);
  }

  hasSlots() {
    return this.tokens.some(token => token.role === 'slot');
  }

  /** Reads what was typed, then colors it again. */
  changed() {
    const caret = caretOffset(this.field);
    this.input.value = readText(this.field);
    this.closeMenu();
    this.render(caret);
  }

  insert(typed) {
    const [start, stop] = selectionOffsets(this.field) ?? [this.text.length, this.text.length];
    const clean = typed.replace(/\s+/g, ' ');
    this.input.value = this.text.slice(0, start) + clean + this.text.slice(stop);
    this.render(start + clean.length);
  }

  /** Redraws the field as colored words; puts the caret back at that offset if given. */
  render(caret = null) {
    const text = this.text;
    const { tokens, error } = analyze(text, vocabulary);
    this.tokens = tokens;
    const parts = [];
    let at = 0;
    tokens.forEach((token, index) => {
      if (token.start > at) {
        parts.push(text.slice(at, token.start));
      }
      const span = document.createElement('span');
      span.className = `tok tok-${token.role}`;
      if (isQuantity(token) || alternatives(token, vocabulary).length > 0) {
        span.classList.add('tok-swappable');
      }
      span.dataset.index = String(index);
      span.textContent = text.slice(token.start, token.stop);
      parts.push(span);
      at = token.stop;
    });
    if (at < text.length) {
      parts.push(text.slice(at));
    }
    this.field.replaceChildren(...parts);
    const available = templates(text);
    [...this.templateButtons.children].forEach(button => {
      button.hidden = !available.includes(button.dataset.template);
    });
    // an incomplete query isn't wrong yet while you're still typing it, so only say so on hover
    this.field.title = error && text.trim() !== '' ? 'Not a complete search yet' : '';
    if (caret !== null && document.activeElement === this.field) {
      setCaret(this.field, caret);
    }
  }

  keydown(event) {
    const open = !this.menu.hidden;
    if (event.key === 'Enter') {
      event.preventDefault();
      if (open && this.active >= 0) {
        this.pick(this.active);
      } else {
        this.input.form?.requestSubmit();
      }
    } else if (event.key === 'Escape' && this.hasSlots()) {
      event.preventDefault();
      this.finishSlots();
    } else if (event.key === 'Escape' && open) {
      event.preventDefault();
      this.closeMenu();
    } else if ((event.key === 'ArrowDown' || event.key === 'ArrowUp') && open && this.options.length > 0) {
      event.preventDefault();
      const count = this.menu.children.length;
      this.highlight((this.active + (event.key === 'ArrowDown' ? 1 : count - 1)) % count);
    } else if (event.key === 'ArrowDown' && event.altKey) {
      // the keyboard way in: the alternatives for the word at the caret
      event.preventDefault();
      const caret = caretOffset(this.field);
      const index = this.tokens.findIndex(token => token.start <= caret && caret <= token.stop);
      if (index >= 0) {
        this.openMenu(index, this.field.querySelector(`.tok[data-index="${index}"]`));
        this.enterMenu();
      }
    }
  }

  openMenu(index, span) {
    const token = this.tokens[index];
    if (token && span && isQuantity(token)) {
      this.openNumberBox(token, span);
      return;
    }
    const options = token ? alternatives(token, vocabulary) : [];
    if (options.length === 0 || !span) {
      this.closeMenu();
      return;
    }
    if (this.menuToken === token && !this.menu.hidden) {
      return;
    }
    this.menuToken = token;
    this.options = options;
    this.active = -1;
    this.menu.setAttribute('role', 'listbox');
    this.menu.replaceChildren(...options.map((option, optionIndex) => {
      const item = document.createElement('li');
      item.id = `${this.menu.id}-${optionIndex}`;
      item.setAttribute('role', 'option');
      item.dataset.index = String(optionIndex);
      item.textContent = option.label;
      if (option.text === '') {
        item.classList.add('query-menu-remove');
      }
      return item;
    }));
    this.showMenu(span);
  }

  /** For a number: a box to type it in, Enter to use it. */
  openNumberBox(token, span) {
    if (this.menuToken === token && !this.menu.hidden) {
      return;
    }
    this.menuToken = token;
    this.options = [];
    this.active = -1;
    this.menu.setAttribute('role', 'group');
    const item = document.createElement('li');
    item.className = 'query-menu-number';
    const label = document.createElement('label');
    const box = document.createElement('input');
    box.type = 'number';
    box.min = '0';
    box.max = '999';
    box.inputMode = 'numeric';
    box.placeholder = '1';
    // a number typed as digits starts in the box; "two" or a blank starts empty
    box.value = quantityText(token.text) ?? '';
    label.append('How many? ', box);
    item.append(label);
    box.addEventListener('keydown', event => {
      if (event.key === 'Enter') {
        // not the form's Enter: the box is inside it
        event.preventDefault();
        const number = quantityText(box.value);
        if (number === null) {
          box.setAttribute('aria-invalid', 'true');
        } else {
          this.choose(this.menuToken, number);
        }
      } else if (event.key === 'Escape') {
        event.preventDefault();
        if (this.hasSlots()) {
          this.finishSlots();
        } else {
          this.closeMenu();
          this.field.focus();
        }
      }
    });
    box.addEventListener('input', () => box.removeAttribute('aria-invalid'));
    box.addEventListener('blur', event => {
      // not when another menu replaced this one, or the focus went back to the field
      if (item.isConnected && event.relatedTarget !== this.field) {
        this.closeMenu();
      }
    });
    this.menu.replaceChildren(item);
    this.showMenu(span);
  }

  showMenu(span) {
    this.menu.style.left = `${span.offsetLeft}px`;
    this.menu.style.top = `${span.offsetTop + span.offsetHeight}px`;
    this.menu.hidden = false;
    this.field.setAttribute('aria-expanded', 'true');
  }

  highlight(index) {
    this.active = index;
    [...this.menu.children].forEach((item, itemIndex) => item.setAttribute('aria-selected', String(itemIndex === index)));
    const item = this.menu.children[index];
    if (item) {
      item.scrollIntoView({ block: 'nearest' });
      this.field.setAttribute('aria-activedescendant', item.id);
    }
  }

  pick(index) {
    const option = this.options?.[index];
    if (!option || !this.menuToken) {
      return;
    }
    // "clan only" replaces the whole equipment name, from in front of its fire control
    this.choose(option.start === undefined ? this.menuToken : { ...this.menuToken, start: option.start }, option.text);
  }

  /** Puts the replacement over that part of the query, then fills the next blank or searches. */
  choose(range, replacement) {
    const { text, caret } = replaceToken(this.text, range, replacement);
    this.input.value = text;
    this.closeMenu();
    this.field.focus();
    this.render(caret);
    // on to the next blank; once there are none, every swap searches right away
    if (!this.nextSlot()) {
      this.input.form?.requestSubmit();
    }
  }

  closeMenu() {
    this.menu.hidden = true;
    this.menuToken = null;
    this.active = -1;
    this.field.setAttribute('aria-expanded', 'false');
    this.field.removeAttribute('aria-activedescendant');
  }
}

// also read by the script in templates/fragments/search-form.html
const THEME_KEY = 'battletech-search.theme';

// storage can be missing or blocked (private windows); the setting is only a convenience
function writeSetting(name, value) {
  try {
    window.localStorage.setItem(name, value);
  } catch {
    // not remembered, still applied
  }
}

/** The field's text, one line, with the non-breaking spaces browsers type turned back into spaces. */
function readText(field) {
  return field.textContent.replace(/ /g, ' ').replace(/[\r\n]/g, ' ');
}

/** The caret's character offset into the field, or null if it isn't in it. */
function caretOffset(field) {
  return selectionOffsets(field)?.[1] ?? null;
}

function selectionOffsets(field) {
  const selection = window.getSelection();
  if (!selection || selection.rangeCount === 0) {
    return null;
  }
  const range = selection.getRangeAt(0);
  if (!field.contains(range.startContainer) || !field.contains(range.endContainer)) {
    return null;
  }
  const offset = (container, at) => {
    const before = document.createRange();
    before.selectNodeContents(field);
    before.setEnd(container, at);
    return before.toString().length;
  };
  return [offset(range.startContainer, range.startOffset), offset(range.endContainer, range.endOffset)];
}

function setCaret(field, offset) {
  const walker = document.createTreeWalker(field, NodeFilter.SHOW_TEXT);
  const range = document.createRange();
  let remaining = offset;
  let node;
  let placed = false;
  while ((node = walker.nextNode())) {
    if (remaining <= node.length) {
      range.setStart(node, remaining);
      placed = true;
      break;
    }
    remaining -= node.length;
  }
  if (!placed) {
    range.selectNodeContents(field);
    range.collapse(false);
  }
  range.collapse(true);
  const selection = window.getSelection();
  selection.removeAllRanges();
  selection.addRange(range);
}

document.querySelectorAll('input[data-query-input]').forEach(input => editors.push(new QueryEditor(input)));
