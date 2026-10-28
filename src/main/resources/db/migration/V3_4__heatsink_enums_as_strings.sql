-- Heat sink type and tech were stored by ordinal (JPA's default for the embedded Heatsinks), so
-- reordering an enum would silently change every mech. Store the enum names, like every other enum.
ALTER TABLE unit ALTER COLUMN type TYPE varchar(255) USING CASE type
    WHEN 0 THEN 'SINGLE' WHEN 1 THEN 'DOUBLE' WHEN 2 THEN 'LASER' WHEN 3 THEN 'COMPACT' END;
ALTER TABLE unit ALTER COLUMN tech_type TYPE varchar(255) USING CASE tech_type
    WHEN 0 THEN 'MIXED_TECH' WHEN 1 THEN 'CLAN' WHEN 2 THEN 'INNER_SPHERE' END;
