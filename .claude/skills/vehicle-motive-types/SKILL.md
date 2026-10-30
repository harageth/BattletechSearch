---
name: vehicle-motive-types
description: Use when changing vehicle motive systems (tracked, wheeled, hover, naval, ...), the motive_system column, or how "tank", "tracked", "wheeled" or "hovercraft" searches behave. "tank" means every ground vehicle (decided); motive types are imported and searchable.
---

# Vehicle motive types

MegaMek's `<motion_type>` is imported for tanks and searchable. (The V2 baseline data, which predated it, was removed on 2026-10-30.)

## Decided: "tank" means every ground vehicle

The user decided on 2026-10-27 that `tank` means **every ground vehicle**: every `Tank` row (dtype `Tank`) but not VTOLs. `tracked`, `wheeled` and `hovercraft` narrow it down.

MegaMek also files boats as `Tank` (Naval, Hydrofoil, Submarine). Since those aren't ground vehicles, plain `tank` excludes them (`MotiveSystem.WATER`). Rows with no motive type stay included (there are none since the baseline was removed). That exclusion was my reading of "ground vehicles"; the user hasn't confirmed it. `vehicle` still means every Tank and VTOL, boats included.

## How it works

- **Schema:** `V3_1__vehicle_motive_system.sql` adds `unit.motive_system` (varchar, enum name; only set for dtype `Tank`).
- **Entity:** `Tank.motiveSystem` (`@Enumerated(STRING)`). `entities/Vehicle.java` isn't an `@Entity` / `@MappedSuperclass`, so fields there aren't persisted. VTOLs don't store one; they're always VTOL.
- **Enum:** `model/MotiveSystem`: Tracked, Wheeled, Hover, VTOL, Naval, Hydrofoil, Submarine, WiGE, Aerodyne, Rail. Stored by name, so new values can go anywhere. `fromString` is case-insensitive.
- **Importer:** `ReadVehicleBlk` maps `motion_type`; unknown values are logged and stored as null. At the pinned mm-data commit every tank's value is recognized (Tracked 572, Hover 328, Wheeled 314, WiGE 36, Submarine 15, Naval 9, Aerodyne 9, Rail 8, Hydrofoil 7, across Tank and support types).
- **Grammar:** `TANK`, `TRACKED`, `WHEELED` and `HOVERCRAFT` (also "hovertank") tokens, plural- and case-insensitive. There are no tokens yet for WiGE, naval and the others.
- **Search:** `UnitBuilder` maps tracked/wheeled/hovercraft to a `Tank` with that motive. `UnitDecorator.getQuery` adds `motive_system = '<enum name>'`, or for plain `tank` the boat exclusion. The SQL is built from enum names only, never user text.

## Tests

- `QueryVisitorTest.tanksAreAllGroundVehicles`, `motiveTypesNarrowTanks`: parsing and the generated SQL.
- `ReadMegaMekTest.readsMotiveTypes`: the importer.
- `UnitServiceImportTest.searchesImportedVehiclesByMotiveType`: imports fixtures, then searches `tracked` / `hovercraft` / `tanks` end to end.

## Ideas not done

- Tokens for WiGE / naval / submarine / hydrofoil searches.
- Motive type for support vehicles, which aren't imported yet (importers skill, bug 13).
