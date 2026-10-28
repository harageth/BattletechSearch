package com.battletech.search.model;

public enum Tech {
  MIXED_TECH("Mixed Tech"),
  CLAN("CLAN"),
  INNER_SPHERE("Inner Sphere");

  private String text;

  Tech(String text) {
    this.text = text;
  }

  public String getText() {
    return this.text;
  }

  public static Tech fromString(String text) {
    for (Tech b : Tech.values()) {
      if (b.text.equalsIgnoreCase(text)) {
        return b;
      }
    }
    return null;
  }

  /**
   * A MegaMek tech base: "Inner Sphere", "Clan" or "Mixed (IS Chassis)" in .mtf files, and
   * "IS Level 2", "Clan Level 3" or "Mixed (Clan Chassis) Experimental" in .blk files.
   */
  public static Tech fromTechBase(String techBase) {
    String text = techBase.trim().toLowerCase();
    if (text.startsWith("mixed")) {
      return MIXED_TECH;
    } else if (text.startsWith("clan")) {
      return CLAN;
    } else if (text.startsWith("inner sphere") || text.startsWith("is ") || text.equals("is")) {
      return INNER_SPHERE;
    }
    return null;
  }

  /** The tech of a unit's chassis, which is the default for equipment that isn't marked IS or Clan. */
  public static Tech chassisTech(String techBase) {
    String text = techBase.toLowerCase();
    if (text.contains("clan chassis")) {
      return CLAN;
    } else if (text.contains("is chassis")) {
      return INNER_SPHERE;
    }
    return fromTechBase(techBase);
  }
}
