// The search box: colors each word of the query as you type, and hovering (or tapping) a word
// opens a list of words to swap it for (for a number, a box to type one in). Replaces each <input data-query-input> with an editable
// field and keeps the input, now hidden, in step, so the form submits exactly as before. Without
// JavaScript the plain input still works.
//
// The "+ unit" / "+ weapon" buttons add a section of blanks ("<comparator> <quantity> <weapon>"). Each
// blank's list opens in turn, and the search runs once the last is filled. Escape, or searching early,
// leaves the rest as their defaults.
//
// As you type, /api/completions (autocomplete, on the server) lists what the word may become, and after a space
// the next word shows in gray when it's known: Tab or a click takes either, and hovering the gray word opens its
// list. Neither runs the search, and the gray word is never part of the query.
//
// When you stop typing, a query that doesn't parse is sent to /api/suggestions (autocorrect, on the
// server): a word it has spellings for is underlined, and its list offers them first.
import { analyze, alternatives, suggestedAlternatives, isQuantity, quantityText, replaceToken, templates, addTemplate, fillSlots, nextWord, nextOptions, SLOT_DEFAULTS, EMPTY_VOCABULARY, withDefaults } from './query-analysis.js';

let vocabulary = EMPTY_VOCABULARY;
const editors = [];
// how long typing has to stop before asking for spellings
const SUGGEST_AFTER_MS = 500;
// ... and before asking what the word may become
const COMPLETE_AFTER_MS = 150;

