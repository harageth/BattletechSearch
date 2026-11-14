-- The hand-written shorthand, once megamek/equipment-slang.tsv, now kept in the slang table: "jj" is a
-- jump jet, "medevac" MASH and paramedic equipment, and a term on several items links them all. The slang
-- load used to rebuild these from the file after each import; now it keeps them, as it keeps slang added
-- with POST /actuator/slang, and the importer links a new tech of an item to the terms its other techs have.
-- Left out: "ams", "c3i" and "vibroblades", which name equipment groups since V3_18.
--
-- A term is added only if its lookup is free (it's unique) and some unit has the equipment, and a link
-- only if it's missing, so this runs on a database that already has these terms from a slang load, and
-- again after a test imports its units (SearchFixtures). Data migrations after V3_8 update what's stored;
-- see the importers skill.

INSERT INTO slang (id, term, lookup, kind)
SELECT gen_random_uuid(), t.term, t.lookup, 'SHORTHAND'
FROM (VALUES
    ('jj', 'jj'),
    ('improved c3 computer', 'improvedc3computer'),
    ('c3 master', 'c3master'),
    ('c3 slave computer', 'c3slavecomputer'),
    ('c3 boosted master', 'c3boostedmaster'),
    ('c3 boosted slave', 'c3boostedslave'),
    ('escape pod', 'escapepod'),
    ('jet booster', 'jetbooster'),
    ('b-pods', 'bpods'),
    ('a-pods', 'apods'),
    ('mechanical jump booster', 'mechanicaljumpbooster'),
    ('machine gun ammo', 'machinegunammo'),
    ('light machine gun ammo', 'lightmachinegunammo'),
    ('heavy machine gun ammo', 'heavymachinegunammo'),
    ('ammo streak-5', 'ammostreak5'),
    ('clan ammo streak-5', 'clanammostreak5'),
    ('gauss rifle magshot', 'gaussriflemagshot'),
    ('magshot gauss rifle', 'magshotgaussrifle'),
    ('pulse laser rifle', 'pulselaserrifle'),
    ('vibro sword', 'vibrosword'),
    ('vibroblade', 'vibroblade'),
    ('medevac', 'medevac'),
    ('medvac', 'medvac'),
    ('medevac equipment', 'medevacequipment'),
    ('mash', 'mash'),
    ('paramedic', 'paramedic')
) AS t (term, lookup)
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = t.lookup);

INSERT INTO slang_equipment (slang_id, equipment_id)
SELECT s.id, e.id
FROM (VALUES
    ('jj', 'jumpjet'),
    ('improvedc3computer', 'improvedc3computer(c3i)'),
    ('c3master', 'c3computer(master)'),
    ('c3slavecomputer', 'c3computer(slave)'),
    ('c3boostedmaster', 'c3boostedsystem(master)'),
    ('c3boostedslave', 'c3boostedsystem(slave)'),
    ('escapepod', 'combatvehicleescapepod'),
    ('jetbooster', 'vtoljetbooster'),
    ('bpods', 'anti-battlearmorpods(b-pods)'),
    ('apods', 'anti-personnelpods(a-pods)'),
    ('mechanicaljumpbooster', 'mechmechanicaljumpboosters'),
    ('mechanicaljumpbooster', 'mechanicaljumpbooster[ba]'),
    ('machinegunammo', 'machinegunammo[full]'),
    ('machinegunammo', 'machinegunammo[half]'),
    ('lightmachinegunammo', 'lightmachinegunammo[full]'),
    ('lightmachinegunammo', 'lightmachinegunammo[half]'),
    ('heavymachinegunammo', 'heavymachinegunammo[full]'),
    ('heavymachinegunammo', 'heavymachinegunammo[half]'),
    ('ammostreak5', 'streaklrm5ammo'),
    ('clanammostreak5', 'streaklrm5ammo'),
    ('gaussriflemagshot', 'magshot'),
    ('gaussriflemagshot', 'gaussrifle[magshot]'),
    ('gaussriflemagshot', 'gaussrifle(magshot)'),
    ('magshotgaussrifle', 'magshot'),
    ('magshotgaussrifle', 'gaussrifle[magshot]'),
    ('magshotgaussrifle', 'gaussrifle(magshot)'),
    ('pulselaserrifle', 'pulselaserrifle(innersphere)'),
    ('pulselaserrifle', 'pulselaserrifle'),
    ('vibrosword', 'blade(vibro-sword,i.s.)'),
    ('vibrosword', 'blade(vibro-sword)'),
    ('vibrosword', 'vibroblade(large)'),
    ('vibrosword', 'vibroblade(medium)'),
    ('vibrosword', 'vibroblade(small)'),
    ('vibroblade', 'vibroblade(large)'),
    ('vibroblade', 'vibroblade(medium)'),
    ('vibroblade', 'vibroblade(small)'),
    ('medevac', 'mashequipment'),
    ('medevac', 'paramedicequipment'),
    ('medvac', 'mashequipment'),
    ('medvac', 'paramedicequipment'),
    ('medevacequipment', 'mashequipment'),
    ('medevacequipment', 'paramedicequipment'),
    ('mash', 'mashequipment'),
    ('paramedic', 'paramedicequipment')
) AS l (lookup, name)
JOIN slang s ON s.lookup = l.lookup AND s.kind = 'SHORTHAND'
JOIN equipment e ON e.name = l.name
WHERE NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id AND x.equipment_id = e.id);

-- a term whose equipment no unit has would match nothing ("pulse laser rifle" on the MegaMek data today)
DELETE FROM slang s
WHERE s.kind = 'SHORTHAND' AND NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id);
