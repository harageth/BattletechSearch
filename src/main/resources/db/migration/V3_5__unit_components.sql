-- Engine, armor and structure as types (enum names) with their own tech, so units can be found by them
-- ("xl engine", "clan ferro-fibrous"). Baseline (V2) rows stay NULL until the data is regenerated.
ALTER TABLE unit ADD COLUMN engine_type varchar(255);
ALTER TABLE unit ADD COLUMN engine_tech varchar(255);
ALTER TABLE unit ADD COLUMN engine_rating integer;
ALTER TABLE unit ADD COLUMN armor_type varchar(255);
ALTER TABLE unit ADD COLUMN armor_tech varchar(255);
ALTER TABLE unit ADD COLUMN structure_type varchar(255);
ALTER TABLE unit ADD COLUMN structure_tech varchar(255);
-- Mechs only: gyro and cockpit, a LAM's type and a QuadVee's vehicle-mode motive (Tracked / Wheeled).
ALTER TABLE unit ADD COLUMN gyro varchar(255);
ALTER TABLE unit ADD COLUMN cockpit varchar(255);
ALTER TABLE unit ADD COLUMN lam_type varchar(255);
ALTER TABLE unit ADD COLUMN quad_vee_motive varchar(255);
-- The raw mech text ("300 XL Engine", "IS Endo Steel") these replace.
ALTER TABLE unit DROP COLUMN engine;
ALTER TABLE unit DROP COLUMN structure;
