package com.battletech.search.model;

/**
 * What a weapon is mounted on that lets it turn: a turret (a vehicle's turret or VTOL chin turret, a
 * mech's head, shoulder or quad turret), a vehicle's sponson turret or a pintle mount. Stored by name
 * in unit_equipment.turret_mount; the mount itself (Vehicular Sponson Turret, Pintle Mount, a mech's
 * turret) is equipment of its own.
 */
public enum TurretMount {
  TURRET("turret"),
  SPONSON("sponson"),
  PINTLE("pintle");

  // what people type in front of a weapon: "turret lrm 20"
  private final String word;

  TurretMount(String word) {
    this.word = word;
  }

  public String getWord() {
    return word;
  }

  /** A search for weapons on one kind of mount, e.g. "sponson machine gun". */
  public record Filter(TurretMount mount, String rest) {
  }

  /**
   * Splits a leading mount word off a normalized search name: "turretlrm20" -> TURRET on "lrm20",
   * "sponsonmachinegun" -> SPONSON on "machinegun". Returns null when the name doesn't start with one
   * or is nothing else.
   */
  public static Filter fromSearch(String name) {
    for (TurretMount mount : values()) {
      if (name.startsWith(mount.word) && name.length() > mount.word.length()) {
        return new Filter(mount, name.substring(mount.word.length()));
      }
    }
    return null;
  }
}
