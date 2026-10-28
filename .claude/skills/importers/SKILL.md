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
- **Running an import.** With the app running and `MEGAMEK_MECHS_PATH` / `MEGAMEK_VEHICLES_PATH` set, `POST localhost:8081/actuator/import` with `{"source": "mechs"}` or `{"source": "vehicles"}` (`admin/ImportEndpoint`, admin port, localhost only). It returns `{"added", "updated", "skipped", "failed"}`. Each file is saved in its own transaction. At the pinned commit: mechs take about 90 s (4,263 added), vehicles about 33 s (1,217 added, 236 skipped). Running it again updates every unit and adds nothing.
- **Configuration.** Paths come from `MEGAMEK_MECHS_PATH`, `MEGAMEK_VEHICLES_PATH` and `RECOGNITION_GUIDE_PDF` (`battletech.import.*` in `application.yml`).
- **Error handling.** A file that throws is logged ("Unable to import ...") and skipped. Most parser bugs show up there as NPEs, not as clear errors.
- **Tests.** `ReadMegaMekTest` parses real files copied from mm-data into `src/test/resources/megamek/` (5 mechs, 6 vehicles). Add a test there with each bug fix. `ReadMegaMekAllFilesTest` parses every file in the checkout, but only when `MEGAMEK_MECHS_PATH` / `MEGAMEK_VEHICLES_PATH` are set. At the pinned commit: 4,263 mechs and 1,453 vehicles, 0 failures, 236 vehicles skipped (bug 13).

## Known bugs

All of these were checked against the code. The "Data:" lines are from the baseline database.

