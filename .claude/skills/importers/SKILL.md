---
name: importers
description: Use when working on the unit data importers - ReadMegaMek (.mtf mechs, .blk vehicles), ReadPDF (recognition guide), UnitService.persistUnits - or when re-importing or regenerating unit/equipment data, or fixing wrong or missing data in the unit, equipment or unit_equipment tables. Lists known parser bugs (verified against the baseline data) and the order to fix them in.
---

# Importers

Unit data comes from MegaMek files. `utils/ReadMegaMek` parses them, and `services/UnitService.persistUnits` saves them. `utils/ReadPDF` is an unfinished importer for the recognition guide PDF.

## Data source

MegaMek moved its unit files out of the main `megamek` repo (which now only has test fixtures) into **`MegaMek/mm-data`**. The `mm-data` tags lag far behind (latest `v0.3.1`, Jan 2026), so pin to a commit.

- Local checkout: `C:\Users\adam\workspace\mm-data`. It's a sparse, shallow, blobless clone with only `data/mekfiles/meks` and `data/mekfiles/vehicles`. Re-create it with:
  ```
  git clone --filter=blob:none --sparse --depth 1 https://github.com/MegaMek/mm-data.git mm-data
  cd mm-data && git sparse-checkout set data/mekfiles/meks data/mekfiles/vehicles
  ```
- Pinned commit: `d195e171b3c87801c8dbc5ffcb5f763e5da57483` (2026-10-27, matching MegaMek release v0.51.00.2).
- Point the importer at it: `MEGAMEK_MECHS_PATH=.../mm-data/data/mekfiles/meks`, `MEGAMEK_VEHICLES_PATH=.../mm-data/data/mekfiles/vehicles`.
- Counts at that commit vs the baseline dump:
  - `.mtf` files: 4,263, vs 3,498 mechs.
  - `.blk` files: 1,453, vs 1,032 vehicles.
  - `.blk` `UnitType`: Tank 1086, SupportTank 178, VTOL 131, LargeSupportTank 25, SupportVTOL 24, FixedWingSupport 9.
  - `motion_type`: Tracked 572, Hover 328, Wheeled 314, VTOL 155, WiGE 36, Submarine 15, Naval 9, Aerodyne 9, Rail 8, Hydrofoil 7.
  - MTF `techbase:` values: `Inner Sphere` 2708, `Clan` 1178, `Mixed (IS Chassis)` 257, `Mixed (Clan Chassis)` 120.

### Format changes since the importer was written
- **MTF files no longer start with name/model lines.** They open with a `#` license comment block, then key/value lines: `uuid:`, `generator:`, `chassis:`, `model:`, `mul id:`, `Config:`, `techbase:`, `era:`, `source:`, `published:`, `rules level:`, `role:`, `quirk:`... **Fixed:** `ReadMechMTF` now skips `#` lines and reads fields by key (`readMtfFields`).
- **MTF weapon lines have no `IS`/`CL` prefix and no quantity** (`Medium Laser, Left Arm`; all 22,369 lines at the pinned commit). Each weapon now takes the unit's tech in `persistUnits`. For mixed-tech mechs the per-weapon tech is only in the critical slot listings (`CLERMediumLaser` vs `Large Laser`), so getting it right means reading the slots (bug 6). Rear-facing `(R)` also only appears in the slots. A few names contain `, ` themselves (`Rifle (Cannon, Heavy), Left Torso`); the location is after the last `, `.
- **`era:` is now a year** (e.g. `2755`), not an era name. The column is a string, so map years to era names or store the year. Decide before building era search; see the `query-grammar` skill.
- **Stable ids now exist.** MTF has `uuid:` and `mul id:` (163 of 4,263 mechs have no `mul id:`). BLK has `<UUID>` and `<mul id:>` (`-1` when unknown; 10 of 1,453 vehicles). Use the MegaMek `uuid` as the upsert key instead of name + designation (bug 1). Consider storing `mul id` too, for Master Unit List links.
- BLK keeps the same `<tag>`/`</tag>` structure, and `readBlkAllParameters` already skips `#` lines. Note the key `<mul id:>` includes the colon. New tags: `<UUID>`, `<year>`, `<role>`. Empty values are written on one line (`<Model></Model>`, `<Right Equipment></Right Equipment>`); **fixed:** these now parse as empty values.
- BLK Inner Sphere equipment is no longer prefixed (`Machine Gun`, `IS Ammo AC/2`), while Clan equipment still is (`CLLightMG`, `Clan Streak SRM 4 Ammo`).

