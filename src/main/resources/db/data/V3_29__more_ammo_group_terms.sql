-- Terms for the ammo groups V3_28 adds ("ac ammo", "gauss ammo", "cluster ammo"), as the slang load makes them: a
-- group's term points at the group and links no rows (as V3_18), only for a group with something stored in it
-- or under it.
-- A group wins over a MegaMek name spelled the same (user, 2026-11-01): MegaMek's "Gauss Ammo" and "AMS Ammo"
-- named one item each and now name the groups, so "gauss ammo" is every gauss bin. A hand-written term keeps
-- its word (user, 2026-11-13); none of these has one. No singulars: no group name ends in "s".
--
-- Each step only changes what isn't done yet. Data migrations after V3_8 update what's stored; see the
-- importers skill.

CREATE TEMPORARY TABLE v3_29_group AS
SELECT g.id, g.name, regexp_replace(g.name, '[^a-z0-9]', '', 'g') AS lookup
FROM equipment_group g
WHERE g.name IN ('ac ammo', 'standard ac ammo', 'lb-x ac ammo', 'ultra ac ammo', 'rotary ac ammo', 'light ac ammo',
    'hvac ammo', 'protomech ac ammo', 'atm ammo', 'improved atm ammo', 'gauss ammo', 'mg ammo', 'artillery ammo',
    'flamer ammo', 'rifle ammo', 'plasma ammo', 'chemical laser ammo', 'ams ammo', 'narc ammo', 'er atm ammo',
    'he atm ammo', 'artemis ammo', 'narc-capable ammo', 'cluster ammo')
  AND EXISTS (SELECT 1 FROM equipment_group_member m
              WHERE m.group_id = g.id
                 OR m.group_id IN (SELECT p.group_id FROM equipment_group_parent p WHERE p.parent_id = g.id));

-- a MegaMek name with the group's key becomes the group's term, without the item it named
DELETE FROM slang_equipment se
USING slang s, v3_29_group g
WHERE se.slang_id = s.id AND s.lookup = g.lookup AND s.kind = 'ALIAS';

UPDATE slang s SET term = g.name, kind = 'FAMILY', equipment_group_id = g.id
FROM v3_29_group g
WHERE s.lookup = g.lookup AND s.kind = 'ALIAS';

INSERT INTO slang (id, term, lookup, kind, equipment_group_id)
SELECT gen_random_uuid(), g.name, g.lookup, 'FAMILY', g.id
FROM v3_29_group g
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = g.lookup);

DROP TABLE v3_29_group;
