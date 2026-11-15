-- Every name on the search guide can be typed as listed (2026-11-14). The grammar now reads brackets
-- ("flamer (vehicle)"), apostrophes and "triple strength"; this updates what's stored to match:
--   1. names drop apostrophes ("'Mech Mortar 1" is the Mech Mortar 1), as the importer now writes them
--   2. "Rifle (Cannon, Heavy)" and the like are shown as "Heavy Rifle": a comma can't be typed inside a
--      bracket, since commas separate lists (user, 2026-11-14). "Flamer (Vehicle)" is shown as "Vehicle
--      Flamer", which reads better (user, 2026-11-14), like its ammo. The names stay, so imports still match
--      them, and "flamer (vehicle)" still finds it.
--   3. terms for the ammo groups V3_20 adds ("lrm ammo")
--   4. separate-word spellings shown on the guide in place of MegaMek's run-together ones ("large shield",
--      not "LargeShield"), and "blazer" (user, 2026-10-29: binary lasers are just blazers)
--
-- Each step only changes what isn't done yet, so this runs again after a test imports its units
-- (SearchFixtures). Data migrations after V3_8 update what's stored; see the importers skill.

-- 1.
UPDATE equipment SET name = replace(name, '''', ''), display_name = replace(display_name, '''', '')
WHERE name LIKE '%''%' OR display_name LIKE '%''%';

-- 2.
UPDATE equipment e SET display_name = v.display_name
FROM (VALUES
    ('rifle(cannon,light)', 'Light Rifle'),
    ('rifle(cannon,medium)', 'Medium Rifle'),
    ('rifle(cannon,heavy)', 'Heavy Rifle'),
    ('flamer(vehicle)', 'Vehicle Flamer')
) AS v (name, display_name)
WHERE e.name = v.name AND e.display_name IS DISTINCT FROM v.display_name;

-- 3. A group's term points at the group and links no rows (as V3_18); only groups with something stored
INSERT INTO slang (id, term, lookup, kind, equipment_group_id)
SELECT gen_random_uuid(), g.name, replace(g.name, ' ', ''), 'FAMILY', g.id
FROM equipment_group g
WHERE g.name LIKE '% ammo'
  AND EXISTS (SELECT 1 FROM equipment_group_member m
              WHERE m.group_id = g.id
                 OR m.group_id IN (SELECT p.group_id FROM equipment_group_parent p WHERE p.parent_id = g.id))
  AND NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = replace(g.name, ' ', ''));

-- 4. A MegaMek name with the same key becomes the hand-written term, keeping its links; otherwise the
-- term is added. Either way the slang load leaves it alone from now on (SlangKind.HAND_WRITTEN).
WITH typed (term, lookup) AS (VALUES
    ('blazer', 'blazer'),
    ('large shield', 'largeshield'),
    ('medium shield', 'mediumshield'),
    ('small shield', 'smallshield'),
    ('large vibroblade', 'largevibroblade'),
    ('medium vibroblade', 'mediumvibroblade'),
    ('small vibroblade', 'smallvibroblade'),
    ('flotation hull', 'flotationhull'),
    ('fully amphibious', 'fullyamphibious'),
    ('limited amphibious', 'limitedamphibious'),
    ('off-road chassis', 'offroadchassis'),
    ('mech sprayer', 'mechsprayer'),
    ('medium bridge layer', 'mediumbridgelayer'),
    ('ground-mobile hpg', 'groundmobilehpg'),
    ('drone carrier control system', 'dronecarriercontrolsystem'),
    ('drone operating system', 'droneoperatingsystem'),
    ('environmental sealing', 'environmentalsealing')
), taken AS (
    UPDATE slang s SET kind = 'SHORTHAND', term = typed.term
    FROM typed
    WHERE s.lookup = typed.lookup AND s.kind = 'ALIAS'
)
INSERT INTO slang (id, term, lookup, kind)
SELECT gen_random_uuid(), typed.term, typed.lookup, 'SHORTHAND' FROM typed
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = typed.lookup);

INSERT INTO slang_equipment (slang_id, equipment_id)
SELECT s.id, e.id
FROM (VALUES
    ('blazer', 'binarylaser(blazer)cannon'),
    ('largeshield', 'shield(large)'),
    ('mediumshield', 'shield(medium)'),
    ('smallshield', 'shield(small)'),
    ('largevibroblade', 'vibroblade(large)'),
    ('mediumvibroblade', 'vibroblade(medium)'),
    ('smallvibroblade', 'vibroblade(small)'),
    ('flotationhull', 'combatvehiclechassismod[flotationhull]'),
    ('fullyamphibious', 'combatvehiclechassismod[fullyamphibious]'),
    ('limitedamphibious', 'combatvehiclechassismod[limitedamphibious]'),
    ('offroadchassis', 'svchassismod[off-road]'),
    ('mechsprayer', 'sprayer(mech)'),
    ('mediumbridgelayer', 'bridgelayer(medium)'),
    ('groundmobilehpg', 'mobilehyperpulsegenerators(ground-mobilehpg)'),
    ('dronecarriercontrolsystem', 'drone(remote)carriercontrolsystem'),
    ('droneoperatingsystem', 'drone(remote)operatingsystem'),
    ('environmentalsealing', 'environmentalsealing(mech)'),
    ('environmentalsealing', 'combatvehiclechassismod[environmentalsealing]')
) AS l (lookup, name)
JOIN slang s ON s.lookup = l.lookup AND s.kind = 'SHORTHAND'
JOIN equipment e ON e.name = l.name
WHERE NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id AND x.equipment_id = e.id);

-- a term whose equipment no unit has would match nothing (on a test database with only a few units)
DELETE FROM slang s
WHERE s.kind = 'SHORTHAND' AND NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id);
