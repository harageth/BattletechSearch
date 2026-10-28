---
name: vehicle-motive-types
description: Use when importing vehicle motive systems (tracked, wheeled, hover, ...) from MegaMek, adding motive type to the unit table, or making "tank", "tracked", "wheeled" or "hovercraft" searches return results. Contains an unresolved product decision about what "tank" means that must be settled with the user first.
---

# Vehicle motive types

Searching by motive type was designed in but never finished. Queries like `tracked with at least 2 lrm20` parse, then fail on purpose with "Searching by motive type (tracked) isn't supported yet", because the data to answer them doesn't exist.

## Open question: resolve with the user before implementing

**What does "tank" mean?** The user hasn't decided. Ask them before changing search behavior.

- **A. Synonym for tracked.** This is what the grammar does today: `TRACKED: T R A C K E D S* | T A N K S* ;` in `src/main/antlr4/me/Battletech.g4`.
- **B. All ground vehicles.** Every `Tank` row (dtype `Tank`) of any motive type except VTOL. This needs `tank` back as its own lexer token (e.g. `TANK: T A N K S* ;`, listed in the `unit` rule) that `UnitBuilder` maps to `new Tank()`. Remove `T A N K S*` from `TRACKED`.

When it's decided, record the answer in this file and delete this section.

## Current state

- `model/MotiveSystem.java` enum: Tracked, Wheeled, Hover, VTOL, Naval, Hydrofoil, Submarine, WiGE. It isn't used anywhere yet.
- Grammar unit tokens: `TRACKED` (also matches "tank"), `WHEELED`, `HOVERCRAFT` (also matches "hovertank"), all plural- and case-insensitive.
- `utils/UnitBuilder.java` throws `FailedParseException` for tracked/wheeled/hovercraft. The controller shows that message on the search page.
- `utils/ReadMegaMek.java` `ReadVehicleBlk` reads `motion_type` from the `.blk` file and discards it.
- No motive column exists in the `unit` table. All 917 `Tank` rows come from the Flyway baseline dump (`V2_0__baselineData.sql`). That file is a `pg_dump` of a database originally filled by `UnitService.persistVehicles()`, and every fresh database (including Testcontainers) loads units only from it.
- The importer can't currently be run from the app: `/readFile/` in `web/SearchController.java` only calls `unitService.importRecognitionGuide()`, and the `persistVehicles()` / `persistMechs()` calls are commented out. Re-enable one deliberately (and set `MEGAMEK_VEHICLES_PATH`) to re-import.
- `entities/Vehicle.java` is **not** an `@Entity` or `@MappedSuperclass`, so a field added there won't be persisted. Put it on `Tank`, or make `Vehicle` a `@MappedSuperclass`. Single-table inheritance stores it in `unit` either way.

## Implementation outline

1. **Entity:** add `@Enumerated(EnumType.STRING) MotiveSystem motiveSystem` (see the note on `Vehicle` above).
2. **Importer:** in `ReadVehicleBlk`, map `motion_type` to `MotiveSystem`. Match case-insensitively, and log unknown values instead of failing the whole unit.
3. **Schema:** add a new migration `V3_x__vehicle_motive_system.sql` that adds a nullable `motive_system varchar(255)` column. Never edit V1/V2; they're already applied.
4. **Backfill existing rows:** unit ids are random UUIDs, so match on `name` + `designation`. Either re-run the vehicle import against a MegaMek checkout (`MEGAMEK_VEHICLES_PATH`) and generate `UPDATE` statements into the V3 migration, or ship the backfill as a separate data migration. The baseline must stay reproducible from Flyway alone.
5. **Search:** replace the throw in `UnitBuilder` with real unit types, and have `UnitDecorator.getQuery` add `motive_system = ...`. Build SQL from enum values only, never from user text.
6. **Tests:** replace `motiveTypesAreNotSupportedYet` in `QueryVisitorTest` and `SearchServiceTest` with real expectations, plus one for the "tank" decision.

## Verification

- `./mvnw verify` (needs Docker; Testcontainers loads V1 + V2 + the new migration).
- Spot-check counts per motive type in the database: `select motive_system, count(*) from unit where dtype = 'Tank' group by 1;`. Nothing should be null unless it was logged as unknown.
- In the running app, `tracked with at least 2 lrm20` and `wheeled …` return disjoint result sets, and `vehicle …` covers both.
