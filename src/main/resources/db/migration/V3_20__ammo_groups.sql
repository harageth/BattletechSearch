-- Generic ammo (user, 2026-11-01 and 2026-11-14): "lrm ammo" is every LRM ammo whatever its size, since the
-- weapon asked about says which size. Ammo with its size in the middle of its name ("LRM 20 Ammo") can't be
-- typed as the guide lists it, so the guide shows it under one of these groups, which can. Artemis- and
-- Narc-capable bins get groups of their own under their ammo; "artemis" is Artemis IV and V, as in a search.
-- Rows only, no new tables. The items move out of "ammo" itself, which still counts them through the tree.
-- The groups' slang terms are db/data/V3_21.

-- the new groups come right after "ammo" on the guide
UPDATE equipment_group SET position = position + 22 WHERE position > 58;

INSERT INTO equipment_group (id, name, section, position) VALUES
    (gen_random_uuid(), 'lrm ammo', NULL, 59),
    (gen_random_uuid(), 'enhanced lrm ammo', NULL, 60),
    (gen_random_uuid(), 'extended lrm ammo', NULL, 61),
    (gen_random_uuid(), 'improved lrm ammo', NULL, 62),
    (gen_random_uuid(), 'streak lrm ammo', NULL, 63),
    (gen_random_uuid(), 'artemis lrm ammo', NULL, 64),
    (gen_random_uuid(), 'narc lrm ammo', NULL, 65),
    (gen_random_uuid(), 'srm ammo', NULL, 66),
    (gen_random_uuid(), 'improved srm ammo', NULL, 67),
    (gen_random_uuid(), 'streak srm ammo', NULL, 68),
    (gen_random_uuid(), 'artemis srm ammo', NULL, 69),
    (gen_random_uuid(), 'narc srm ammo', NULL, 70),
    (gen_random_uuid(), 'mml ammo', NULL, 71),
    (gen_random_uuid(), 'artemis mml ammo', NULL, 72),
    (gen_random_uuid(), 'narc mml ammo', NULL, 73),
    (gen_random_uuid(), 'mrm ammo', NULL, 74),
    (gen_random_uuid(), 'lrt ammo', NULL, 75),
    (gen_random_uuid(), 'artemis lrt ammo', NULL, 76),
    (gen_random_uuid(), 'srt ammo', NULL, 77),
    (gen_random_uuid(), 'artemis srt ammo', NULL, 78),
    (gen_random_uuid(), 'thunderbolt ammo', NULL, 79),
    (gen_random_uuid(), 'mortar ammo', NULL, 80);

INSERT INTO equipment_group_parent (group_id, parent_id)
SELECT g.id, p.id FROM (VALUES
    ('lrm ammo', 'ammo'),
    ('enhanced lrm ammo', 'lrm ammo'),
    ('extended lrm ammo', 'lrm ammo'),
    ('improved lrm ammo', 'lrm ammo'),
    ('streak lrm ammo', 'lrm ammo'),
    ('artemis lrm ammo', 'lrm ammo'),
    ('narc lrm ammo', 'lrm ammo'),
    ('srm ammo', 'ammo'),
    ('improved srm ammo', 'srm ammo'),
    ('streak srm ammo', 'srm ammo'),
    ('artemis srm ammo', 'srm ammo'),
    ('narc srm ammo', 'srm ammo'),
    ('mml ammo', 'ammo'),
    ('artemis mml ammo', 'mml ammo'),
    ('narc mml ammo', 'mml ammo'),
    ('mrm ammo', 'ammo'),
    ('lrt ammo', 'ammo'),
    ('artemis lrt ammo', 'lrt ammo'),
    ('srt ammo', 'ammo'),
    ('artemis srt ammo', 'srt ammo'),
    ('thunderbolt ammo', 'ammo'),
    ('mortar ammo', 'ammo')
) AS v (name, parent)
JOIN equipment_group g ON g.name = v.name
JOIN equipment_group p ON p.name = v.parent;

