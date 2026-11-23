# BattletechSearch: notes for code reviewers

A Spring Boot site that searches BattleTech units in plain English: `light units with at most 2 medium lasers and at least 1 srm6`. Unit data is imported from MegaMek's data files and ships as Flyway data migrations.

## How it fits together

- **Grammar:** `src/main/antlr4/me/Battletech.g4` (ANTLR 4). `antlr/QueryParser` parses, `antlr/QueryVisitor` builds `model/UnitDecorator` / `EquipmentDecorator`, whose `getQuery()` builds the SQL. Words come from enums and database lookups, never from user text pasted into SQL.
- **Search box** (`src/main/resources/static/js`): `query-analysis.js` (no DOM) reads the query with JavaScript generated from the same grammar; `query-input.js` is the editable field, its menus and keys. The server and the box must read a query the same way.
- **Autocorrect / autocomplete** (`autocorrect/`): `SearchWordsLoader` holds one word index for both. The parser decides what fits: a suggestion is offered only if the query with it parses.
- **Data:** `db/migration` (schema), `db/data` (imported units). A migration that has shipped is never edited.
- **Design decisions** live in `.claude/skills/*/SKILL.md` (query-grammar, autocorrect, importers, ...). Something a skill records as decided by the owner is not a bug; you may question whether the code does what it says.

## Tests

`./mvnw test` runs the Java tests (Testcontainers Postgres, fixture units) and the JavaScript unit tests (`src/test/js`). `npm run test:browser` drives the real search box in Chrome against a running app; it isn't part of the build.

## Reviewing

Look for real defects, ranked:

- **Correctness:** wrong results, crashes, queries that used to work and no longer do.
- **Server vs search box:** the two reading a query differently.
- **Concurrency:** shared state, caches, request races, and the browser's async answers arriving late or out of order.
- **Browser behavior:** focus, caret, IME composition, keyboard traps, and menus left open or stuck.
- **Accessibility:** ARIA roles and states, and what a screen reader is told.
- **Cost and abuse:** work per request, unbounded input, endpoints with no limits.
- **Injection and escaping:** SQL, HTML, and offsets (UTF-16).
- **Data:** migrations that don't match what the importer writes.
- **Tests and comments:** missing or weak tests; wrong comments or docs.

For each finding give:

- a severity: P1 breaks a main path, P2 real but narrower, P3 minor;
- the file and method;
- a concrete input, key sequence or timing;
- the wrong result, traced step by step through the code;
- a fix;
- whether you confirmed it by tracing or think it's plausible.

Trace before reporting, and don't pad the list. "No findings" is a fine answer when it's true, but say what you checked.