## How data gets into the database today

- **Every database gets its units from the frozen dump `db/migration/V2_0__baselineData.sql`.** That's a `pg_dump` of a database that the importer filled in 2020-2021. Fixing a parser changes nothing in the app until the data is regenerated (see "Regenerating data" below).
- **No way to trigger a MegaMek import.** The admin endpoint `POST localhost:8081/actuator/import` (`admin/ImportEndpoint`) only accepts `{"source": "recognition-guide"}`. `persistMechs()` / `persistVehicles()` aren't wired to anything; add them as sources once re-importing no longer duplicates units (bug 1).
- **Configuration.** Paths come from `MEGAMEK_MECHS_PATH`, `MEGAMEK_VEHICLES_PATH` and `RECOGNITION_GUIDE_PDF` (`battletech.import.*` in `application.yml`).
- **Error handling.** A file that throws is logged ("Unable to import ...") and skipped. Most parser bugs show up there as NPEs, not as clear errors.
- **Tests.** `ReadMegaMekTest` parses real files copied from mm-data into `src/test/resources/megamek/` (5 mechs, 6 vehicles). Known bugs those files show are `@Disabled` tests describing the correct result: enable each one with its fix. `ReadMegaMekAllFilesTest` parses every file in the checkout, but only when `MEGAMEK_MECHS_PATH` / `MEGAMEK_VEHICLES_PATH` are set. At the pinned commit: 4,263 mechs and 1,453 vehicles, 0 failures, 236 vehicles skipped (bug 13).

## Known bugs

All of these were checked against the code. The "Data:" lines are from the baseline database.

### Both formats
1. **Re-importing duplicates units.** `persistUnits` never checks whether the unit already exists. Unit ids are random UUIDs, so a second run adds every unit again. Data: 11 name/designation pairs already appear twice (e.g. Wasp WSP-1S, Marauder II MAD-5C). Fix: upsert on MegaMek's `uuid` (see "Format changes" above).
2. **Equipment names are flattened.** `persistUnits` lowercases them and removes spaces (`Medium Laser` → `mediumlaser`). The query side joins words with a space, so `mechs with 2 medium laser` doesn't match. Only `mediumlaser` works, unless `equipment_slang` has a row. That table ships empty. Decide on one normal form and apply it on both the import and query sides.
3. **Annotations stay in equipment names.** Data: 28 equipment names include suffixes, e.g. `mediumlaser(r)` (rear-facing), `srm6(i-os)` / `srm2(os)` (one-shot), `tag(clan)`, `cargo(1ton)`, `rifle(cannon`, `unknowncritical(0xda)`. The vehicle path strips some of these with `.contains("(r)")` checks, but the mech path strips none. A rear `mediumlaser(r)` therefore isn't counted as a `mediumlaser`.
4. **Missing tech gives a third copy of the equipment.** Equipment is de-duplicated by name + tech, and a null tech counts as its own value. Data: 128 equipment rows have null tech, e.g. `erlargelaser` exists as CLAN, INNER_SPHERE and NULL. With per-variant counting, one mech's ER large lasers can be split across rows.

### Mechs (`ReadMechMTF`, `.mtf`)
5. **Mixed-tech mechs get no tech.** `Tech.fromString` only matches the exact strings `Inner Sphere`, `CLAN` and `Mixed Tech`. MTF values like `Mixed (IS Chassis)` match nothing. Data: 236 mechs have null tech (e.g. Trebuchet TBT-9N, Awesome AWS-11H). Their weapons then inherit the null tech; see bug 4.
6. **Per-weapon tech isn't read.** Weapon lines no longer carry an `IS`/`CL` prefix (see "Format changes"), so every weapon gets the unit's tech. That's right for pure IS/Clan mechs but wrong for mixed tech. Fix by reading the critical slot listings (`CLERMediumLaser`). The old prefix code (`getTechType`) is removed.
7. ~~The fixed field order is fragile.~~ **Fixed:** fields are read by key. A missing required field throws an `IOException` naming the file and field.
8. **Armor and critical slots aren't imported.** Armor is totaled and thrown away, and the slot layout isn't read.
9. ~~Prefix-based tech detection for mechs.~~ Obsolete: MTF weapon lines have no prefixes now. The vehicle path still uses `startsWith("is"/"cl")` in `convertToEquipment`.
18. **Double heat sinks aren't recognized.** `Mech.setHeatsinks` takes the type from the second word: `20 IS Double` → `IS`, and `17 Clan Double` → `Clan`, which both map to null. At the pinned commit: IS Double 1981, Clan Double 1280, Single 968, Laser 30, Compact 4. `HeatsinkType` only has SINGLE/DOUBLE.

