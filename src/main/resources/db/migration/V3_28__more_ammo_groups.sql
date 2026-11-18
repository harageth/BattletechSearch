-- More generic ammo (user, 2026-11-17), like V3_20's "lrm ammo": a group for the ammo of each weapon group, so
-- "ac ammo" or "gauss ammo" counts every size and kind. AC ammo is split the way the autocannons are, and iATM
-- ammo is under ATM ammo as improved ATMs are under ATMs. Where one item has the natural name, the group takes
-- a short one (user, 2026-11-17): "gauss ammo" is every gauss bin, "gauss rifle ammo" still the Gauss Rifle's;
-- "mg ammo" every machine gun's, "machine gun ammo" the Machine Gun's (V3_19); "narc ammo" both kinds of pods,
-- "narc pods" the Narc's. Arrow IV ammo is in "artillery ammo", and "arrow iv ammo" stays the Arrow IV's.
-- Ammo also has groups by kind, across weapons (user, 2026-11-18): "artemis ammo" and "narc-capable ammo" hold
-- V3_20's Artemis- and Narc-capable groups of each launcher (a second parent, as "streak lrms" has), "cluster
-- ammo" the LB-X and Arrow IV cluster bins (in their weapon's group too), and ATM ammo splits into "er atm ammo"
-- and "he atm ammo". Only kinds a unit file names: MegaMek's files don't say which units carry smoke,
-- incendiary or other special munitions, which are picked when a game is set up.
-- Rows only, no new tables. The items move out of "ammo" itself, which still counts them through the tree;
-- the fluid gun, nail/rivet gun and taser ammo stay there. The groups' slang terms are db/data/V3_29.

-- the new groups come right after "mortar ammo", the last ammo group, on the guide
UPDATE equipment_group SET position = position + 24 WHERE position > 81;

INSERT INTO equipment_group (id, name, section, position) VALUES
    (gen_random_uuid(), 'ac ammo', NULL, 82),
    (gen_random_uuid(), 'standard ac ammo', NULL, 83),
    (gen_random_uuid(), 'lb-x ac ammo', NULL, 84),
    (gen_random_uuid(), 'ultra ac ammo', NULL, 85),
    (gen_random_uuid(), 'rotary ac ammo', NULL, 86),
    (gen_random_uuid(), 'light ac ammo', NULL, 87),
    (gen_random_uuid(), 'hvac ammo', NULL, 88),
    (gen_random_uuid(), 'protomech ac ammo', NULL, 89),
    (gen_random_uuid(), 'atm ammo', NULL, 90),
    (gen_random_uuid(), 'er atm ammo', NULL, 91),
    (gen_random_uuid(), 'he atm ammo', NULL, 92),
    (gen_random_uuid(), 'improved atm ammo', NULL, 93),
    (gen_random_uuid(), 'gauss ammo', NULL, 94),
    (gen_random_uuid(), 'mg ammo', NULL, 95),
    (gen_random_uuid(), 'artillery ammo', NULL, 96),
    (gen_random_uuid(), 'flamer ammo', NULL, 97),
    (gen_random_uuid(), 'rifle ammo', NULL, 98),
    (gen_random_uuid(), 'plasma ammo', NULL, 99),
    (gen_random_uuid(), 'chemical laser ammo', NULL, 100),
    (gen_random_uuid(), 'ams ammo', NULL, 101),
    (gen_random_uuid(), 'narc ammo', NULL, 102),
    (gen_random_uuid(), 'artemis ammo', NULL, 103),
    (gen_random_uuid(), 'narc-capable ammo', NULL, 104),
    (gen_random_uuid(), 'cluster ammo', NULL, 105);

