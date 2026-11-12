---
name: schema-changes
description: Use before proposing or writing any database schema change (DDL - CREATE, ALTER or DROP of a table, column, index or constraint, or a new file in db/migration), and when a PR or plan touches the database. The user's rules - show today's rows next to the proposed ones, prefer the existing schema, show the exact DDL, and draw a diagram of the table and its connected tables.
---

# Schema changes

The user's rules for any change to the database's shape (2026-11-11). Propose first, and write the migration only once the user has seen all of this and agreed.

## 1. Try the existing schema first

- **Show how the data is stored today:** real rows for one or two units from a scratch database, next to what the unit file says.
- **Show the proposed rows next to them.**
- **Separate "the reader writes it wrong" from "the schema can't hold it."** Fix what the importer writes when that covers the need. Propose DDL only for the cases the current shape truly can't hold, and name those cases.
- Example: for equipment locations (2026-11-11), a `unit_equipment_location` table was proposed first. Most of the problem was the reader storing the wrong location in `unit_equipment.location`, so it was fixed with no schema change. The table is only noted for later, for items in several locations (importers skill, bug 30).

## 2. Show the exact DDL

- Show every statement as it will be written: `CREATE TABLE`, `ALTER TABLE`, `DROP`, indexes, constraints, defaults. Never only a summary ("adds a table for groups").
- Say which file it goes in. DDL lives in `db/migration`; `db/data` is only for rows (data migrations).
- Flyway applies versions in order (no out-of-order), so take the next free `V3_n` number after everything already merged or in an open PR, and say which later branches have to be renumbered.
- Never edit a migration that's already merged; existing databases have applied it.

## 3. Draw the table and its connected tables

- Draw each new or changed table and **every table connected to it by a foreign key, in either direction**, marking what's new or changed. A Mermaid `erDiagram` works in the terminal and in PR bodies; for a bigger change, publish it as a diagram page.
- Find the connected tables in a scratch database rather than from memory (replace `unit_equipment` with the table):
  ```sql
  SELECT conrelid::regclass AS from_table, a.attname AS from_column,
         confrelid::regclass AS to_table, af.attname AS to_column
  FROM pg_constraint c
  JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY (c.conkey)
  JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = ANY (c.confkey)
  WHERE c.contype = 'f' AND 'unit_equipment' IN (conrelid::regclass::text, confrelid::regclass::text)
  ORDER BY 1, 2;
  ```
  Add `\d <table>` for the columns. The foreign keys at V3_16: `unit_equipment` → `equipment`; `unit_mech_equipment` → `unit` and → `unit_equipment` (it joins **every** unit, vehicles too, to its items); `slang_equipment` → `slang` and → `equipment` (both `ON DELETE CASCADE`). Some links have no constraint: `ambiguous_slang.equipment_name` names equipment by name, and enums are stored as strings, with no lookup tables. Show those links in the diagram too, and say they have no constraint.
- Example, the slang tables from `V3_6`:
  ```mermaid
  erDiagram
    slang ||--o{ slang_equipment : "slang_id"
    equipment ||--o{ slang_equipment : "equipment_id"
    slang {
      uuid id PK
      varchar term
      varchar lookup UK
      varchar kind
    }
    slang_equipment {
      uuid slang_id FK
      uuid equipment_id FK
    }
    equipment {
      uuid id PK
      varchar name
      varchar tech
      varchar display_name
    }
  ```

## 4. When there's no DDL

Say so plainly, in the answer and the PR body ("No DDL: nothing in `db/migration`"), and list what the data migrations touch instead: which tables, how many rows, insert, update or delete. Example: `V3_16__equipment_groups.sql` deletes 5 `slang` terms and inserts 107 terms and 1,257 `slang_equipment` links, and touches no unit or equipment rows.
