package com.battletech.search.model;

/**
 * A unit's engine. Mech files name it ("300 XL (Clan) Engine"); vehicle files give MegaMek's BLK code
 * (<engine_type>, BLKFile.FUSION ...). A large engine is the same type with a rating over 400.
 */
public enum EngineType {
  FUSION("Fusion", 0),
  ICE("ICE", 1),
  XL("XL", 2),
  XXL("XXL", 3),
  LIGHT("Light", 4),
  COMPACT("Compact", 5),
  FUEL_CELL("Fuel Cell", 6),
  FISSION("Fission", 7),
  NONE("None", 8),
  MAGLEV("Maglev", 9),
  STEAM("Steam", 10),
  BATTERY("Battery", 11),
  SOLAR("Solar", 12),
  EXTERNAL("External", 13);

  private final String text;
  private final int blkCode;

  EngineType(String text, int blkCode) {
    this.text = text;
    this.blkCode = blkCode;
  }

  public String getText() {
    return text;
  }

  /** "XL", "Fuel Cell"; without the rating, "Large", the tech or "Engine". */
  public static EngineType fromString(String text) {
    for (EngineType type : values()) {
      if (type.text.equalsIgnoreCase(text.trim())) {
        return type;
      }
    }
    return null;
  }

  public static EngineType fromBlkCode(int code) {
    for (EngineType type : values()) {
      if (type.blkCode == code) {
        return type;
      }
    }
    return null;
  }
}
