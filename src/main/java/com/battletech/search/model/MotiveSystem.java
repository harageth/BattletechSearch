package com.battletech.search.model;

import java.util.Set;

// MegaMek's <motion_type> values; stored by name
public enum MotiveSystem {
  Tracked,
  Wheeled,
  Hover,
  VTOL,
  Naval,
  Hydrofoil,
  Submarine,
  WiGE,
  Aerodyne,
  Rail;

  // vehicles MegaMek files as tanks that aren't ground vehicles
  public static final Set<MotiveSystem> WATER = Set.of(Naval, Hydrofoil, Submarine);

  public static MotiveSystem fromString(String text) {
    for (MotiveSystem motive : values()) {
      if (motive.name().equalsIgnoreCase(text.trim())) {
        return motive;
      }
    }
    return null;
  }
}
