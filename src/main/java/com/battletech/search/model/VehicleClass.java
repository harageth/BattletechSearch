package com.battletech.search.model;

/**
 * "support vehicles", "combat tanks": which vehicles a vehicle word means. Without either it means both
 * (user, 2026-11-15: support ground vehicles are tanks, support VTOLs are VTOLs).
 */
public enum VehicleClass {
  COMBAT,
  SUPPORT;

  /** "support" or "combat" as typed; null for anything else. */
  public static VehicleClass fromWord(String word) {
    for (VehicleClass vehicleClass : values()) {
      if (vehicleClass.name().equalsIgnoreCase(word.trim())) {
        return vehicleClass;
      }
    }
    return null;
  }
}