-- each item moves out of "ammo" itself and into its group, every tech of it (matched by name, as V3_17)
WITH moved (group_name, equipment_name) AS (VALUES
    ('lrm ammo', 'lrm5ammo'),
    ('lrm ammo', 'lrm10ammo'),
    ('lrm ammo', 'lrm15ammo'),
    ('lrm ammo', 'lrm20ammo'),
    ('enhanced lrm ammo', 'enhancedlrm5ammo'),
    ('enhanced lrm ammo', 'enhancedlrm10ammo'),
    ('enhanced lrm ammo', 'enhancedlrm15ammo'),
    ('extended lrm ammo', 'extendedlrm5ammo'),
    ('extended lrm ammo', 'extendedlrm10ammo'),
    ('extended lrm ammo', 'extendedlrm15ammo'),
    ('extended lrm ammo', 'extendedlrm20ammo'),
    ('improved lrm ammo', 'improvedlrm10ammo'),
    ('improved lrm ammo', 'improvedlrm15ammo'),
    ('streak lrm ammo', 'streaklrm5ammo'),
    ('streak lrm ammo', 'streaklrm10ammo'),
    ('streak lrm ammo', 'streaklrm15ammo'),
    ('streak lrm ammo', 'streaklrm20ammo'),
    ('artemis lrm ammo', 'ammolrm-5artemis-capable'),
    ('artemis lrm ammo', 'ammolrm-5artemisv-capable'),
    ('artemis lrm ammo', 'ammolrm-10artemis-capable'),
    ('artemis lrm ammo', 'ammolrm-10artemisv-capable'),
    ('artemis lrm ammo', 'ammolrm-15artemis-capable'),
    ('artemis lrm ammo', 'ammolrm-15artemisv-capable'),
    ('artemis lrm ammo', 'ammolrm-20artemis-capable'),
    ('artemis lrm ammo', 'ammolrm-20artemisv-capable'),
    ('artemis lrm ammo', 'enhancedlrm10ammoartemis-capable'),
    ('artemis lrm ammo', 'improvedlrm20ammoartemis-capable'),
    ('narc lrm ammo', 'ammolrm-5narc-capable'),
    ('narc lrm ammo', 'ammolrm-10narc-capable'),
    ('narc lrm ammo', 'ammolrm-15narc-capable'),
    ('narc lrm ammo', 'ammolrm-20narc-capable'),
    ('srm ammo', 'srm2ammo'),
    ('srm ammo', 'srm4ammo'),
    ('srm ammo', 'srm6ammo'),
    ('improved srm ammo', 'improvedsrm6ammo'),
    ('streak srm ammo', 'streaksrm2ammo'),
    ('streak srm ammo', 'streaksrm4ammo'),
    ('streak srm ammo', 'streaksrm6ammo'),
    ('artemis srm ammo', 'ammosrm-2artemisv-capable'),
    ('artemis srm ammo', 'ammosrm-4artemis-capable'),
    ('artemis srm ammo', 'ammosrm-6artemis-capable'),
    ('artemis srm ammo', 'ammosrm-6artemisv-capable'),
    ('narc srm ammo', 'ammosrm-2narc-capable'),
    ('narc srm ammo', 'ammosrm-4narc-capable'),
    ('narc srm ammo', 'ammosrm-6narc-capable'),
    ('mml ammo', 'mml3lrmammo'),
    ('mml ammo', 'mml3srmammo'),
    ('mml ammo', 'mml5lrmammo'),
    ('mml ammo', 'mml5srmammo'),
    ('mml ammo', 'mml7lrmammo'),
    ('mml ammo', 'mml7srmammo'),
    ('mml ammo', 'mml9lrmammo'),
    ('mml ammo', 'mml9srmammo'),
    ('artemis mml ammo', 'ammomml-3lrmartemis-capable'),
    ('artemis mml ammo', 'ammomml-3srmartemis-capable'),
    ('artemis mml ammo', 'ammomml-5lrmartemis-capable'),
    ('artemis mml ammo', 'ammomml-5srmartemis-capable'),
    ('artemis mml ammo', 'ammomml-7lrmartemis-capable'),
    ('artemis mml ammo', 'ammomml-7srmartemis-capable'),
    ('artemis mml ammo', 'ammomml-9lrmartemis-capable'),
    ('artemis mml ammo', 'ammomml-9srmartemis-capable'),
    ('narc mml ammo', 'ammomml-7lrmnarc-capable'),
    ('narc mml ammo', 'ammomml-7srmnarc-capable'),
    ('mrm ammo', 'mrm10ammo'),
    ('mrm ammo', 'mrm20ammo'),
    ('mrm ammo', 'mrm30ammo'),
    ('mrm ammo', 'mrm40ammo'),
    ('lrt ammo', 'lrt5ammo'),
    ('lrt ammo', 'lrt10ammo'),
    ('lrt ammo', 'lrt15ammo'),
    ('lrt ammo', 'lrt20ammo'),
    ('artemis lrt ammo', 'ammolrtorpedo-10artemis-capable'),
    ('artemis lrt ammo', 'ammolrtorpedo-15artemis-capable'),
    ('artemis lrt ammo', 'ammolrtorpedo-15artemisv-capable'),
    ('srt ammo', 'srt2ammo'),
    ('srt ammo', 'srt4ammo'),
    ('srt ammo', 'srt6ammo'),
    ('artemis srt ammo', 'ammosrtorpedo-4artemis-capable'),
    ('thunderbolt ammo', 'thunderbolt5ammo'),
    ('thunderbolt ammo', 'thunderbolt10ammo'),
    ('thunderbolt ammo', 'thunderbolt15ammo'),
    ('thunderbolt ammo', 'thunderbolt20ammo'),
    ('mortar ammo', 'shapedchargemortar1ammo'),
    ('mortar ammo', 'shapedchargemortar2ammo'),
    ('mortar ammo', 'shapedchargemortar4ammo'),
    ('mortar ammo', 'shapedchargemortar8ammo')
), out_of_ammo AS (
    DELETE FROM equipment_group_member m
    USING equipment_group a, equipment e, moved
    WHERE m.group_id = a.id AND a.name = 'ammo' AND m.equipment_id = e.id AND e.name = moved.equipment_name
)
INSERT INTO equipment_group_member (group_id, equipment_id)
SELECT g.id, e.id FROM moved
JOIN equipment_group g ON g.name = moved.group_name
JOIN equipment e ON e.name = moved.equipment_name;

