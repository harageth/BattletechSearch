package com.battletech.search.model;

import java.util.Set;

/** Where a slang term came from. The slang load rebuilds every kind but the hand-written ones. */
public enum SlangKind {
  // a MegaMek display, internal or lookup name (megamek/equipment-aliases.tsv)
  ALIAS,
  // an equipment group, "lrms" or "missiles" (the equipment_group table); it names the group, not equipment rows
  FAMILY,
  // a group in the singular, "atm", when no equipment already has that name
  FAMILY_SINGULAR,
  // hand-written shorthand, "jj" (db/data V3_19)
  SHORTHAND,
  // added with POST /actuator/slang
  USER;

  /** Written by hand, so the slang load keeps them and nothing it builds takes their lookup. */
  public static final Set<SlangKind> HAND_WRITTEN = Set.of(SHORTHAND, USER);
}
