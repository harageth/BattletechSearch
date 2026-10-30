package com.battletech.search.model;

/**
 * A unit's internal structure. Mech files name it ("IS Endo Steel"); vehicle files give MegaMek's
 * EquipmentType.T_STRUCTURE_* code (<internal_type>). A FrankenMek's hybrid structure has a type
 * per location, which isn't stored.
 */
public enum StructureType {
  STANDARD("Standard", 0),
  INDUSTRIAL("Industrial", 1),
  ENDO_STEEL("Endo Steel", 2),
  ENDO_STEEL_PROTOTYPE("Endo Steel Prototype", 3),
  REINFORCED("Reinforced", 4),
  COMPOSITE("Composite", 5),
  ENDO_COMPOSITE("Endo-Composite", 6),
  HYBRID("Hybrid", -2);

  private final String text;
  private final int code;

  StructureType(String text, int code) {
    this.text = text;
    this.code = code;
  }

  public String getText() {
    return text;
  }

  /** Without the "IS " / "Clan " prefix. */
  public static StructureType fromString(String text) {
    for (StructureType type : values()) {
      if (type.text.equalsIgnoreCase(text.trim())) {
        return type;
      }
    }
    return null;
  }

  /** -1, MegaMek's unknown structure, is standard. */
  public static StructureType fromCode(int code) {
    if (code == -1) {
      return STANDARD;
    }
    for (StructureType type : values()) {
      if (type.code == code) {
        return type;
      }
    }
    return null;
  }
}
