package com.battletech.search.model;

import java.util.EnumSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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
    // LRM, SRM, MML and torpedoes, including improved and enhanced LRMs. Not extended LRMs: no
    // MegaMek unit mounts Artemis on one
    static final String ARTEMIS = "(improved|enhanced)?(lrm|srm|mml|lrt|srt)\\d+";
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

  // what people type before a launcher, longest first so "artemis iv" isn't read as "artemis" + "iv..."
  private static final Map<String, Set<FireControl>> SEARCH_WORDS = new LinkedHashMap<>();
  static {
    SEARCH_WORDS.put("artemis iv", EnumSet.of(ARTEMIS_IV));
    SEARCH_WORDS.put("artemis v", EnumSet.of(ARTEMIS_V));
    SEARCH_WORDS.put("artemis", EnumSet.of(ARTEMIS_IV, ARTEMIS_V));
    SEARCH_WORDS.put("apollo", EnumSet.of(APOLLO));
  }

  /** The words a search can put before a launcher, as typed ("artemis iv"); the search box offers them. */
  public static List<String> searchWords() {
    return List.copyOf(SEARCH_WORDS.keySet());
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
    for (Map.Entry<String, Set<FireControl>> word : SEARCH_WORDS.entrySet()) {
      String prefix = word.getKey().replace(" ", "");
      if (name.startsWith(prefix) && name.length() > prefix.length()) {
        return new Filter(word.getValue(), name.substring(prefix.length()));
      }
    }
    return null;
  }

  /** Whether this fire control fits the launcher, e.g. Artemis on "LRM 20" but not on "Streak SRM 6". */
  public boolean fits(String launcher) {
    return launchers.matcher(launcher.toLowerCase().replaceAll("[^a-z0-9]", "")).matches();
  }
}
