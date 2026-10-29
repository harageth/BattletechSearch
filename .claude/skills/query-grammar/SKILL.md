---
name: query-grammar
description: Use when changing the search query language - the ANTLR grammar (Battletech.g4), QueryParser, QueryVisitor, or how a query becomes SQL - or when adding unit types, comparators, quantity words, equipment slang, or era search. Holds the original design notes and the gotchas found so far.
---

# Query grammar

A search like `light mechs with at least 2 ppc and a srm6` is parsed by ANTLR into units and equipment chunks, then turned into SQL.

## Pipeline

1. `src/main/antlr4/me/Battletech.g4` is the grammar. `antlr4-maven-plugin` generates `me.BattletechLexer` / `me.BattletechParser` / `me.BattletechVisitor` during the build, so there's no generated code in git.
2. `antlr/QueryParser.parse(...)` runs the lexer and parser with a throwing error listener. Any syntax error fails the whole query with a `FailedParseException`, which the controller shows on the page. Never let ANTLR silently recover. `ThrowingErrorListener` turns ANTLR's raw messages into plain ones ("expected 'with' before 'at least'"), using the parser's expected-token set. When you add a token that users can leave out, add it to `describe` too.
3. `antlr/QueryVisitor` walks the tree:
   - `visitUnit` → `utils/UnitBuilder` maps the unit token's symbolic name to an entity class (`Mech`, `Vehicle`, `Vtol`, `Unit`) wrapped in a `UnitDecorator`.
   - Leading `WORD`s before the unit are joined into a weight class (`ultra light`).
   - Each `equipmentChunk` becomes an `EquipmentDecorator`. Its words are joined, lowercased, and looked up with `EquipmentRepository.findAllByNameOrSlang(canonical, typed)`: the equipment name by `EquipmentNames.canonical` (MegaMek alias table, so `ac 20` = `autocannon 20` = `ac/20`), or an `equipment_slang` row by the normalized typed name. If several rows match (IS and Clan variants), the decorators are chained.
   - `EquipmentDecorator.buildComparison` + `model/search/QuantityConverter` turn the comparator token and quantity into a `Comparison` and an int.
4. `UnitDecorator.getQuery()` builds the SQL: a `dtype` / `weight_class` filter plus one `id IN (...)` subquery per chunk, joined by the chunk's `and`/`or` (default AND). **Tech is optional** (user decision, 2026-10-27, replacing the earlier per-variant counting): all matching equipment rows (IS, Clan, null tech) are counted together in one `equipment_id IN (...)` group, so "at least 4 medium laser" counts a mixed mech's IS and Clan lasers. A leading `clan` / `is` / `inner sphere` (`EquipmentNames.splitTechWord`, checked on the typed words before fire control: `clan artemis lrm 20`) keeps only rows of that tech. If the equipment exists but not in that tech (`clan plasma rifle`), the chunk matches no units (`EquipmentDecorator.matchesNothing`) instead of failing to parse; only names that don't exist at all give "Unable to parse".
- **Shorthand:** `src/main/resources/megamek/equipment-slang.tsv` (hand-maintained, e.g. `ams`, `jj`) is loaded on top of the generated alias table by `EquipmentNames`. Like the alias table, it's meant to move into `equipment_slang` later.

## Gotchas

- **Lexer rules are tried longest match first, then by order in the file.** Keyword tokens (`MECH`, `ATLEAST`, `WITH`, `AND`, ...) must stay above `WORD`, or `WORD` swallows them.
- Multi-word tokens (`at least`, `or fewer`) match a literal single space `[ ]`. `WHITESPACE` is skipped between tokens, not inside them.
- `NEWLINE` used to be `[\r\n]`-ish letters and matched the words `r` and `n`. It's now `('\r'? '\n' | '\r')+`. Test single-letter input when touching it.
- Case-insensitivity comes from the letter fragments (`M : ('M'|'m')`). Plurals come from a trailing `S*`.
- `QUANTITY` includes `a`, so `a` can't be used as an equipment word.
- Equipment names are the `equipmentName` rule: `WORD+ QUANTITY?`. The words (plus an optional trailing number) are joined with spaces (`visitEquipmentName`) and then normalized with `utils/EquipmentNames.normalize` (lowercase, no spaces, mounting notes like `(R)` / `(OS)` removed). The same normalizer is used on import and for slang, so `large laser` = `largelaser` and `lrm 20` = `lrm20`.
- **Fire control prefixes.** `artemis lrm 20`, `artemis iv srm 6`, `artemis v lrm 15` and `apollo mrm 40` search for launchers with that fire control. `FireControl.fromSearch` splits the prefix off the normalized name; plain `artemis` means IV or V. `EquipmentDecorator` adds `AND fire_control IN (...)` (enum names). Without a prefix, `lrm 20` counts every LRM 20, with or without Artemis. Fire control is stored on the launcher (importers skill, bug 20).
- **A trailing number is part of the name only if no word follows it.** A number lexes as `QUANTITY` whether it's `20` in `lrm 20` or the quantity of the next chunk. Because the name allows at most one trailing `QUANTITY`, and a chunk needs a word after its quantity, ANTLR's lookahead splits `mechs with 2 ppc 3 srm6` into `ppc` + `3 srm6`, but keeps `2 lrm 20 3 srm 6` as `lrm 20` + `3 srm 6`. Side effects: a name can't have a number in the middle (`lrm 20 artemis` reads as `lrm` with a chunk `20 artemis`), and `mechs with 2 ppc 3` asks for equipment `ppc 3` ("Unable to parse: ppc 3"). Tests: `QueryVisitorTest.equipmentNamesCanEndInANumber`, `aNumberBeforeAWordStartsTheNextChunk`.
- `tank` means every ground vehicle (dtype `Tank`, not VTOLs). `tracked` / `wheeled` / `hovercraft` are motive types; see the `vehicle-motive-types` skill.
- `QueryVisitor`'s `slangRepo` is passed in but unused; slang is resolved inside `findAllBySlangOrEquipmentName`.
- Unit and weight class SQL is built from enums. Equipment is matched by id after a repository lookup. Keep user text out of the SQL string.