fetch('/api/vocabulary')
  .then(response => (response.ok ? response.json() : null))
  .then(loaded => {
    if (loaded) {
      vocabulary = withDefaults(loaded);
      editors.forEach(editor => editor.refresh());
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
    this.composing = false;
    this.redrawing = false;
    // the server's spellings, for the text they were asked for
    this.suggested = { text: null, words: [] };
    this.suggestTimer = null;
    // the server's completions, for the text and caret they were asked for
    this.completed = { text: null, caret: null, options: [], complete: false };
    this.completeTimer = null;
    this.completeRequest = null;
    // the gray word shown, and the text Escape put it (and the list) away for
    this.next = null;
    this.dismissed = null;
    // which list is open: the swaps for a word, what the word typed may become, or the gray word's
    this.menuKind = 'swap';
    // where the mouse last was, and whether something was typed since it moved
    this.mouse = null;

    this.wrapper = document.createElement('div');
    this.wrapper.className = 'query-editor';
    this.field = document.createElement('div');
    this.field.className = 'query-input';
    this.field.contentEditable = 'true';
    this.field.spellcheck = false;
    this.field.setAttribute('role', 'textbox');
    this.field.setAttribute('aria-label', input.getAttribute('aria-label') || 'Search query');
    this.field.setAttribute('aria-haspopup', 'listbox');
    this.field.setAttribute('aria-autocomplete', 'list');
    this.field.setAttribute('autocapitalize', 'off');
    this.field.dataset.placeholder = input.placeholder || '';
    this.menu = document.createElement('ul');
    this.menu.className = 'query-menu';
    this.menu.id = `${input.id || 'query'}-alternatives`;
    this.menu.setAttribute('role', 'listbox');
    this.menu.hidden = true;
    this.field.setAttribute('aria-controls', this.menu.id);

    // beside the field, not in it: never part of the query, the caret's offsets or what's copied
    this.ghost = document.createElement('span');
    this.ghost.className = 'query-ghost';
    this.ghost.setAttribute('aria-hidden', 'true');
    this.ghost.hidden = true;
    this.announcer = document.createElement('span');
    this.announcer.className = 'query-announcer';
    this.announcer.setAttribute('aria-live', 'polite');

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
    this.wrapper.append(this.field, this.ghost, this.menu, this.templateButtons, this.announcer);
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
    field.addEventListener('compositionstart', () => {
      this.composing = true;
      // a list or gray word for the text before it
      this.closeMenu();
      this.hideNext();
    });
    field.addEventListener('compositionend', () => {
      this.composing = false;
      this.changed();
    });
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
        this.hideNext();
      }
    });
    // the gray word is only for the end of the text
    document.addEventListener('selectionchange', () => {
      if (document.activeElement === this.field) {
        this.showNext();
      }
    });
    window.addEventListener('resize', () => this.showNext());
    this.ghost.addEventListener('mousedown', event => event.preventDefault());
    this.ghost.addEventListener('mouseenter', event => {
      if (this.mouseMoved(event)) {
        this.openNext();
      }
    });
    this.ghost.addEventListener('click', () => this.takeNext());

    // hover a word, or tap it, for its alternatives
    field.addEventListener('mouseover', event => {
      const span = event.target.closest?.('.tok');
      // the mouse passing over the query doesn't take away a number box being typed in; redrawing under a mouse
      // that isn't moving isn't hovering
      if (this.mouseMoved(event) && span && !this.menu.contains(document.activeElement)) {
        this.openMenu(Number(span.dataset.index), span);
      }
    });
    field.addEventListener('click', event => {
      const span = event.target.closest?.('.tok');
      if (span) {
        this.openMenu(Number(span.dataset.index), span);
      }
    });
    this.wrapper.addEventListener('mousemove', event => this.mouseMoved(event));
    this.wrapper.addEventListener('mouseleave', () => {
      // a number box being typed in stays open, and so does what the word being typed may become
      if (!this.menu.contains(document.activeElement) && this.menuKind !== 'complete') {
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

  // whether the mouse is somewhere else than it last was
  mouseMoved(event) {
    const moved = this.mouse === null || this.mouse.x !== event.clientX || this.mouse.y !== event.clientY;
    this.mouse = { x: event.clientX, y: event.clientY };
    return moved;
  }

  /** Reads what was typed, then colors it again. */
  changed() {
    const caret = caretOffset(this.field);
    this.input.value = readText(this.field);
    this.dismissed = null;
    this.closeMenu();
    this.render(caret);
    this.askForCompletions();
  }

  /** Once typing stops, asks the server what the word at the caret may become. Not for a template's blanks. */
  askForCompletions() {
    clearTimeout(this.completeTimer);
    this.completeRequest?.abort();
    const text = this.text;
    const caret = caretOffset(this.field);
    if (text.trim() === '' || caret === null || this.composing || this.hasSlots()) {
      return;
    }
    this.completeTimer = setTimeout(() => {
      this.completeRequest = new AbortController();
      fetch(`/api/completions?query=${encodeURIComponent(text)}&caret=${caret}`, { signal: this.completeRequest.signal })
        .then(response => (response.ok ? response.json() : null))
        .then(found => {
          // only if nothing has changed since
          if (found && this.text === text && caretOffset(this.field) === caret && !this.composing) {
            this.completed = { ...found, text, caret };
            this.showNext();
            this.openCompletions();
          }
        })
        // without them the box works as before
        .catch(() => {});
    }, COMPLETE_AFTER_MS);
  }

  /**
   * The list of what the word at the caret may become. Beside the gray word only after a whole search, with the
   * gray word first (user, 2026-11-22): "2 lrm " lists "and", then "lrm 5", "lrm 10", ...; Tab takes the first.
   * "clan " shows "units" alone.
   */
  openCompletions() {
    const { options, stop, text, complete } = this.completed;
    if (options.length === 0 || this.dismissed === text || document.activeElement !== this.field
        || (this.next && !complete) || (this.menuKind === 'next' && !this.menu.hidden)) {
      return;
    }
    // under the last of the words replaced; each option says where its own start
    const start = Math.max(...options.map(option => option.start));
    const listed = options.map(option => ({ label: option.text, text: option.text, start: option.start }));
    if (this.next?.text) {
      listed.unshift({ label: this.next.text, text: this.next.text, start: stop });
    }
    this.openList({ start, stop }, listed, rangeBox(this.field, start, stop), 'complete');
  }

  /** Shows the next word in gray at the end of the text, if it's known and the caret is there. */
  showNext() {
    // the caret isn't back yet, or the gray number's box is being typed in
    if (this.redrawing || this.menu.contains(document.activeElement)) {
      return;
    }
    const text = this.text;
    const selection = selectionOffsets(this.field);
    const atEnd = document.activeElement === this.field && selection !== null
        && selection[0] === text.length && selection[1] === text.length;
    const next = atEnd && !this.composing && this.dismissed !== text ? nextWord(text, vocabulary) : null;
    const complete = this.completed.text === text && this.completed.complete;
    if (!next || (next.needsComplete && !complete)) {
      this.hideNext();
      return;
    }
    const label = next.text ?? 'weapon';
    this.ghost.textContent = label;
    this.ghost.hidden = false;
    const end = rangeBox(this.field, text.length - 1, text.length);
    this.ghost.style.left = `${end.offsetLeft + end.offsetWidth}px`;
    this.ghost.style.top = `${end.offsetTop}px`;
    // the letters' own height, so it sits on the text's line
    this.ghost.style.lineHeight = `${end.offsetHeight}px`;
    // no room left on the line
    if (end.offsetLeft + end.offsetWidth + this.ghost.offsetWidth > this.field.clientWidth) {
      this.hideNext();
      return;
    }
    const said = next.text ? `Tab for ${label}` : 'Tab for the weapons';
    if (this.announcer.textContent !== said) {
      this.announcer.textContent = said;
    }
    this.next = next;
  }

  hideNext() {
    this.next = null;
    this.ghost.hidden = true;
    this.announcer.textContent = '';
    if (this.menuKind === 'next') {
      this.closeMenu();
    }
  }

  /** The gray word's list, or the box for a number. */
  openNext() {
    if (!this.next || (this.menuKind === 'next' && !this.menu.hidden)) {
      return;
    }
    const end = this.text.length;
    if (this.next.slot === 'quantity') {
      // an empty box with the default as its hint, like a blank's
      this.openNumberBox({ start: end, stop: end, text: '', role: 'slot', slot: 'quantity' }, this.ghost, 'next');
    } else {
      this.openList({ start: end, stop: end }, nextOptions(this.next, vocabulary), this.ghost, 'next');
    }
  }

  /** Takes the gray word; one that's only a list (the weapon) opens it. */
  takeNext() {
    if (!this.next) {
      return;
    }
    if (this.next.text === null) {
      this.openNext();
      this.enterMenu();
    } else {
      this.insertNext({ start: this.text.length, stop: this.text.length }, this.next.text);
    }
  }

  /** Puts a completion or the next word in, with a space after it at the end, and goes on from there. */
  insertNext(range, replacement) {
    const atEnd = range.stop === this.text.length;
    const { text, caret } = replaceToken(this.text, range, atEnd ? `${replacement} ` : replacement);
    this.input.value = text;
    this.dismissed = null;
    this.closeMenu();
    this.field.focus();
    this.render(caret);
    this.askForCompletions();
  }

  insert(typed) {
    let [start, stop] = selectionOffsets(this.field) ?? [this.text.length, this.text.length];
    // pasting into a blank replaces the whole blank, as typing does (typeOverSlot)
    const slot = start === stop && this.tokens.find(token => token.role === 'slot' && token.start < start && start < token.stop);
    if (slot) {
      [start, stop] = [slot.start, slot.stop];
    }
    const clean = typed.replace(/\s+/g, ' ');
    this.input.value = this.text.slice(0, start) + clean + this.text.slice(stop);
    // like typing: an open menu would point at where its word used to be
    this.closeMenu();
    this.render(start + clean.length);
  }

  // the misspelled words the server found in the text as it is now
  misspelledWords() {
    return this.suggested.text === this.text ? this.suggested.words : [];
  }

  /**
   * Once typing stops, asks the server what a query that doesn't parse may have meant, and redraws with its
   * misspelled words underlined. Not for blanks a template left ("<quantity>"), which aren't typos.
   */
  askForSpellings(text) {
    clearTimeout(this.suggestTimer);
    if (text.trim() === '' || text === this.suggested.text || /<[^>]*>/.test(text)) {
      return;
    }
    this.suggestTimer = setTimeout(() => {
      fetch(`/api/suggestions?query=${encodeURIComponent(text)}`)
        .then(response => (response.ok ? response.json() : null))
        .then(found => {
          // only if the text hasn't changed since
          if (found && this.text === text) {
            this.suggested = { text, words: found.words ?? [] };
            this.refresh();
          }
        })
        // without them the box works as before
        .catch(() => {});
    }, SUGGEST_AFTER_MS);
  }

  /**
   * Colors the query again with the word lists once they load, keeping the selection. Not while an
   * IME is composing: redrawing would drop the text not yet committed, and compositionend redraws.
   */
  refresh() {
    if (this.composing) {
      return;
    }
    const selection = selectionOffsets(this.field);
    this.redrawing = true;
    this.render();
    if (selection && document.activeElement === this.field) {
      setSelection(this.field, ...selection);
    }
    this.redrawing = false;
    this.showNext();
  }

  /** Redraws the field as colored words; puts the caret back at that offset if given. */
  render(caret = null) {
    const text = this.text;
    const { tokens, error } = analyze(text, vocabulary);
    this.tokens = tokens;
    const misspelled = this.misspelledWords();
    const parts = [];
    let at = 0;
    tokens.forEach((token, index) => {
      if (token.start < at) {
        // overlaps the one before (analyze shouldn't allow it): drawing it would repeat text
        return;
      }
      if (token.start > at) {
        parts.push(text.slice(at, token.start));
      }
      const span = document.createElement('span');
      span.className = `tok tok-${token.role}`;
      if (suggestedAlternatives(token, text, misspelled).length > 0) {
        span.classList.add('tok-misspelled', 'tok-swappable');
      } else if (isQuantity(token) || alternatives(token, vocabulary).length > 0) {
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
    this.askForSpellings(text);
    if (caret !== null && document.activeElement === this.field) {
      setCaret(this.field, caret);
    }
    this.showNext();
  }

  keydown(event) {
    // keys during IME composition (Enter confirms the composed text) belong to the IME
    if (event.isComposing || event.keyCode === 229) {
      return;
    }
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
    } else if (event.key === 'Escape' && (open || this.next)) {
      event.preventDefault();
      // put away until something is typed, so Tab leaves the box again
      this.dismissed = this.text;
      this.closeMenu();
      this.hideNext();
    } else if (event.key === 'Tab' && !event.shiftKey && !event.altKey && !event.ctrlKey && !event.metaKey
        && open && this.menuKind !== 'swap' && this.options.length > 0) {
      // the gray word, first in the list beside it, unless another option was arrowed to
      if (this.menuKind === 'complete' && this.active < 0 && this.next) {
        event.preventDefault();
        this.takeNext();
        return;
      }
      // a whole search ("mechs with 2 ppc") is left as it is, not made "ppc capacitor" on the way out of the box
      if (this.menuKind === 'complete' && this.active < 0 && this.completed.complete) {
        return;
      }
      event.preventDefault();
      // hovering the gray word opens its list without choosing from it
      if (this.menuKind === 'next' && this.active < 0) {
        this.takeNext();
      } else {
        this.pick(Math.max(0, this.active));
      }
    } else if (event.key === 'Tab' && !event.shiftKey && !event.altKey && !event.ctrlKey && !event.metaKey && this.next) {
      event.preventDefault();
      this.takeNext();
    } else if ((event.key === 'ArrowDown' || event.key === 'ArrowUp') && !event.altKey && open && this.options.length > 0) {
      event.preventDefault();
      const count = this.menu.children.length;
      this.highlight((this.active + (event.key === 'ArrowDown' ? 1 : count - 1)) % count);
    } else if (event.key === 'ArrowDown' && event.altKey) {
      // the keyboard way in: the alternatives for the word at the caret
      event.preventDefault();
      this.closeMenu();
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
    // a misspelled word's spellings first
    const options = token
      ? [...suggestedAlternatives(token, this.text, this.misspelledWords()), ...alternatives(token, vocabulary)]
      : [];
    if (options.length === 0 || !span) {
      this.closeMenu();
      return;
    }
    this.openList(token, options, span, 'swap');
  }

  /** Opens a list of options for part of the query, under that element or box. */
  openList(token, options, anchor, kind) {
    if (this.menuToken === token && !this.menu.hidden) {
      return;
    }
    this.menuToken = token;
    this.menuKind = kind;
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
    this.showMenu(anchor);
  }

  /** For a number: a box to type it in, Enter to use it. */
  openNumberBox(token, span, kind = 'swap') {
    if (this.menuToken === token && !this.menu.hidden) {
      return;
    }
    this.menuToken = token;
    this.menuKind = kind;
    this.options = [];
    this.active = -1;
    this.menu.setAttribute('role', 'group');
    const item = document.createElement('li');
    item.className = 'query-menu-number';
    const label = document.createElement('label');
    const box = document.createElement('input');
    // text, not type="number": the browser would validate it as part of the form and could block
    // searching; quantityText checks it instead
    box.type = 'text';
    box.autocomplete = 'off';
    box.inputMode = 'numeric';
    // a number typed as digits starts in the box; "two" or a blank starts empty, showing what Enter
    // keeps: the blank's default, or "two"
    box.placeholder = token.role === 'slot' ? SLOT_DEFAULTS.quantity : token.text;
    box.value = quantityText(token.text) ?? '';
    label.append('How many? ', box);
    item.append(label);
    box.addEventListener('keydown', event => {
      if (event.isComposing || event.keyCode === 229) {
        return;
      }
      if (event.key === 'Enter') {
        // not the form's Enter: the box is inside it
        event.preventDefault();
        const number = box.value.trim() === '' ? box.placeholder : quantityText(box.value);
        if (number === null) {
          box.setAttribute('aria-invalid', 'true');
        } else {
          this.use(this.menuToken, number);
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

  /** Under the word, moved left as far as it takes to stay inside the search box (phones). */
  showMenu(span) {
    this.menu.style.top = `${span.offsetTop + span.offsetHeight}px`;
    this.menu.style.left = '0px';
    this.menu.hidden = false;
    const room = this.wrapper.clientWidth - this.menu.offsetWidth;
    this.menu.style.left = `${Math.max(0, Math.min(span.offsetLeft, room))}px`;
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
    this.use(option.start === undefined ? this.menuToken : { ...this.menuToken, start: option.start }, option.text);
  }

  // a swap searches right away; a completion or the next word goes on typing
  use(range, replacement) {
    if (this.menuKind === 'swap') {
      this.choose(range, replacement);
    } else {
      this.insertNext(range, replacement);
    }
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
    // empty, so nothing left in it (a number box) takes part in the form
    this.menu.replaceChildren();
    this.menuToken = null;
    this.menuKind = 'swap';
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
  setSelection(field, offset, offset);
}

/** Where part of the text is, measured like an element's offsets in the search box; on the line it ends on. */
function rangeBox(field, start, stop) {
  const range = document.createRange();
  range.setStart(...position(field, start));
  range.setEnd(...position(field, stop));
  const rects = range.getClientRects();
  const rect = rects[rects.length - 1] ?? field.getBoundingClientRect();
  const box = field.offsetParent.getBoundingClientRect();
  return { offsetLeft: rect.left - box.left, offsetTop: rect.top - box.top, offsetWidth: rect.width, offsetHeight: rect.height };
}

/** Selects from one character offset to another (the same offset for a caret). */
function setSelection(field, start, stop) {
  const range = document.createRange();
  range.setStart(...position(field, start));
  range.setEnd(...position(field, stop));
  const selection = window.getSelection();
  selection.removeAllRanges();
  selection.addRange(range);
}

// the text node and offset in it for a character offset into the field; past the end is the end
function position(field, offset) {
  const walker = document.createTreeWalker(field, NodeFilter.SHOW_TEXT);
  let remaining = offset;
  let node;
  while ((node = walker.nextNode())) {
    if (remaining <= node.length) {
      return [node, remaining];
    }
    remaining -= node.length;
  }
  return [field, field.childNodes.length];
}

document.querySelectorAll('input[data-query-input]').forEach(input => editors.push(new QueryEditor(input)));
