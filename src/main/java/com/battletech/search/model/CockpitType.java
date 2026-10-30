package com.battletech.search.model;

/** A mech's cockpit, as MegaMek writes it (Mek.COCKPIT_STRING). A file without a cockpit: line has a standard one. */
public enum CockpitType {
  STANDARD("Standard Cockpit"),
  SMALL("Small Cockpit"),
  COMMAND_CONSOLE("Command Console"),
  TORSO_MOUNTED("Torso-Mounted Cockpit"),
  DUAL("Dual Cockpit"),
  INDUSTRIAL("Industrial Cockpit"),
  PRIMITIVE("Primitive Cockpit"),
  PRIMITIVE_INDUSTRIAL("Primitive Industrial Cockpit"),
  SUPERHEAVY("Superheavy Cockpit"),
  SUPERHEAVY_TRIPOD("Superheavy Tripod Cockpit"),
  TRIPOD("Tripod Cockpit"),
  INTERFACE("Interface Cockpit"),
  VIRTUAL_REALITY_PILOTING_POD("Virtual Reality Piloting Pod"),
  QUADVEE("QuadVee Cockpit"),
  SUPERHEAVY_INDUSTRIAL("Superheavy Industrial Cockpit"),
  SUPERHEAVY_COMMAND_CONSOLE("Superheavy Command Console"),
  SMALL_COMMAND_CONSOLE("Small Command Console"),
  TRIPOD_INDUSTRIAL("Tripod Industrial Cockpit"),
  SUPERHEAVY_TRIPOD_INDUSTRIAL("Superheavy Tripod Industrial Cockpit");

  private final String text;

  CockpitType(String text) {
    this.text = text;
  }

  public String getText() {
    return text;
  }

  public static CockpitType fromString(String text) {
    for (CockpitType type : values()) {
      if (type.text.equalsIgnoreCase(text.trim())) {
        return type;
      }
    }
    return null;
  }
}
