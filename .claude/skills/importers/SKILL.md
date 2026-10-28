---
name: importers
description: Use when working on the unit data importers - ReadMegaMek (.mtf mechs, .blk vehicles), ReadPDF (recognition guide), UnitService.persistUnits - or when re-importing or regenerating unit/equipment data, or fixing wrong or missing data in the unit, equipment or unit_equipment tables. Lists known parser bugs (verified against the baseline data) and the order to fix them in.
---

# Importers

Unit data comes from MegaMek files. `utils/ReadMegaMek` parses them, and `services/UnitService.persistUnits` saves them. `utils/ReadPDF` is an unfinished importer for the recognition guide PDF.

## How data gets into the database today

- **Every database gets its units from the frozen dump `db/migration/V2_0__baselineData.sql`.** That's a `pg_dump` of a database that the importer filled in 2020-2021. Fixing a parser changes nothing in the app until the data is regenerated (see "Regenerating data" below).
- **No way to trigger a MegaMek import.** The admin endpoint `POST localhost:8081/actuator/import` (`admin/ImportEndpoint`) only accepts `{"source": "recognition-guide"}`. `persistMechs()` / `persistVehicles()` aren't wired to anything; add them as sources once re-importing no longer duplicates units (bug 1).
- **Configuration.** Paths come from `MEGAMEK_MECHS_PATH`, `MEGAMEK_VEHICLES_PATH` and `RECOGNITION_GUIDE_PDF` (`battletech.import.*` in `application.yml`).
- **Error handling.** A file that throws is logged ("Unable to import ...") and skipped. Most parser bugs show up there as NPEs, not as clear errors.
- **No tests.** Nothing covers the importers yet.

## Known bugs

All of these were checked against the code. The "Data:" lines are from the baseline database.

### Both formats
1. **Re-importing duplicates units.** `persistUnits` never checks whether `name` + `designation` already exists. Unit ids are random UUIDs, so a second run adds every unit again. Data: 11 name/designation pairs already appear twice (e.g. Wasp WSP-1S, Marauder II MAD-5C).
2. **Equipment names are flattened.** `persistUnits` lowercases them and removes spaces (`Medium Laser` → `mediumlaser`). The query side joins words with a space, so `mechs with 2 medium laser` doesn't match. Only `mediumlaser` works, unless `equipment_slang` has a row. That table ships empty. Decide on one normal form and apply it on both the import and query sides.
3. **Annotations stay in equipment names.** Data: 28 equipment names include suffixes, e.g. `mediumlaser(r)` (rear-facing), `srm6(i-os)` / `srm2(os)` (one-shot), `tag(clan)`, `cargo(1ton)`, `rifle(cannon`, `unknowncritical(0xda)`. The vehicle path strips some of these with `.contains("(r)")` checks, but the mech path strips none. A rear `mediumlaser(r)` therefore isn't counted as a `mediumlaser`.
4. **Missing tech gives a third copy of the equipment.** Equipment is de-duplicated by name + tech, and a null tech counts as its own value. Data: 128 equipment rows have null tech, e.g. `erlargelaser` exists as CLAN, INNER_SPHERE and NULL. With per-variant counting, one mech's ER large lasers can be split across rows.

### Mechs (`ReadMechMTF`, `.mtf`)
5. **Mixed-tech mechs get no tech.** `Tech.fromString` only matches the exact strings `Inner Sphere`, `CLAN` and `Mixed Tech`. MTF values like `Mixed (IS Chassis)` match nothing. Data: 236 mechs have null tech (e.g. Trebuchet TBT-9N, Awesome AWS-11H). Their weapons then inherit the null tech; see bug 4.
6. **Weapon tech is lost when a line has no quantity.** In `getWeapons`, the branch for lines without a quantity strips the `IS`/`CL` prefix and then calls `getTechType` again on the stripped name. That returns null, so the computed `tech` is never used.
7. **The fixed field order is fragile.** `readParameter` reads forward until it finds each field in a fixed order. If a field is missing or out of order, the reader runs to the end of the file and hits an NPE, and the whole mech is skipped.
8. **Armor and critical slots aren't imported.** Armor is totaled and thrown away, and the slot layout isn't read.
9. **Prefix-based tech detection.** `getTechType` treats any name starting with `is`/`cl` as Inner Sphere/Clan. A non-prefixed name that happens to start with those letters would be misread. This is unverified, but worth a test.

### Vehicles (`ReadVehicleBlk`, `.blk`)
10. **Body equipment is never imported.** The code checks `value.get("body")` but reads `value.get("body equipment")`. The check is always null. Data: the only BODY-location rows on vehicles are 321 `infantrybay` entries, which are added separately from `transporters`.
11. **Mixed tech becomes Inner Sphere.** Tech comes from `techType.contains("is")` before checking `cl`/`mixed tech`. `chassis` contains "is", so `Mixed (Clan Chassis)` → INNER_SPHERE, and `MIXED_TECH` is never set. Data: no vehicle has MIXED_TECH.
12. **Motive type is dropped.** `motion_type` is read and thrown away. See the `vehicle-motive-types` skill, which also has the open "what does tank mean" question.
13. **Several unit types are skipped.** Only `Tank` and `VTOL` are imported. `SupportTank`, `SupportVTOL`, `LargeSupportTank` and others are logged and skipped.
14. **Some vehicle stats aren't kept.** Armor type and internal structure type are parsed into unused locals, and total armor is computed and thrown away. Tonnage is truncated (`7.5` → `7`), and only cruise MP is kept.
15. **A dead line in `convertToEquipment`.** `equip.toLowerCase().replaceAll(...)` throws its result away. It's harmless today because `readBlkAllParameters` already lowercases, but it's misleading.

### Recognition guide (`ReadPDF`)
16. **Unfinished and saves nothing.** `convertToUnit` builds a `Mech` and only logs it.
    - It mixes label-based parsing (`Type:`, `Tonnage:`) with line-number parsing (`i == 1` is the name...).
    - It reads only the first weapon line after the weapons header, and `parseEquipment` throws away what it parses.
    - It skips the first 15 pages based on a hard-coded number.
    - Treat it as a separate project: decide whether it's still needed before investing in it.

## Recommended order

1. **Make imports runnable and testable.**
   - Add `mechs` / `vehicles` sources to `ImportEndpoint` (admin port, localhost only). Optionally add a command-line runner too, e.g. `--battletech.import.run=mechs,vehicles`, that runs once and exits.
   - Add unit tests for `ReadMechMTF` / `ReadVehicleBlk` using a few small fixture files in `src/test/resources/megamek/`. Cover a plain IS mech, a Clan omni, a mixed-tech mech, a tank with body + turret equipment, and a VTOL.
   - Make import idempotent: upsert on name + designation (bug 1).
2. **Fix the parsers one bug at a time**, with a fixture test for each. Suggested order: equipment naming (2, 3), then tech (5, 6, 11, 4), then body equipment (10), then motive type (12, needs the tank decision), then the rest.
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
