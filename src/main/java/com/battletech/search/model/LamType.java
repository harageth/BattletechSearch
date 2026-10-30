package com.battletech.search.model;

/** A land-air mech's lam: line. Bimodal LAMs have no AirMech mode. */
public enum LamType {
  STANDARD,
  BIMODAL;

  public static LamType fromString(String text) {
    for (LamType type : values()) {
      if (type.name().equalsIgnoreCase(text.trim())) {
        return type;
      }
    }
    return null;
  }
}
