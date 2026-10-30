package com.battletech.search.model;

/** A mech's gyro, as MegaMek writes it (Mek.GYRO_STRING). A file without a gyro: line has a standard one. */
public enum GyroType {
  STANDARD("Standard Gyro"),
  XL("XL Gyro"),
  COMPACT("Compact Gyro"),
  HEAVY_DUTY("Heavy Duty Gyro"),
  NONE("None"),
  SUPERHEAVY("Superheavy Gyro");

  private final String text;

  GyroType(String text) {
    this.text = text;
  }

  public String getText() {
    return text;
  }

  public static GyroType fromString(String text) {
    for (GyroType type : values()) {
      if (type.text.equalsIgnoreCase(text.trim())) {
        return type;
      }
    }
    return null;
  }
}
