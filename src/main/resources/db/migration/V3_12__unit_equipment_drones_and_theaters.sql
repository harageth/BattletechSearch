-- How many drones a drone carrier control system runs ("DroneCarrierControlSystem:SIZE:6.0") and how many
-- operating theaters a MASH has ("MASH Equipment:SIZE:5.0"), each its own column like jump_boost (V3_3),
-- not tonnage. Null for every other item.
ALTER TABLE unit_equipment ADD COLUMN drones integer;
ALTER TABLE unit_equipment ADD COLUMN mash_theaters integer;