### Both formats
1. ~~Re-importing duplicates units.~~ **Fixed:** `V3_0__unit_megamek_ids.sql` adds `unit.megamek_uuid` (unique) and `unit.mul_id` (not unique). `UnitService.save` finds the stored unit by MegaMek uuid, keeps its database id, swaps in the new equipment and deletes the old equipment rows. Every file at the pinned commit has a unique uuid. MUL ids group variants: the user decided that units sharing a MUL id are variants of the same unit. 163 mechs and 10 vehicles have no MUL id (MegaMek's own units), and 11 MUL ids are shared. `UnitRepository.findByMulId` returns a unit's variants. Verified on a scratch database with a full import run twice: same unit, equipment and unit_equipment counts, and no orphaned rows. Data: the baseline has 11 name/designation pairs that appear twice.
2. ~~Equipment names are flattened.~~ **Fixed:** `utils/EquipmentNames.normalize` (lowercase, no spaces, mounting notes removed) is used on import, for search words and for slang, so `medium laser` matches `mediumlaser`. Numbers after a space (`lrm 20`) still don't parse; see the query-grammar skill.
3. ~~Annotations stay in equipment names.~~ **Fixed for mounting notes:** `(R)`, `(OS)`, `(I-OS)`, `(iOS)` and `(ST)` are stripped by the normalizer. Annotations that name a different item (`(Vehicle)`, `(B-Pods)`, `(Blazer)`, `(Cannon, Heavy)`) are kept. The baseline data still has names like `mediumlaser(r)` until it's regenerated.
4. ~~Missing tech gives a third copy of the equipment.~~ **Fixed in the parsers:** every unit and every piece of equipment now gets a tech (0 nulls across the pinned commit), via `Tech.fromTechBase` / `Tech.chassisTech`. The baseline data still has 128 null-tech equipment rows until it's regenerated.
19. **Some mech weapons have no location.** `Location` has no values for quad, tripod or LAM locations such as `Front Left Leg`. At the pinned commit, 30 weapons get a null location.

### Mechs (`ReadMechMTF`, `.mtf`)
5. ~~Mixed-tech mechs get no tech.~~ **Fixed:** `Tech.fromTechBase` maps `Mixed (IS Chassis)` / `Mixed (Clan Chassis)` to `MIXED_TECH`. At the pinned commit: IS 2708, Clan 1178, Mixed 377.
6. ~~Per-weapon tech isn't read.~~ **Fixed:** weapon lines have no prefix, so `readMtfWeapons` looks for a slot in the same location named with a `CL` / `Clan ` / `IS` prefix that matches the weapon (letters and digits only, so `Ultra AC/10` = `CLUltraAC10`). If there's a match, that's the tech; otherwise it's the chassis tech. Mixed mechs' weapons come out 1,246 Clan and 802 IS.
7. ~~The fixed field order is fragile.~~ **Fixed:** fields are read by key. A missing required field throws an `IOException` naming the file and field.
8. **Armor isn't imported.** ~~Critical slot contents~~ **Partly fixed:** `readMtfSlotEquipment` imports ammo per slot (one ton each; 9,837 tons at the pinned commit) and equipment from an allow-list (`SLOT_EQUIPMENT`: targeting computer, CASE, TSM, MASC, ECM, probes, Artemis, C3 slaves, melee weapons and others; 4,319 items), once per mech each. It's an allow-list because slots also repeat every weapon under different names (`LBXAC10` for `LB 10-X AC`), and those can't be told apart from equipment without MegaMek's equipment tables. C3 master computers are left out because some mechs also list them as weapons. Anything new in mm-data that's not on the list is silently skipped; run `SlotSurvey`-style checks (names that match no weapon in their location) when updating the pinned commit. Mech and vehicle ammo now share names (`IS Ammo LRM-20` and `IS Ammo LRM-20` both become `ammolrm-20`).
9. ~~Prefix-based tech detection for mechs.~~ Obsolete: MTF weapon lines have no prefixes now. The vehicle path still uses `startsWith("is"/"cl")` in `convertToEquipment`. That's safe at the pinned commit: no equipment name starts with those letters without being a prefix.
18. ~~Double heat sinks aren't recognized.~~ **Fixed:** the type is the last word and the tech comes from the `IS`/`Clan` word when present. `HeatsinkType` gained `LASER` and `COMPACT`, added at the end because the column stores the ordinal. At the pinned commit: Double 3261, Single 968, Laser 30, Compact 4.

### Vehicles (`ReadVehicleBlk`, `.blk`)
10. ~~Body equipment is never imported.~~ **Fixed.** In the baseline data, the only BODY rows on vehicles are 321 `infantrybay` entries. At the pinned commit the parser now reads 5,060 body items. Note that these are mostly ammo, CASE and similar: vehicle equipment lists include everything, while mech weapon lists don't include ammo. Decide whether search should ignore ammo, and keep vehicles and mechs consistent.
11. ~~Mixed tech becomes Inner Sphere.~~ **Fixed:** the vehicle tech comes from `Tech.fromTechBase`. At the pinned commit: IS 1009, Clan 171, Mixed 37. Equipment with a `CL`/`Clan`/`IS` prefix gets that tech; anything else gets the chassis tech. **Known limitation:** in mixed *Clan-chassis* vehicles (8 files), IS weapons are unprefixed (`Bombast Laser`), so they're labeled Clan. Pure Clan vehicles also list some Clan-only items unprefixed (`Hyper-Assault Gauss Rifle/30 Ammo`, `VehicleJumpJet`), so "unprefixed = IS" would be worse overall. Fixing this properly needs an equipment lookup table.
12. **Motive type is dropped.** `motion_type` is read and thrown away. See the `vehicle-motive-types` skill, which also has the open "what does tank mean" question.
13. **Several unit types are skipped.** Only `Tank` and `VTOL` are imported. `SupportTank`, `SupportVTOL`, `LargeSupportTank` and others are logged and skipped.
14. **Some vehicle stats aren't kept.** Armor type and internal structure type are parsed into unused locals, and total armor is computed and thrown away. Tonnage is truncated (`7.5` → `7`), and only cruise MP is kept.
15. ~~A dead line in `convertToEquipment`.~~ **Fixed:** it now lowercases the equipment name, which `readBlkAllParameters` no longer does (bug 17).
17. ~~Vehicle names and models are lowercased.~~ **Fixed:** `readBlkAllParameters` keeps values in their original case and only lowercases tag names. The baseline data is still lowercase (e.g. `packrat lrpv pkr-t5 (ml)`) until it's regenerated. `SearchServiceTest` pins some of those names.

### Recognition guide (`ReadPDF`)
16. **Unfinished and saves nothing.** `convertToUnit` builds a `Mech` and only logs it.
    - It mixes label-based parsing (`Type:`, `Tonnage:`) with line-number parsing (`i == 1` is the name...).
    - It reads only the first weapon line after the weapons header, and `parseEquipment` throws away what it parses.
    - It skips the first 15 pages based on a hard-coded number.
    - Treat it as a separate project: decide whether it's still needed before investing in it.

## Recommended order

1. **Make imports runnable and testable.**
   - ~~Add `mechs` / `vehicles` sources to `ImportEndpoint`.~~ Done. A command-line runner is still optional.
   - ~~Add fixture tests for `ReadMechMTF` / `ReadVehicleBlk`.~~ Done (see "Tests" above).
   - ~~Make import idempotent.~~ Done (bug 1).
2. **Fix the parsers one bug at a time**, with a fixture test for each. Done: the MTF header change, plus bugs 1-7, 10, 11, 15, 17 and 18, and mech ammo and equipment (8). Remaining: motive type (12; "tank" is decided as every ground vehicle), then the rest.
3. **Regenerate the data** (see below) and compare it with the old baseline.
4. **`ReadPDF`**: finish it or delete it, separately.

## Regenerating data

**Baseline rows have no `megamek_uuid`.** Importing into a database that has the V2 baseline adds the MegaMek units *next to* the old rows, so every unit appears twice in search (old lowercase/null-tech rows plus the new ones). The database pass needs to replace the baseline: import, then delete the rows where `megamek_uuid IS NULL` (and their `unit_mech_equipment` / `unit_equipment` rows and any unused `equipment`), then dump. Search tests that pin baseline results (`SearchServiceTest`) will change.

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
