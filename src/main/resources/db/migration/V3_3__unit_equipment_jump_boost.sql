-- The jump MP a mechanical jump booster adds (MegaMek's "MechanicalJumpBooster:SIZE:4.0").
-- Variable-size items measured in tons (cargo, communications equipment, ...) use unit_equipment.tonnage.
ALTER TABLE unit_equipment ADD COLUMN jump_boost integer;
