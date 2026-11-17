-- Groups for the equipment support vehicles brought in (db/data/V3_22; user, 2026-11-15). Rows only, no new
-- tables. Members are matched by name, as V3_17, so every tech of an item joins.
--   - "infantry weapons": the infantry-scale weapons MegaMek mounts on support vehicles (its
--     weapons/infantry), kept out of the vehicle weapon groups, so "machine guns" or "lasers" don't count a
--     Support Laser or a pintle-mounted infantry machine gun. MegaMek's "Machine Gun (Light)" and "Flamer
--     (Heavy)" are the exception: the importer stores them as the Light Machine Gun and Heavy Flamer (user,
--     2026-11-15), already in their groups.
--   - the Primitive Prototype AC/20 is an autocannon but not a standard one, like the AC/10: it goes in
--     "autocannons" itself. Its ammo goes in "ammo".
--   - support vehicle chassis mods, environmental sealing, industrial equipment and a cargo container join
--     the groups the combat vehicle versions are in
--   - the transport bays, at the end
-- Fire control, satellite imagers, the field kitchen, lifeboat, pintle mount and handheld searchlight stay
-- ungrouped. The new groups' terms are db/data/V3_24.

-- the new group comes right after "pods", the last weapons group, on the guide
UPDATE equipment_group SET position = position + 1 WHERE position > 57;

INSERT INTO equipment_group (id, name, section, position) VALUES
    (gen_random_uuid(), 'infantry weapons', 'WEAPONS', 58);

INSERT INTO equipment_group_member (group_id, equipment_id)
SELECT g.id, e.id FROM (VALUES
    ('infantry weapons', 'supportlaser'),
    ('infantry weapons', 'supportlaser(heavy)'),
    ('infantry weapons', 'supportlaser(semi-portable)'),
    ('infantry weapons', 'machinegun(support)'),
    ('infantry weapons', 'machinegun(semi-portable)'),
    ('infantry weapons', 'auto-rifle(modern,generic)'),
    ('infantry weapons', 'gaussrifle,light(kingdavid)'),
    ('infantry weapons', 'grenadelauncher(auto)'),
    ('infantry weapons', 'grenadelauncher(heavy)'),
    ('infantry weapons', 'recoillessrifle(heavy)'),
    ('infantry weapons', 'srmlauncher(light)'),
    ('infantry weapons', 'srmlauncher(std,two-shot)'),
    ('infantry weapons', 'plasmarifle(man-portable)'),
    ('infantry weapons', 'laserrifle(mauseriicias)'),
    ('infantry weapons', 'tag(light,man-portable)'),
    ('infantry weapons', 'wire-guidedmissilelauncher'),
    ('infantry weapons', 'autocannon(semi-portable)'),
    ('infantry weapons', 'autocannon(bearhuntersuperheavy)'),
    ('autocannons', 'primitiveprototypeautocannon/20'),
    ('ammo', 'primitiveprototypeautocannon/20ammo'),
    ('chassis mods', 'svchassismod[amphibious]'),
    ('chassis mods', 'svchassismod[bicycle]'),
    ('chassis mods', 'svchassismod[convertible]'),
    ('chassis mods', 'svchassismod[dunebuggy]'),
    ('chassis mods', 'svchassismod[hydrofoil]'),
    ('chassis mods', 'svchassismod[monocycle]'),
    ('chassis mods', 'svchassismod[omni]'),
    ('chassis mods', 'svchassismod[snowmobile]'),
    ('chassis mods', 'svchassismod[submersible]'),
    ('chassis mods', 'svchassismod[tractor]'),
    ('chassis mods', 'svchassismod[trailer]'),
    ('chassis mods', 'svchassismod[ultra-light]'),
    ('environmental sealing', 'environmentalsealing'),
    ('industrial equipment', 'sprayer(vehicular)'),
    ('industrial equipment', 'manipulator(non-mech/non-battlearmor)'),
    ('industrial equipment', 'ladder'),
    ('industrial equipment', 'bridgelayer(heavy)'),
    ('industrial equipment', 'fluidsuctionsystem(standard)'),
    ('cargo', 'cargocontainer(10tons)')
) AS v (group_name, equipment_name)
JOIN equipment_group g ON g.name = v.group_name
JOIN equipment e ON e.name = v.equipment_name;

-- Transport bays (Copilot on PR #26; user, 2026-11-15): each bay on a vehicle is its own item, in tons
-- (db/data/V3_22 and V3_25). The cargo bays go under "cargo"; the Infantry Compartment (the "Infantry Bay" until
-- V3_22) moves out of "cargo" into a group of its own, and the vehicle bay, seating and quarters get theirs,
-- after "cargo" on the guide.
UPDATE equipment_group SET position = position + 5 WHERE position > 97;

INSERT INTO equipment_group (id, name, section, position) VALUES
    (gen_random_uuid(), 'cargo bays', NULL, 98),
    (gen_random_uuid(), 'infantry transport', 'EQUIPMENT', 99),
    (gen_random_uuid(), 'vehicle bays', 'EQUIPMENT', 100),
    (gen_random_uuid(), 'seating', 'EQUIPMENT', 101),
    (gen_random_uuid(), 'quarters', 'EQUIPMENT', 102);

INSERT INTO equipment_group_parent (group_id, parent_id)
SELECT g.id, p.id FROM (VALUES
    ('cargo bays', 'cargo')
) AS v (name, parent)
JOIN equipment_group g ON g.name = v.name
JOIN equipment_group p ON p.name = v.parent;

INSERT INTO equipment_group_member (group_id, equipment_id)
SELECT g.id, e.id FROM (VALUES
    ('cargo bays', 'cargobay'),
    ('cargo bays', 'liquidcargobay'),
    ('cargo bays', 'insulatedcargobay'),
    ('cargo bays', 'refrigeratedcargobay'),
    ('cargo bays', 'livestockcargobay'),
    ('vehicle bays', 'lightvehiclebay'),
    ('seating', 'standardseating'),
    ('seating', 'pillionseating'),
    ('seating', 'ejectionseating'),
    ('quarters', 'crewquarters'),
    ('quarters', 'steeragequarters'),
    ('quarters', 'secondclassquarters'),
    ('quarters', 'firstclassquarters')
) AS v (group_name, equipment_name)
JOIN equipment_group g ON g.name = v.group_name
JOIN equipment e ON e.name = v.equipment_name;

WITH moved (group_name, equipment_name) AS (VALUES
    ('infantry transport', 'infantrycompartment')
), out_of_cargo AS (
    DELETE FROM equipment_group_member m
    USING equipment_group a, equipment e, moved
    WHERE m.group_id = a.id AND a.name = 'cargo' AND m.equipment_id = e.id AND e.name = moved.equipment_name
)
INSERT INTO equipment_group_member (group_id, equipment_id)
SELECT g.id, e.id FROM moved
JOIN equipment_group g ON g.name = moved.group_name
JOIN equipment e ON e.name = moved.equipment_name;
