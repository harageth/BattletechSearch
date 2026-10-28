-- How a tank moves (Tracked, Wheeled, Hover, Naval...), from MegaMek's <motion_type>.
-- Only set for dtype 'Tank'; baseline (V2) rows stay NULL until the data is regenerated.
ALTER TABLE unit ADD COLUMN motive_system varchar(255);