INSERT INTO equipment_group_parent (group_id, parent_id)
SELECT g.id, p.id FROM (VALUES
    ('ac ammo', 'ammo'),
    ('standard ac ammo', 'ac ammo'),
    ('lb-x ac ammo', 'ac ammo'),
    ('ultra ac ammo', 'ac ammo'),
    ('rotary ac ammo', 'ac ammo'),
    ('light ac ammo', 'ac ammo'),
    ('hvac ammo', 'ac ammo'),
    ('protomech ac ammo', 'ac ammo'),
    ('atm ammo', 'ammo'),
    ('er atm ammo', 'atm ammo'),
    ('he atm ammo', 'atm ammo'),
    ('improved atm ammo', 'atm ammo'),
    ('gauss ammo', 'ammo'),
    ('mg ammo', 'ammo'),
    ('artillery ammo', 'ammo'),
    ('flamer ammo', 'ammo'),
    ('rifle ammo', 'ammo'),
    ('plasma ammo', 'ammo'),
    ('chemical laser ammo', 'ammo'),
    ('ams ammo', 'ammo'),
    ('narc ammo', 'ammo'),
    ('artemis ammo', 'ammo'),
    ('artemis lrm ammo', 'artemis ammo'),
    ('artemis srm ammo', 'artemis ammo'),
    ('artemis mml ammo', 'artemis ammo'),
    ('artemis lrt ammo', 'artemis ammo'),
    ('artemis srt ammo', 'artemis ammo'),
    ('narc-capable ammo', 'ammo'),
    ('narc lrm ammo', 'narc-capable ammo'),
    ('narc srm ammo', 'narc-capable ammo'),
    ('narc mml ammo', 'narc-capable ammo'),
    ('cluster ammo', 'ammo')
) AS v (name, parent)
JOIN equipment_group g ON g.name = v.name
JOIN equipment_group p ON p.name = v.parent;

