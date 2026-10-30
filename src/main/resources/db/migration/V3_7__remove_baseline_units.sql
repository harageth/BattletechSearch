-- The units from the V2 baseline dump (imported in 2020-2021, no MegaMek uuid) give way to the
-- importer's: run the mechs and vehicles imports after this. Deletes run in foreign-key order.
CREATE TEMP TABLE baseline_items AS
  SELECT um.mech_equipment_id AS id FROM unit_mech_equipment um
  JOIN unit u ON u.id = um.unit_id WHERE u.megamek_uuid IS NULL;
DELETE FROM unit_mech_equipment WHERE unit_id IN (SELECT id FROM unit WHERE megamek_uuid IS NULL);
DELETE FROM unit_equipment WHERE id IN (SELECT id FROM baseline_items);
DELETE FROM unit WHERE megamek_uuid IS NULL;
-- equipment only the baseline used, under its old spellings ("particlecannon", "mediumlaser(r)")
DELETE FROM equipment e WHERE NOT EXISTS (SELECT 1 FROM unit_equipment ue WHERE ue.equipment_id = e.id);
DROP TABLE baseline_items;
