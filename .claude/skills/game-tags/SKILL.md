---
name: game-tags
description: Use when tagging units with the games they appear in (MechWarrior 5 and its DLC, MechWarrior 5 Clans, HBS BattleTech, MechWarrior Online, tabletop boxed sets, older games), or searching or showing those tags. Planned, not built yet - holds the user's decisions, what the unit data has today, and the open questions.
---

# Game tags (planned, not built)

## Decided

- **Units get tagged with the games they're in** (user, 2026-11-11), so people can find a unit from a game they play, or see which games a unit is in.
- **Which games:**
  - MechWarrior 5: Mercenaries, **with each DLC listed on its own**
  - MechWarrior 5: Clans
  - HBS BattleTech (Harebrained Schemes, 2018), with its DLC
  - MechWarrior Online
  - tabletop boxed sets and miniature packs (Beginner Box, A Game of Armored Combat, Mercenaries, ForcePacks, ...)
  - **older games too, wherever data can be found** (earlier MechWarrior and MechCommander games, and so on)
- **Where the data comes from is decided later**, when this is built (user: "We can solve where to get the data later").

## What the unit data has today

- **MegaMek's files don't say which games a unit is in.** The only trace is `source:Apocryphal (Videogame)` on 25 mechs, in `meks/Videogame (Apocryphal)/` at the pinned mm-data commit (`Bull Shark BSK-M3`, `Corsair COR-5R`, ...). It doesn't name the game, and none of those 25 has a MUL id, so they aren't imported (importers skill, bug 25).
- **Units are matched on `unit.megamek_uuid`**, and variants share a `unit.mul_id` (importers skill, bug 1). A game list names a chassis and model (`Atlas AS7-D`), so tags would be matched to units by name and model, then stored against the unit.

## Open questions

- **The data source**, per game: official lists, wikis (Sarna lists the games a unit appears in), or game files. Check each one's license, as for the MegaMek data.
- **Per variant or per chassis.** A game usually has some variants of a chassis, not all of them. Tagging the variant is the accurate choice. Tagging the chassis is easier, but over-reports.
- **Game-only variants.** Units that exist only in a video game (hero mechs, game-original variants) aren't in the MUL, so there's no unit to tag. Decide whether they're left out, or listed in some other way.
- **Storage:** probably a `game` table (name, kind: video game / DLC / boxed set, parent game for a DLC) and a `unit_game` join table. Follow the schema-change rule: show the rows before proposing tables.
- **Search syntax:** for example `mechs in mw5`, `heavy mechs in mechwarrior online`, `units in heavy metal`. Game names and their short forms (`mw5`, `mwo`, `hbs`) would be search words, so add them to the `query-grammar` skill and `QueryVocabulary` when it's built. A DLC search might include its base game, or not.
- **Showing tags:** on the search results and the unit's details.