-- each item moves out of "ammo" itself and into its group, every tech of it (matched by name, as V3_17)
WITH moved (group_name, equipment_name) AS (VALUES
    ('standard ac ammo', 'ac/2ammo'),
    ('standard ac ammo', 'ac/5ammo'),
    ('standard ac ammo', 'ac/10ammo'),
    ('standard ac ammo', 'ac/20ammo'),
    ('lb-x ac ammo', 'lb2-xacammo'),
    ('lb-x ac ammo', 'lb5-xacammo'),
    ('lb-x ac ammo', 'lb10-xacammo'),
    ('lb-x ac ammo', 'lb20-xacammo'),
    ('lb-x ac ammo', 'lb2-xclusterammo'),
    ('lb-x ac ammo', 'lb5-xclusterammo'),
    ('lb-x ac ammo', 'lb10-xclusterammo'),
    ('lb-x ac ammo', 'lb20-xclusterammo'),
    ('ultra ac ammo', 'ultraac/2ammo'),
    ('ultra ac ammo', 'ultraac/5ammo'),
    ('ultra ac ammo', 'ultraac/10ammo'),
    ('ultra ac ammo', 'ultraac/20ammo'),
    ('rotary ac ammo', 'rotaryac/2ammo'),
    ('rotary ac ammo', 'rotaryac/5ammo'),
    ('light ac ammo', 'lac/2ammo'),
    ('light ac ammo', 'lac/5ammo'),
    ('hvac ammo', 'hvac/2ammo'),
    ('hvac ammo', 'hvac/5ammo'),
    ('hvac ammo', 'hvac/10ammo'),
    ('protomech ac ammo', 'protomechac/2ammo'),
    ('protomech ac ammo', 'protomechac/4ammo'),
    ('protomech ac ammo', 'protomechac/8ammo'),
    ('ac ammo', 'primitiveprototypeautocannon/10ammo'),
    ('ac ammo', 'primitiveprototypeautocannon/20ammo'),
    ('atm ammo', 'standardatm/3ammo'),
    ('atm ammo', 'standardatm/6ammo'),
    ('atm ammo', 'standardatm/9ammo'),
    ('atm ammo', 'standardatm/12ammo'),
    ('er atm ammo', 'extended-rangeatm/3ammo'),
    ('er atm ammo', 'extended-rangeatm/6ammo'),
    ('er atm ammo', 'extended-rangeatm/9ammo'),
    ('er atm ammo', 'extended-rangeatm/12ammo'),
    ('he atm ammo', 'high-explosiveatm/3ammo'),
    ('he atm ammo', 'high-explosiveatm/6ammo'),
    ('he atm ammo', 'high-explosiveatm/9ammo'),
    ('he atm ammo', 'high-explosiveatm/12ammo'),
    ('improved atm ammo', 'standardiatm/3ammo'),
    ('improved atm ammo', 'standardiatm/9ammo'),
    ('improved atm ammo', 'standardiatm/12ammo'),
    ('gauss ammo', 'gaussrifleammo'),
    ('gauss ammo', 'lightgaussrifleammo'),
    ('gauss ammo', 'heavygaussrifleammo'),
    ('gauss ammo', 'improvedgaussrifleammo'),
    ('gauss ammo', 'improvedheavygaussrifleammo'),
    ('gauss ammo', 'anti-personnelgaussrifleammo'),
    ('gauss ammo', 'magshotgaussrifleammo'),
    ('gauss ammo', 'silverbulletgaussrifleammo'),
    ('gauss ammo', 'hyper-assaultgaussrifle/20ammo'),
    ('gauss ammo', 'hyper-assaultgaussrifle/30ammo'),
    ('gauss ammo', 'hyper-assaultgaussrifle/40ammo'),
    ('mg ammo', 'machinegunammo[full]'),
    ('mg ammo', 'machinegunammo[half]'),
    ('mg ammo', 'lightmachinegunammo[full]'),
    ('mg ammo', 'lightmachinegunammo[half]'),
    ('mg ammo', 'heavymachinegunammo[full]'),
    ('mg ammo', 'heavymachinegunammo[half]'),
    ('artillery ammo', 'arrowivammo'),
    ('artillery ammo', 'arrowivclusterammo'),
    ('artillery ammo', 'arrowivhomingammo'),
    ('artillery ammo', 'longtomammo'),
    ('artillery ammo', 'longtomcannonammo'),
    ('artillery ammo', 'sniperammo'),
    ('artillery ammo', 'snipercannonammo'),
    ('artillery ammo', 'thumperammo'),
    ('artillery ammo', 'thumpercannonammo'),
    ('artillery ammo', 'cruisemissile/50ammo'),
    ('flamer ammo', 'heavyflamerammo'),
    ('flamer ammo', 'vehicleflamerammo'),
    ('rifle ammo', 'lightrifleammo'),
    ('rifle ammo', 'mediumrifleammo'),
    ('rifle ammo', 'heavyrifleammo'),
    ('plasma ammo', 'plasmarifleammo'),
    ('plasma ammo', 'plasmacannonammo'),
    ('chemical laser ammo', 'largechemicallaserammo'),
    ('chemical laser ammo', 'mediumchemicallaserammo'),
    ('ams ammo', 'anti-missilesystemammo'),
    ('ams ammo', 'riscadvancedpointdefensesystemammo'),
    ('narc ammo', 'narcpods'),
    ('narc ammo', 'inarcpods')
), out_of_ammo AS (
    DELETE FROM equipment_group_member m
    USING equipment_group a, equipment e, moved
    WHERE m.group_id = a.id AND a.name = 'ammo' AND m.equipment_id = e.id AND e.name = moved.equipment_name
)
INSERT INTO equipment_group_member (group_id, equipment_id)
SELECT g.id, e.id FROM moved
JOIN equipment_group g ON g.name = moved.group_name
JOIN equipment e ON e.name = moved.equipment_name;

-- the cluster bins stay in their weapon's ammo group too
INSERT INTO equipment_group_member (group_id, equipment_id)
SELECT g.id, e.id FROM (VALUES
    ('cluster ammo', 'lb2-xclusterammo'),
    ('cluster ammo', 'lb5-xclusterammo'),
    ('cluster ammo', 'lb10-xclusterammo'),
    ('cluster ammo', 'lb20-xclusterammo'),
    ('cluster ammo', 'arrowivclusterammo')
) AS v (group_name, equipment_name)
JOIN equipment_group g ON g.name = v.group_name
JOIN equipment e ON e.name = v.equipment_name;
