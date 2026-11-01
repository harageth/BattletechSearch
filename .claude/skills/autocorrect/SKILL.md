---
name: autocorrect
description: Use when building or changing spelling suggestions for search queries ("Did you mean heavy?"), or the errors a misspelled word causes (Unknown weight class, Unable to parse). Planned as its own PR, not built yet - holds the user's decision, how misspellings are read today, and the open questions.
---

# Autocorrect (planned, not built)

## Decided

- **A real autocorrect for every kind of term** suggests the right spelling (user, 2026-11-01). Kinds: weight classes, unit words, omni words, with/without words, comparators, quantity words, operators, tech words, fire controls, equipment names and slang, components, and `engine rating`.
- **It's its own PR**, after PR #15 and the PR that makes every guide name typeable (generic ammo names, no apostrophes, brackets).
- **Unknown words fail; they're never dropped.** Since PR #15, a weight class that isn't one fails with "Unknown weight class: hevy" (`QueryVisitor.visitWeightClass`). Before, it was left out, and the search covered every weight class. Autocorrect adds a suggestion to errors like this. It never quietly searches for something other than what was typed.

## How a misspelling is read today

A misspelled word usually doesn't fail where it was meant to go. The grammar reads it as whatever a plain `WORD` can be in that position, so the error names the wrong part. Checked 2026-11-01 with `query-analysis.js`:

| Typed | Read as | Error the user sees |
|---|---|---|
| `hevy mechs` | weight class `hevy` | Unknown weight class: hevy |
| `mehcs with 2 ppc` | weight class `mehcs` (no unit; `line` takes weight classes before `with`) | Unknown weight class: mehcs |
| `mechs with at lest 2 ppc` | equipment `at lest`, then `2 ppc` | Unable to parse: at lest |
| `mechs with 2 clna lrm 20` | equipment `clna lrm 20` | Unable to parse: clna lrm 20 |
| `mechs with 2 ppc adn 1 srm 6` | equipment `ppc adn`, then `1 srm 6` | Unable to parse: ppc adn |
| `mechs wtih 2 ppc` | syntax error at `wtih` | from `ThrowingErrorListener.describe` |

So:
- **Suggestions for a word go by what it could have been, not where it landed.** An "unknown weight class" may be a misspelled unit word (`mehcs`). An "unknown equipment" name may hold a misspelled comparator (`at lest`), tech (`clna`) or operator (`adn`) along with real equipment words.
- **The error messages need the same care.** "Unknown weight class: mehcs" is misleading when the word is a misspelled unit. The autocorrect PR should name the closest kind of term ("Did you mean mechs?").

## Where the words come from

- **Fixed words:** `antlr/QueryVocabulary`, also served at `GET /api/vocabulary`: weight classes, unit words (singular and plural), comparators before and after the number, with words, operators, omni words, tech words, fire controls, and component names (`ComponentNames.names()`). Every spelling the grammar accepts should be a candidate, not only the ones the search box offers. The lexer rules hold more (`hovertank`, `helo`, `lacking`, `that don't have`). Keep the candidate lists generated from, or tested against, the grammar, the way `QueryVocabularyTest` checks the unit words.
- **Equipment:** stored equipment names (`equipment.display_name` / `name`), slang terms (the `slang` table: shorthand, family, user and alias terms), and component names, including the bare armor and structure names. Compare them on `EquipmentNames.slangKey` (lowercase letters and digits), the key the lookups use.

## Where suggestions show

- **Server:** the error on the results page gets "Did you mean …?", with a link that runs the corrected search.
- **Search box:** a word colored `unknown` or `error` (`query-analysis.js`) gets the suggestions in its dropdown, swapped in like any other alternative. The equipment list it needs is already in `/api/vocabulary`. Slang might need adding.
- Both sides have to agree on the suggestions. Either keep the matching rules in one place and mirror them with tests (as with the equipment-name split), or have the browser ask the server.

## Open questions for the user

- **Matching:** edit distance (Damerau-Levenshtein, so `wtih` → `with` costs 1), with a limit that grows with word length? Keyboard-neighbor typos? Plurals and run-together words (`heavymechs`)?
- **How many suggestions:** one best guess, or a short list?
- **Auto-apply:** never (always ask), or run the corrected search when there's exactly one close match and say so ("Showing results for heavy mechs")?
- **Multi-word spans:** how to split `ppc adn 1 srm 6` or `at lest 2`: try re-reading the query with each suggestion and keep the ones that parse?
- **Syntax errors** (`wtih`): suggest from the tokens ANTLR expected at that point (`ThrowingErrorListener` already has the expected-token set)?

## Constraints

- User text never goes into the SQL. A suggestion is only text shown to the user, or a new query that goes through the parser like any other.
- No suggestion replaces what was typed without saying so.
- Tests: a table of misspelled queries and their suggestions, on both sides (`QueryVisitorTest` / `SearchServiceTest`, and `src/test/js`), including the cases in the table above.
