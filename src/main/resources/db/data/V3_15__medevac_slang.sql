-- Adds the medical equipment shorthand (megamek/equipment-slang.tsv, 2026-11-11) to a database loaded by
-- V3_8: "medevac" (also "medvac", "medevac equipment") stands for MASH and paramedic equipment, counted
-- together; "mash" and "paramedic" for each one. The importer loads the same terms after each import
-- (services/SlangLoader); this is for databases nobody re-imports.
--
-- A term is added only if its lookup is free (it's unique) and some unit has the equipment, as the slang
-- load does, and a link only if it's missing, so this also runs on a database that was re-imported since.
-- Data migrations after V3_8 update what's stored; see the importers skill.

INSERT INTO slang (id, term, lookup, kind)
SELECT gen_random_uuid(), t.term, t.lookup, 'SHORTHAND'
FROM (VALUES ('medevac', 'medevac'), ('medvac', 'medvac'), ('medevac equipment', 'medevacequipment'),
             ('mash', 'mash'), ('paramedic', 'paramedic')) AS t (term, lookup)
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = t.lookup);

INSERT INTO slang_equipment (slang_id, equipment_id)
SELECT s.id, e.id
FROM (VALUES ('medevac', 'mashequipment'), ('medevac', 'paramedicequipment'),
             ('medvac', 'mashequipment'), ('medvac', 'paramedicequipment'),
             ('medevacequipment', 'mashequipment'), ('medevacequipment', 'paramedicequipment'),
             ('mash', 'mashequipment'), ('paramedic', 'paramedicequipment')) AS l (lookup, name)
JOIN slang s ON s.lookup = l.lookup AND s.kind = 'SHORTHAND'
JOIN equipment e ON e.name = l.name
WHERE NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id AND x.equipment_id = e.id);

-- a term whose equipment no unit has would match nothing; the slang load leaves those out too
DELETE FROM slang s
WHERE s.kind = 'SHORTHAND' AND s.lookup IN ('medevac', 'medvac', 'medevacequipment', 'mash', 'paramedic')
  AND NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id);
