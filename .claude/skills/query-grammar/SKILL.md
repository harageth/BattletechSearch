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
   - Each `equipmentChunk` becomes an `EquipmentDecorator`. Its words are joined, lowercased, and looked up with `EquipmentRepository.findAllBySlangOrEquipmentName`, which matches the equipment name or an `equipment_slang` row. If several rows match (IS and Clan variants), the decorators are chained.
   - `EquipmentDecorator.buildComparison` + `model/search/QuantityConverter` turn the comparator token and quantity into a `Comparison` and an int.
4. `UnitDecorator.getQuery()` builds the SQL: a `dtype` / `weight_class` filter plus one `id IN (...)` subquery per chunk, joined by the chunk's `and`/`or` (default AND). Each matching variant is counted separately and UNIONed, so "at least 3 ppc" means at least 3 of one variant.

## Gotchas

- **Lexer rules are tried longest match first, then by order in the file.** Keyword tokens (`MECH`, `ATLEAST`, `WITH`, `AND`, ...) must stay above `WORD`, or `WORD` swallows them.
- Multi-word tokens (`at least`, `or fewer`) match a literal single space `[ ]`. `WHITESPACE` is skipped between tokens, not inside them.
- `NEWLINE` used to be `[\r\n]`-ish letters and matched the words `r` and `n`. It's now `('\r'? '\n' | '\r')+`. Test single-letter input when touching it.
- Case-insensitivity comes from the letter fragments (`M : ('M'|'m')`). Plurals come from a trailing `S*`.
- `QUANTITY` includes `a`, so `a` can't be used as an equipment word.
- `tank` is currently a synonym for `tracked`. See the `vehicle-motive-types` skill before changing that.
- `QueryVisitor`'s `slangRepo` is passed in but unused; slang is resolved inside `findAllBySlangOrEquipmentName`.
- Unit and weight class SQL is built from enums. Equipment is matched by id after a repository lookup. Keep user text out of the SQL string.

## Adding things

- **Comparator:** add the phrase to the matching token in the grammar (`ATLEAST`, `NOMORE`, `EQUAL`, `LESSTHANCOMPARATOR`, `GREATERTHANCOMPARATOR`), or add a new token to the `comparator` rule and handle its symbolic name in `EquipmentDecorator.buildComparison`.
- **Quantity word:** add a `fragment` to `NUMBER` in the grammar and the word to `QuantityConverter.NUMBER_WORDS`.
- **Unit type:** add a token, list it in the `unit` rule, and map its symbolic name in `UnitBuilder` and `UnitDecorator.getQuery`.
- **Slang:** `POST localhost:8081/actuator/slang` with `{"equipmentName": "mediumlaser", "terms": "ml, medium laser"}` (`admin/SlangEndpoint`, admin port, localhost only). Terms are one comma-separated string, because Actuator only binds string values from the JSON body. The `equipment_slang` table ships empty.
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
