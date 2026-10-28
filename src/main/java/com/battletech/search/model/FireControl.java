package com.battletech.search.model;

import java.util.EnumSet;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Fire control systems that upgrade a single missile launcher. MegaMek lists them as their own
 * equipment next to the launcher; here they're an attribute of the launcher. Stored by name.
 */
public enum FireControl {
  ARTEMIS_IV("artemisiv", 1, Launchers.ARTEMIS),
  ARTEMIS_V("artemisv", 2, Launchers.ARTEMIS),
  APOLLO("apollo", 1, Launchers.APOLLO);

  private static final class Launchers {
    // LRM, SRM, MML and torpedoes, including improved / extended / enhanced LRMs
    static final String ARTEMIS = "(improved|extended|enhanced)?(lrm|srm|mml|lrt|srt)\\d+";
    static final String APOLLO = "mrm\\d+";
  }

  // equipment name with only letters and digits, e.g. "ISArtemisIV" -> "artemisiv" after the prefix
  private final String name;
  // critical slots one takes on a mech: Artemis V's two slots are one system
  private final int slots;
  private final Pattern launchers;

  FireControl(String name, int slots, String launchers) {
    this.name = name;
    this.slots = slots;
    this.launchers = Pattern.compile(launchers);
  }

  public int getSlots() {
    return slots;
  }

  /** The fire control a (prefix-free) equipment name is, or null. */
  public static FireControl fromEquipmentName(String name) {
    String comparable = name.toLowerCase().replaceAll("[^a-z0-9]", "");
    for (FireControl fireControl : values()) {
      if (fireControl.name.equals(comparable)) {
        return fireControl;
      }
    }
    return null;
  }

  /** A search for launchers with one of these fire controls, e.g. "artemis lrm 20". */
  public record Filter(Set<FireControl> fireControls, String launcher) {
  }

  /**
   * Splits a leading fire control off a normalized search name: "artemisivlrm20" -> Artemis IV on
   * "lrm20", "artemislrm20" -> either Artemis on "lrm20", "apollomrm10" -> Apollo on "mrm10".
   * Returns null when the name doesn't start with one.
   */
  public static Filter fromSearch(String name) {
    if (fromEquipmentName(name) != null) {
      // just the system, with no launcher
      return null;
    }
    // longest first, so "artemisiv" isn't read as "artemis" + "iv..."
    if (name.startsWith("artemisiv") && name.length() > 9) {
      return new Filter(EnumSet.of(ARTEMIS_IV), name.substring(9));
    } else if (name.startsWith("artemisv") && name.length() > 8) {
      return new Filter(EnumSet.of(ARTEMIS_V), name.substring(8));
    } else if (name.startsWith("artemis") && name.length() > 7) {
      return new Filter(EnumSet.of(ARTEMIS_IV, ARTEMIS_V), name.substring(7));
    } else if (name.startsWith("apollo") && name.length() > 6) {
      return new Filter(EnumSet.of(APOLLO), name.substring(6));
    }
    return null;
  }

  /** Whether this fire control fits the launcher, e.g. Artemis on "LRM 20" but not on "Streak SRM 6". */
  public boolean fits(String launcher) {
    return launchers.matcher(launcher.toLowerCase().replaceAll("[^a-z0-9]", "")).matches();
  }
}
