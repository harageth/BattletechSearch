-- Names and terms for the support vehicles' equipment (db/data/V3_22, groups V3_23; user, 2026-11-15):
--   1. terms for the "infantry weapons" group, and its singular ("an infantry weapon"), as the slang load
--      makes them
--   2. names shown the way V3_21 shows bracketed items (user, 2026-11-14 and 2026-11-15): a bracket holding a
--      size or kind goes in front ("Support Laser (Heavy)" is the Heavy Support Laser), a chassis mod is a
--      chassis ("Tractor Chassis"), and a comma inside a bracket, which a search can't type, goes ("Gauss
--      Rifle, Light (King David)" is the King David Gauss Rifle). A bracket holding a brand stays ("Laser
--      Rifle (Mauser IIC IAS)"), and so does "Cargo Container (10 tons)": a number in front would read as a
--      quantity.
--   3. each of those names gets a term that finds it
-- The names stay, so imports still match them.
--
-- Each step only changes what isn't done yet. Data migrations after V3_8 update what's stored; see the
-- importers skill.

-- 1. A group's term points at the group and links no rows (as V3_18); only once something is in the group
INSERT INTO slang (id, term, lookup, kind, equipment_group_id)
SELECT gen_random_uuid(), v.term, v.lookup, v.kind, g.id
FROM (VALUES
    ('infantry weapons', 'infantryweapons', 'FAMILY'),
    ('infantry weapon', 'infantryweapon', 'FAMILY_SINGULAR')
) AS v (term, lookup, kind)
JOIN equipment_group g ON g.name = 'infantry weapons'
WHERE EXISTS (SELECT 1 FROM equipment_group_member m WHERE m.group_id = g.id)
  AND NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = v.lookup);

-- 2.
UPDATE equipment e SET display_name = v.display_name
FROM (VALUES
    ('supportlaser(heavy)', 'Heavy Support Laser'),
    ('supportlaser(semi-portable)', 'Semi-Portable Support Laser'),
    ('machinegun(support)', 'Support Machine Gun'),
    ('machinegun(semi-portable)', 'Semi-Portable Machine Gun'),
    ('grenadelauncher(auto)', 'Auto Grenade Launcher'),
    ('grenadelauncher(heavy)', 'Heavy Grenade Launcher'),
    ('recoillessrifle(heavy)', 'Heavy Recoilless Rifle'),
    ('srmlauncher(light)', 'Light SRM Launcher'),
    ('srmlauncher(std,two-shot)', 'Two-Shot SRM Launcher'),
    ('plasmarifle(man-portable)', 'Man-Portable Plasma Rifle'),
    ('tag(light,man-portable)', 'Man-Portable TAG'),
    ('autocannon(semi-portable)', 'Semi-Portable Autocannon'),
    ('gaussrifle,light(kingdavid)', 'King David Gauss Rifle'),
    ('auto-rifle(modern,generic)', 'Auto-Rifle'),
    ('bridgelayer(heavy)', 'Heavy Bridge Layer'),
    ('sprayer(vehicular)', 'Vehicular Sprayer'),
    ('fluidsuctionsystem(standard)', 'Standard Fluid Suction System'),
    ('searchlight(handheld)', 'Handheld Searchlight'),
    ('lifeboat(maritime)', 'Maritime Lifeboat'),
    ('satelliteimager(infraredimager)', 'Infrared Satellite Imager'),
    ('satelliteimager(high-resolutionimager)', 'High-Resolution Satellite Imager'),
    ('manipulator(non-mech/non-battlearmor)', 'Vehicle Manipulator'),
    ('svchassismod[amphibious]', 'Amphibious Chassis'),
    ('svchassismod[bicycle]', 'Bicycle Chassis'),
    ('svchassismod[convertible]', 'Convertible Chassis'),
    ('svchassismod[dunebuggy]', 'Dune Buggy Chassis'),
    ('svchassismod[hydrofoil]', 'Hydrofoil Chassis'),
    ('svchassismod[monocycle]', 'Monocycle Chassis'),
    ('svchassismod[omni]', 'OmniVehicle Chassis'),
    ('svchassismod[snowmobile]', 'Snowmobile Chassis'),
    ('svchassismod[submersible]', 'Submersible Chassis'),
    ('svchassismod[tractor]', 'Tractor Chassis'),
    ('svchassismod[trailer]', 'Trailer Chassis'),
    ('svchassismod[ultra-light]', 'Ultra-Light Chassis')
) AS v (name, display_name)
WHERE e.name = v.name AND e.display_name IS DISTINCT FROM v.display_name;

