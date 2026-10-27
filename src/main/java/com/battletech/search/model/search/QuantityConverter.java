package com.battletech.search.model.search;

import java.util.Map;

/**
 * Converts a QUANTITY token (digits or a number word from the grammar) into an integer.
 */
public class QuantityConverter {
  private static final Map<String, Integer> NUMBER_WORDS = Map.ofEntries(
      Map.entry("a", 1),
      Map.entry("one", 1),
      Map.entry("single", 1),
      Map.entry("two", 2),
      Map.entry("double", 2),
      Map.entry("three", 3),
      Map.entry("triple", 3),
      Map.entry("triplet", 3),
      Map.entry("four", 4),
      Map.entry("five", 5),
      Map.entry("six", 6),
      Map.entry("seven", 7),
      Map.entry("eight", 8),
      Map.entry("nine", 9),
      Map.entry("ten", 10));

  public static int toInt(String quantity) {
    Integer value = NUMBER_WORDS.get(quantity.toLowerCase());
    return value != null ? value : Integer.parseInt(quantity);
  }
}
