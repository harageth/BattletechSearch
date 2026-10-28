-- MegaMek identifiers for each unit, so re-importing updates units instead of duplicating them.
-- Baseline (V2) rows predate these and stay NULL until the data is regenerated.

-- MegaMek's own id for the unit file; the key imports match on
ALTER TABLE unit ADD COLUMN megamek_uuid uuid;
ALTER TABLE unit ADD CONSTRAINT unit_megamek_uuid_key UNIQUE (megamek_uuid);

-- Master Unit List id. Not unique: variants of the same unit can share one, and units that
-- aren't in the MUL (e.g. MegaMek's own designs) have none
ALTER TABLE unit ADD COLUMN mul_id integer;