## The search box (browser side)

The search box colors the query as you type and offers swaps on hover. It parses **in the browser** with JavaScript generated from the same grammar: a second `antlr4-maven-plugin` execution (`-Dlanguage=JavaScript`) writes `BattletechLexer.js` / `BattletechParser.js` to `target/classes/static/js/grammar/me/`, served as `/js/grammar/me/...`. The ANTLR runtime is vendored at `static/vendor/antlr4/antlr4.web.js` (antlr4@4.13.2 `dist/antlr4.web.mjs`, renamed `.js` so it's served as JavaScript; module scripts need a JavaScript MIME type). It **must stay the same version as `antlr4.version`** in the pom. The import map in `templates/fragments/search-form.html` points the generated code's bare `antlr4` import at it.

- `static/js/query-analysis.js` (no DOM): `analyze` gives each word a role from the parse tree; `alternatives` lists swaps; `replaceToken` applies one. **It splits equipment names the same way `QueryVisitor` does** (tech word, then fire control, then the name). Change both together.
- `static/js/query-input.js`: replaces each `<input data-query-input>` with a contenteditable field and keeps the hidden input in sync, so the form submits unchanged. Without JavaScript, the plain input still works.
- **Templates** (user decision, 2026-10-28): the "+ unit" and "+ weapon" buttons add a section of blanks, written into the query as `<weight class> <unit> with <comparator> <quantity> <weapon>` (`TEMPLATES` in query-analysis.js); a weapon section after another starts with an `<and/or>` blank. Each blank's list opens in turn (guided fill-in; a number, blank or typed, gets a box to type it in instead of a list: `isQuantity`, `quantityText`), and the search runs once the last is filled. Typing in a blank replaces it. Escape, or searching early, fills the rest with `SLOT_DEFAULTS` (`fillSlots`, also run on submit), so **the server never sees a blank**. `analyze` reads a query with blanks by padding each default to the blank's length, which keeps offsets, so every default must fit in its blank. Equipment dropdowns also offer adding a tech (`clan only`, inserted before any fire control) and, for LRM/SRM/MML (not Streak) and MRM families, `with artemis` / `with apollo`.
- **Word lists:** `GET /api/vocabulary` (`web/VocabularyController`) serves `antlr/QueryVocabulary`: weight classes (`WeightClass`), unit words and comparators (`QueryVocabularyTest` checks each still lexes to the right token), tech words (`EquipmentNames.techWords`), fire controls (`FireControl.searchWords`, which `fromSearch` also reads), and equipment families. It lists only family weapons that some unit has and a query can type (`QueryVocabulary.isTypeable` runs them through the real parser).
- **Not mirrored yet:** fire control run into the weapon name in one word (`artemisivlrm20`). The server accepts it (`FireControl.fromSearch` works on the normalized name), but `query-analysis.js` only splits fire control at word boundaries, so the box colors it all as equipment with no dropdown (Copilot review, 2026-10-29; left as minor).
- **Equipment families are slang terms** (user decision): `lasers`, `lrms`, `srms`, `streaks`, `torpedoes`, `mmls`, `mrms`, `autocannons`, `ppcs`, `gauss rifles`, `machine guns`, `flamers`. A family term searches every weapon in the family, counted together (`at least 4 lasers`). Tech and fire control still apply (`clan lasers`, `artemis lrms`). There are deliberately no size-level terms like `medium lasers`; they'd clash with the plural of `Medium Laser`. The families come from `megamek/equipment-family-slang.tsv` (see the importers skill, bug 21), loaded by `EquipmentNames.familyMembers`. A slang term registered with the same name as a family term is searched together with the family.
- **Tests:** `src/test/js/*.test.mjs` run with Node's test runner in Maven's `test` phase. `frontend-maven-plugin` installs Node into `target/node`, and the tests import from `target/classes`. When the grammar changes, check the JS tests too.

## Adding things

- **Comparator:** add the phrase to the matching token in the grammar (`ATLEAST`, `NOMORE`, `EQUAL`, `LESSTHANCOMPARATOR`, `GREATERTHANCOMPARATOR`), or add a new token to the `comparator` rule and handle its symbolic name in `EquipmentDecorator.buildComparison`.
- **Quantity word:** add a `fragment` to `NUMBER` in the grammar and the word to `QuantityConverter.NUMBER_WORDS`.
- **Unit type:** add a token, list it in the `unit` rule, and map its symbolic name in `UnitBuilder` and `UnitDecorator.getQuery`.
- **Anything people type** (comparator, unit word, tech or fire control word): also add it to `QueryVocabulary` (or where it reads from) so the search box offers it.
- **Slang:** `POST localhost:8081/actuator/slang` with `{"equipmentName": "mediumlaser", "terms": "ml, medium laser"}` (`admin/SlangEndpoint`, admin port, localhost only). Terms are one comma-separated string, because Actuator only binds string values from the JSON body. Both the name and the terms are stored normalized (`EquipmentNames`). **Slang never carries a tech** (user decision, 2026-10-28): a leading `clan` / `is` / `inner sphere` is stripped from terms (`EquipmentNames.splitTechWord`), and the term goes on every tech of the equipment, even when the name has a tech (`ER PPC [Clan]`). Tech is only a search filter: `clan big ppc` looks up the slang `bigppc` and keeps the Clan rows. The `equipment_slang` table ships empty.
- Tests: `QueryVisitorTest` (parser only, mocked repository) and `SearchServiceTest` (real data via Testcontainers). Add both.

## Planned, not built

- **Era search.** The `unit.era` column exists. `Unit.getQuery()` (unused; `UnitDecorator` overrides it) sketches an era filter. It still refers to an old `mechs` table. `Battletech.g4` has a commented-out list of eras (Age of War ... IlClan) and a commented-out `WEIGHTCLASS` token.
- **Location filters.** `EquipmentDecorator.getQuery` has a placeholder for filtering by equipment location.
- **A query the user expects to work** (future work, 2026-10-28): `medium or heavy mechs with at least 2 lrms and any lasers`. Two pieces are missing; `lrms` and `lasers` already work as family terms:
  - **Several weight classes joined by `or`** (`medium or heavy mechs`). The `line` rule takes `WORD*` before the unit and `QueryVisitor` joins them into one weight class name, so `medium or heavy` fails. `or` also lexes as `OR` there, which `line` doesn't allow. It needs a weight-class list in the grammar and a `weight_class IN (...)` filter in `UnitDecorator.getQuery`.
  - **`any` as a quantity** (`any lasers` = at least 1). `QUANTITY` has no `any`; it would be a new quantity word (meaning `ATLEAST 1`) in the grammar, `QuantityConverter` and `EquipmentDecorator.buildComparison`. Watch for `any` in the search box: it currently offers "any of the lrms" as a label only, not as query text.
  - When this is built, add the query to `QueryVisitorTest`, the search tests and the JS analysis tests, and the new words to `QueryVocabulary`.
- **Synonym graph.** The old `SearchParameters` class noted that unit words form a graph (`vee` → vehicle, `tracked` is a vehicle) rather than a flat map. The old `LanguageMapping` class planned a hard-coded slang map (`LL` → Large Laser, `Vee` → Vehicle, `VSP` → Variable Speed Pulse). The `equipment_slang` table replaced that for equipment.

## Original design notes

From `src/main/resources/antlrNotes.txt`, kept as written:

```
We know that we should expect things in a relative order

Units with at least 3 PPC's
Mechs with 3 or more PPC's
Mechs with 3 PPC's and a small laser or LRM's


[Optional] UNIT + CHUNK + [Optional] CHUNK...

UNIT: any unit type. And if one isn't provided we just assume that it is everything

CHUNK: QUANTITY + EQUIPMENT

QUANTITY: Dont forget

EQUIPMENT: Ideally we could get this from the database... And that might be doable but not sure yet



MEDIUM_LASER: [medium laser | ml]
LARGE_LASER:  [large laser | ll]
```

From the old `SearchService.getQuerySegments()`:

```
// A query should be of the format of
// "Mechs with mutliple Large Lasers" or a more complex query "Things with at least 3 medium lasers and SRM's"

So we need to find part of the query that matches to the language mapping
If we can find where the language mapping is then we can use that as a starting point
to figure out where the rest of the query parameters are.

1. Find what we are looking for
2. split on logical operators while maintaining understanding of them
3. identify what equipment is being looked at or which Unit Parameter
4. identify quantity searching for
5. identify comparator being used (this is probably implied)
```