-- Environmental sealing (user, 2026-11-14): the mech's and the combat vehicle's are one group under "chassis
-- mods", so "environmental sealing" is either. They move out of "chassis mods" itself, which still counts them.
UPDATE equipment_group SET position = position + 1 WHERE position > 93;

INSERT INTO equipment_group (id, name, section, position) VALUES
    (gen_random_uuid(), 'environmental sealing', NULL, 94);

INSERT INTO equipment_group_parent (group_id, parent_id)
SELECT g.id, p.id FROM (VALUES
    ('environmental sealing', 'chassis mods')
) AS v (name, parent)
JOIN equipment_group g ON g.name = v.name
JOIN equipment_group p ON p.name = v.parent;

WITH moved (group_name, equipment_name) AS (VALUES
    ('environmental sealing', 'environmentalsealing(mech)'),
    ('environmental sealing', 'combatvehiclechassismod[environmentalsealing]')
), out_of_chassis_mods AS (
    DELETE FROM equipment_group_member m
    USING equipment_group a, equipment e, moved
    WHERE m.group_id = a.id AND a.name = 'chassis mods' AND m.equipment_id = e.id AND e.name = moved.equipment_name
)
INSERT INTO equipment_group_member (group_id, equipment_id)
SELECT g.id, e.id FROM moved
JOIN equipment_group g ON g.name = moved.group_name
JOIN equipment e ON e.name = moved.equipment_name;
