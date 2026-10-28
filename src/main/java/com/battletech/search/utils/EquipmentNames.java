package com.battletech.search.utils;

import java.util.regex.Pattern;

/**
 * The one normal form for equipment names, shared by the importers, search queries and slang, so
 * "Medium Laser", "medium laser" and "MediumLaser" all match "mediumlaser".
 */
public final class EquipmentNames {
  // how a weapon is mounted, not what it is: rear-facing, one-shot, improved one-shot, sponson turret.
  // Annotations that name a different item, like "(Vehicle)" or "(B-Pods)", are kept.
  private static final Pattern MOUNTING = Pattern.compile("\\s*\\((r|os|i-os|ios|st)\\)", Pattern.CASE_INSENSITIVE);

  private EquipmentNames() {
  }

  public static String normalize(String name) {
    return MOUNTING.matcher(name).replaceAll("").toLowerCase().replaceAll("\\s", "");
  }
}
