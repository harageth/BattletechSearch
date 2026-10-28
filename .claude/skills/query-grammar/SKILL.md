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
4. `UnitDecorator.getQuery()` builds the SQL: a `dtype` / `weight_class` filter plus one `id IN (...)` subquery per chunk, joined by the chunk's `and`/`or` (default AND). **Tech is optional** (user decision, 2026-10-27, replacing the earlier per-variant counting): all matching equipment rows (IS, Clan, null tech) are counted together in one `equipment_id IN (...)` group, so "at least 4 medium laser" counts a mixed mech's IS and Clan lasers. A leading `clan` / `is` / `inner sphere` (`QueryVisitor.TECH_PREFIXES`, checked on the typed words before fire control: `clan artemis lrm 20`) keeps only rows of that tech. If the equipment exists but not in that tech (`clan plasma rifle`), the chunk matches no units (`EquipmentDecorator.matchesNothing`) instead of failing to parse; only names that don't exist at all give "Unable to parse".
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

## Adding things

- **Comparator:** add the phrase to the matching token in the grammar (`ATLEAST`, `NOMORE`, `EQUAL`, `LESSTHANCOMPARATOR`, `GREATERTHANCOMPARATOR`), or add a new token to the `comparator` rule and handle its symbolic name in `EquipmentDecorator.buildComparison`.
- **Quantity word:** add a `fragment` to `NUMBER` in the grammar and the word to `QuantityConverter.NUMBER_WORDS`.
- **Unit type:** add a token, list it in the `unit` rule, and map its symbolic name in `UnitBuilder` and `UnitDecorator.getQuery`.
- **Slang:** `POST localhost:8081/actuator/slang` with `{"equipmentName": "mediumlaser", "terms": "ml, medium laser"}` (`admin/SlangEndpoint`, admin port, localhost only). Terms are one comma-separated string, because Actuator only binds string values from the JSON body. Both the name and the terms are stored normalized (`EquipmentNames`). The `equipment_slang` table ships empty.
- Tests: `QueryVisitorTest` (parser only, mocked repository) and `SearchServiceTest` (real data via Testcontainers). Add both.

## Planned, not built

- **Era search.** The `unit.era` column exists. `Unit.getQuery()` (unused; `UnitDecorator` overrides it) sketches an era filter. It still refers to an old `mechs` table. `Battletech.g4` has a commented-out list of eras (Age of War ... IlClan) and a commented-out `WEIGHTCLASS` token.
- **Location filters.** `EquipmentDecorator.getQuery` has a placeholder for filtering by equipment location.
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
