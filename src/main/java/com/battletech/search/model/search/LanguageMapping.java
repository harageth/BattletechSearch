package com.battletech.search.model.search;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * This class should be a mapping of various slang terms into system specific
 * terms.
 *
 * LL -> LargeLaser
 * Vee -> Vehicle
 * VSP -> VariableSpeedPulse
 */
public class LanguageMapping {

  public static Map<String, String> slangMap = new HashMap<String, String>();
  public static List<String> searchStrings;

  public static void initialize() {
    slangMap.put("LL", "Large Laser");
  }

}
