-- Artemis IV / Artemis V / Apollo fire control on a missile launcher (FireControl enum name).
-- MegaMek lists these as separate equipment; they're stored on the launcher they upgrade instead.
ALTER TABLE unit_equipment ADD COLUMN fire_control varchar(255);
