package com.battletech.search.model;

/** Where a slang term came from. The slang load replaces every kind but USER. */
public enum SlangKind {
  // a MegaMek display, internal or lookup name (megamek/equipment-aliases.tsv)
  ALIAS,
  // an equipment group, "lrms" or "missiles" (the equipment_group table); it names the group, not equipment rows
  FAMILY,
  // a group in the singular, "atm", when no equipment already has that name
  FAMILY_SINGULAR,
  // hand-written shorthand, "ams" (megamek/equipment-slang.tsv)
  SHORTHAND,
  // added with POST /actuator/slang
  USER
}
