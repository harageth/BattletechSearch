-- How a weapon is mounted (TurretMount enum name): TURRET, SPONSON or PINTLE; null when it isn't on one.
-- Vehicle turret weapons are TURRET as well as being in a turret location, so one search covers mechs and vehicles.
ALTER TABLE unit_equipment ADD COLUMN turret_mount varchar(255);
-- never set by any importer (0 rows are true); turret_mount replaces it
ALTER TABLE unit_equipment DROP COLUMN turret_equipped;