### Vehicles (`ReadVehicleBlk`, `.blk`)
10. **Body equipment is never imported.** The code checks `value.get("body")` but reads `value.get("body equipment")`. The check is always null. Data: the only BODY-location rows on vehicles are 321 `infantrybay` entries, which are added separately from `transporters`.
11. **Mixed tech becomes Inner Sphere.** Tech comes from `techType.contains("is")` before checking `cl`/`mixed tech`. `chassis` contains "is", so `Mixed (Clan Chassis)` → INNER_SPHERE, and `MIXED_TECH` is never set. Data: no vehicle has MIXED_TECH.
12. **Motive type is dropped.** `motion_type` is read and thrown away. See the `vehicle-motive-types` skill, which also has the open "what does tank mean" question.
13. **Several unit types are skipped.** Only `Tank` and `VTOL` are imported. `SupportTank`, `SupportVTOL`, `LargeSupportTank` and others are logged and skipped.
14. **Some vehicle stats aren't kept.** Armor type and internal structure type are parsed into unused locals, and total armor is computed and thrown away. Tonnage is truncated (`7.5` → `7`), and only cruise MP is kept.
15. **A dead line in `convertToEquipment`.** `equip.toLowerCase().replaceAll(...)` throws its result away. It's harmless today because `readBlkAllParameters` already lowercases, but it's misleading.
17. **Vehicle names and models are lowercased.** `readBlkAllParameters` lowercases every value, so `Bulldog Medium Tank` is stored as `bulldog medium tank`. Data: e.g. `packrat lrpv pkr-t5 (ml)`. Only lowercase the values that need it.

### Recognition guide (`ReadPDF`)
16. **Unfinished and saves nothing.** `convertToUnit` builds a `Mech` and only logs it.
    - It mixes label-based parsing (`Type:`, `Tonnage:`) with line-number parsing (`i == 1` is the name...).
    - It reads only the first weapon line after the weapons header, and `parseEquipment` throws away what it parses.
    - It skips the first 15 pages based on a hard-coded number.
    - Treat it as a separate project: decide whether it's still needed before investing in it.

## Recommended order

1. **Make imports runnable and testable.**
   - Add `mechs` / `vehicles` sources to `ImportEndpoint` (admin port, localhost only). Optionally add a command-line runner too, e.g. `--battletech.import.run=mechs,vehicles`, that runs once and exits.
   - ~~Add fixture tests for `ReadMechMTF` / `ReadVehicleBlk`.~~ Done (see "Tests" above).
   - Make import idempotent: store MegaMek's `uuid` and upsert on it (bug 1). This needs a new column, so it needs a migration.
2. **Fix the parsers one bug at a time**, with a fixture test for each (enable the matching `@Disabled` test). The MTF header change is done. Suggested order: equipment naming (2, 3), then tech (5, 6, 11, 4), then body equipment (10), then motive type (12, needs the tank decision), then the rest.
3. **Regenerate the data** (see below) and compare it with the old baseline.
4. **`ReadPDF`**: finish it or delete it, separately.

## Regenerating data

- Never edit `V1_0` / `V2_0`; existing databases have already applied them. Ship new data as a new migration (`V3_x__...`).
- The new migration can't simply truncate and reload units: unit ids are random, and nothing else references them yet, but check before relying on that. Either:
  - re-import into a scratch database, `pg_dump --data-only` the `unit` / `equipment` / `unit_equipment` / `unit_mech_equipment` tables, and write a migration that truncates them and loads the new dump, or
  - write targeted `UPDATE`s keyed on name + designation for small fixes.
- Record which MegaMek version or commit the data came from in the migration's header comment.
- Before and after, compare counts per `dtype` and `tech`, distinct equipment names, and names matching `[():]`. Re-run `SearchServiceTest`; its pinned results will change, so review each difference instead of blindly updating the expected values.

## Verification queries

```sql
select dtype, tech, count(*) from unit group by 1, 2 order by 1, 2;
select count(*) from equipment where tech is null;
select name from equipment where name ~ '[():]';
select name, designation, count(*) from unit group by 1, 2 having count(*) > 1;
select ue.location, count(*) from unit_equipment ue
  join unit_mech_equipment ume on ue.id = ume.mech_equipment_id
  join unit u on u.id = ume.unit_id
  where u.dtype in ('Tank', 'Vtol') group by 1;
```
