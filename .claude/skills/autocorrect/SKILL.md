---
name: autocorrect
description: Use when changing spelling suggestions for search queries ("Did you mean heavy mechs?"), the /api/suggestions endpoint, the search box's underlined misspelled words, or the word index (SearchWords) that autocomplete is meant to reuse. Holds the user's decisions, how it works, and the future improvements (popularity ranking).
---

# Autocorrect

Built 2026-11-18 (branch `autocorrect`). A search that doesn't parse gets "Did you mean …?"; the search box underlines the misspelled words and offers their spellings.

## Decided

- **A real autocorrect for every kind of term** (user, 2026-11-01): weight classes, unit words, omni words, with/without words, comparators, quantity words, operators, tech words, fire control and mount words, equipment names and slang, components.
- **Unknown words fail; they're never dropped or quietly replaced.** Autocorrect only adds a suggestion to the error.
- **Ask, never auto-run** (user, 2026-11-18): the results page shows the error and "Did you mean *heavy mechs with 2 ppc*?" as a link that runs it. Nothing is searched that wasn't typed or clicked.
- **One corrected query** on the results page; **up to 3 spellings per word** in the search box's list (user, 2026-11-18).
- **A typo** is a swapped pair, a missing, an extra or a wrong letter, one edit each (optimal string alignment distance), on `EquipmentNames.slangKey` (case and punctuation don't count). **Allowed edits by length** = Elasticsearch's `fuzziness: AUTO` (user, 2026-11-18, after comparing with standard practice): none for 1–2 letters, 1 for 3–5, 2 for 6+. So `lager` (5 letters, 2 edits from `large`) gets nothing. **Run-together words split** (`heavymechs` → `heavy mechs`, one edit).
- **Equally close candidates:** fixed words of the grammar before equipment, then alphabetical.
- **Server only** (user, 2026-11-18): the browser asks the server; no matching logic in JavaScript.
- **Words in the wrong place are moved** (user, 2026-11-18): when no spelling fix parses, the words where the query stopped making sense are tried at every other place, nearest first. One move per suggestion, never combined with a spelling fix, and only those words move, so a suggestion doesn't rearrange words the grammar understood. Results page only; the search box's per-word list has no place for "move this".

## How it works

- `autocorrect/SearchWords`: every word a query can contain, by key. Fixed words: everything `antlr/QueryVocabulary` serves plus `QueryVocabulary.keywords()` (every other spelling the lexer takes: `helo`, `lacking`, `that don't have`, ...; `QueryVocabularyTest` checks each is one keyword token) and `QuantityConverter.numberWords()`. Equipment: every stored display name (as `EquipmentNames.typed`) and name, and every slang term. Each phrase's words, plus the whole phrase matched run together and shown with its spaces (`mediumlasr` → `medium laser`). Brackets and trailing commas are dropped from shown words. Reads only equipment and slang; no new tables or queries over units. `Autocorrect` rebuilds it at most once a minute, so imports show up.
- `autocorrect/TypoMatcher`: candidates for one word, closest first (pure; `TypoMatcherTest`).
- `autocorrect/Autocorrect.suggest(query)`: a query that parses gets nothing. Otherwise each word that isn't a number, a bracketed part or a known word is a typo (the first 4); its 3 closest candidates, and the word as typed, are tried in every combination, closest first (at most 100), through `QueryParser.parse` (parses and looks up equipment; runs no search). The first that parses is the corrected query, so a word becomes whatever fits where it is, wherever the error showed up (`mehcs` read as a weight class → `mechs`; `adn` → `and`, not `an`). A word's list is its candidates that appear in any combination that parses. Keeping the word as typed as an option means a word the index doesn't know but the grammar does (`20s` in `lrm 20s`) doesn't block the rest. 6–80 ms on full data.
- **Moves** (`Autocorrect.moved`): where the query stopped making sense is `QueryParser.syntaxErrorAt` (the word ANTLR didn't expect, or the end) or, when the grammar took the words but they mean nothing there, the end of `FailedParseException.getUnknownName()` (an equipment name nothing is called: `with 2 ppc heavy mechs` is read as the name "ppc heavy mechs"). The 1–3 words from there and the 1–3 just before are each tried at every other place, by how far they move, then fewest words first, up to 100 tries. Examples on full data (11–47 ms): `mechs with 2 ppc or more` → `mechs with 2 or more ppc`, `mechs heavy with 2 ppc` / `with 2 ppc heavy mechs` / `heavy with 2 ppc mechs` → `heavy mechs with 2 ppc`, `mechs with ppc at least 2` → `mechs with at least 2 ppc`. A query with two separate mistakes gets nothing.
- `web/SearchController` adds `suggestion` on a `FailedParseException`; `templates/search.html` shows the link (`.suggestion`).
- `GET /api/suggestions?query=` (`web/SuggestionController`): `{query, words: [{start, stop, text, suggestions}]}`, offsets in UTF-16 code units. Not cached.
- Search box: `query-input.js` asks 500 ms after typing stops (not for template blanks), keeps the answer for that text, underlines a token holding a misspelled word (`.tok-misspelled`) and puts its spellings first in the list (`query-analysis.js` `suggestedAlternatives`, which swaps just that word inside the token).
- Tests: `TypoMatcherTest`, `AutocorrectTest` (a table of misspelled queries on the fixtures, the endpoint's JSON), `SearchControllerTest` (the link), JS `suggestedAlternatives`.

## Future improvements (not built)

- **Ranking by popularity** (user, 2026-11-18: documented, not built, to avoid more database work now): standard spell-checkers break ties by frequency. Here that would be how many units have an item, so a typo equally close to two items suggests the more common one first.
- **Keyboard-neighbor typos:** a wrong letter next to the intended key counted as a smaller typo. Most systems skip it.
- **Autocomplete** (the next PR): `SearchWords` keeps every phrase with whether it's fixed or equipment, and `/api/suggestions` is the place to return completions. Autocomplete needs prefix matching and what the grammar allows at the cursor (ANTLR's expected tokens, already used by `QueryParser.ThrowingErrorListener`).
- The error message itself still names where the word landed ("Unknown weight class: mehcs"); the suggestion says what was meant.
