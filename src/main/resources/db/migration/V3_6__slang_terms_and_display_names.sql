-- Slang moves into the database: one term stands for many equipment rows, loaded by the importer
-- after the units (services/SlangLoader) from the megamek/*.tsv files.

-- MegaMek's name for showing to people ("LB 10-X AC"); name stays the normalized match key
ALTER TABLE equipment ADD COLUMN display_name varchar(255);

-- empty everywhere: the baseline dump has no rows for it
DROP TABLE equipment_slang;

-- one row per term
CREATE TABLE slang (
    id     uuid         NOT NULL PRIMARY KEY,
    term   varchar(255) NOT NULL,        -- as written: "gauss rifles", "LB 10-X AC", "ams"
    lookup varchar(255) NOT NULL UNIQUE, -- what a search matches: letters and digits, lowercase ("gaussrifles")
    kind   varchar(255) NOT NULL         -- model/SlangKind
);

-- the equipment a term stands for: one term -> many equipment rows. Tech comes from the rows:
-- "lrms" links IS and Clan LRMs, the MegaMek name "cllrm20" only the Clan LRM 20.
CREATE TABLE slang_equipment (
    slang_id     uuid NOT NULL REFERENCES slang (id) ON DELETE CASCADE,
    equipment_id uuid NOT NULL REFERENCES equipment (id) ON DELETE CASCADE,
    PRIMARY KEY (slang_id, equipment_id)
);
CREATE INDEX slang_equipment_equipment ON slang_equipment (equipment_id);

-- keys MegaMek uses for more than one item, so the slang load can't give them one meaning; kept
-- for someone to decide (a line in megamek/equipment-slang.tsv, or POST /actuator/slang)
CREATE TABLE ambiguous_slang (
    lookup         varchar(255) NOT NULL, -- the key both items answer to
    term           varchar(255) NOT NULL, -- as MegaMek wrote it for this candidate
    equipment_name varchar(255) NOT NULL, -- canonical name of one candidate
    PRIMARY KEY (lookup, equipment_name)
);