-- 3. A MegaMek name with the same key becomes the hand-written term, keeping its links; otherwise the
-- term is added. Either way the slang load leaves it alone from now on (SlangKind.HAND_WRITTEN).
WITH typed (term, lookup) AS (VALUES
    ('heavy support laser', 'heavysupportlaser'),
    ('semi-portable support laser', 'semiportablesupportlaser'),
    ('support machine gun', 'supportmachinegun'),
    ('semi-portable machine gun', 'semiportablemachinegun'),
    ('auto grenade launcher', 'autogrenadelauncher'),
    ('heavy grenade launcher', 'heavygrenadelauncher'),
    ('heavy recoilless rifle', 'heavyrecoillessrifle'),
    ('light srm launcher', 'lightsrmlauncher'),
    ('two-shot srm launcher', 'twoshotsrmlauncher'),
    ('man-portable plasma rifle', 'manportableplasmarifle'),
    ('man-portable tag', 'manportabletag'),
    ('semi-portable autocannon', 'semiportableautocannon'),
    ('king david gauss rifle', 'kingdavidgaussrifle'),
    ('auto-rifle', 'autorifle'),
    ('heavy bridge layer', 'heavybridgelayer'),
    ('vehicular sprayer', 'vehicularsprayer'),
    ('standard fluid suction system', 'standardfluidsuctionsystem'),
    ('handheld searchlight', 'handheldsearchlight'),
    ('maritime lifeboat', 'maritimelifeboat'),
    ('infrared satellite imager', 'infraredsatelliteimager'),
    ('high-resolution satellite imager', 'highresolutionsatelliteimager'),
    ('vehicle manipulator', 'vehiclemanipulator'),
    ('amphibious chassis', 'amphibiouschassis'),
    ('bicycle chassis', 'bicyclechassis'),
    ('convertible chassis', 'convertiblechassis'),
    ('dune buggy chassis', 'dunebuggychassis'),
    ('hydrofoil chassis', 'hydrofoilchassis'),
    ('monocycle chassis', 'monocyclechassis'),
    ('omnivehicle chassis', 'omnivehiclechassis'),
    ('snowmobile chassis', 'snowmobilechassis'),
    ('submersible chassis', 'submersiblechassis'),
    ('tractor chassis', 'tractorchassis'),
    ('trailer chassis', 'trailerchassis'),
    ('ultra-light chassis', 'ultralightchassis')
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
    ('heavysupportlaser', 'supportlaser(heavy)'),
    ('semiportablesupportlaser', 'supportlaser(semi-portable)'),
    ('supportmachinegun', 'machinegun(support)'),
    ('semiportablemachinegun', 'machinegun(semi-portable)'),
    ('autogrenadelauncher', 'grenadelauncher(auto)'),
    ('heavygrenadelauncher', 'grenadelauncher(heavy)'),
    ('heavyrecoillessrifle', 'recoillessrifle(heavy)'),
    ('lightsrmlauncher', 'srmlauncher(light)'),
    ('twoshotsrmlauncher', 'srmlauncher(std,two-shot)'),
    ('manportableplasmarifle', 'plasmarifle(man-portable)'),
    ('manportabletag', 'tag(light,man-portable)'),
    ('semiportableautocannon', 'autocannon(semi-portable)'),
    ('kingdavidgaussrifle', 'gaussrifle,light(kingdavid)'),
    ('autorifle', 'auto-rifle(modern,generic)'),
    ('heavybridgelayer', 'bridgelayer(heavy)'),
    ('vehicularsprayer', 'sprayer(vehicular)'),
    ('standardfluidsuctionsystem', 'fluidsuctionsystem(standard)'),
    ('handheldsearchlight', 'searchlight(handheld)'),
    ('maritimelifeboat', 'lifeboat(maritime)'),
    ('infraredsatelliteimager', 'satelliteimager(infraredimager)'),
    ('highresolutionsatelliteimager', 'satelliteimager(high-resolutionimager)'),
    ('vehiclemanipulator', 'manipulator(non-mech/non-battlearmor)'),
    ('amphibiouschassis', 'svchassismod[amphibious]'),
    ('bicyclechassis', 'svchassismod[bicycle]'),
    ('convertiblechassis', 'svchassismod[convertible]'),
    ('dunebuggychassis', 'svchassismod[dunebuggy]'),
    ('hydrofoilchassis', 'svchassismod[hydrofoil]'),
    ('monocyclechassis', 'svchassismod[monocycle]'),
    ('omnivehiclechassis', 'svchassismod[omni]'),
    ('snowmobilechassis', 'svchassismod[snowmobile]'),
    ('submersiblechassis', 'svchassismod[submersible]'),
    ('tractorchassis', 'svchassismod[tractor]'),
    ('trailerchassis', 'svchassismod[trailer]'),
    ('ultralightchassis', 'svchassismod[ultra-light]')
) AS l (lookup, name)
JOIN slang s ON s.lookup = l.lookup AND s.kind = 'SHORTHAND'
JOIN equipment e ON e.name = l.name
WHERE NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id AND x.equipment_id = e.id);

-- a term whose equipment no unit has would match nothing (on a test database with only a few units)
DELETE FROM slang s
WHERE s.kind = 'SHORTHAND' AND NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id);
