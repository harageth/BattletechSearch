-- The equipment group tree moves into the database: "missiles" holds "lrms", which holds "standard lrms",
-- "streak lrms", ... A search can name any level, and a group counts everything under it (utils/EquipmentGroups).
-- The rows are V3_17; the slang terms that name the groups are V3_18 (db/data).

CREATE TABLE equipment_group (
    id       uuid         NOT NULL PRIMARY KEY,
    name     varchar(255) NOT NULL UNIQUE, -- what a search types: "standard lrms"
    section  varchar(255),                 -- top groups only, model/GroupSection: WEAPONS or EQUIPMENT; NULL below
    position integer      NOT NULL         -- order on the search guide
);

-- a group sits under one or more others ("streak lrms" is in "lrms" and "streaks")
CREATE TABLE equipment_group_parent (
    group_id  uuid NOT NULL REFERENCES equipment_group (id) ON DELETE CASCADE,
    parent_id uuid NOT NULL REFERENCES equipment_group (id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, parent_id),
    CHECK (group_id <> parent_id)
);
CREATE INDEX equipment_group_parent_parent ON equipment_group_parent (parent_id);

-- the items in a group itself, every tech its own row; the importer puts a new tech of an item in the
-- groups its other techs are in (services/UnitService)
CREATE TABLE equipment_group_member (
    group_id     uuid NOT NULL REFERENCES equipment_group (id) ON DELETE CASCADE,
    equipment_id uuid NOT NULL REFERENCES equipment (id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, equipment_id)
);
CREATE INDEX equipment_group_member_equipment ON equipment_group_member (equipment_id);

-- a group's term ("lrms", "lrm") names the group, not equipment rows: a search finds what's in it
-- through the tree, so slang_equipment has no links for it
ALTER TABLE slang ADD COLUMN equipment_group_id uuid REFERENCES equipment_group (id) ON DELETE CASCADE;
