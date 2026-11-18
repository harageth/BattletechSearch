package com.battletech.search.autocorrect;

import com.battletech.search.utils.EquipmentNames;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import lombok.Value;

/**
 * Every word a search can contain, by its key (EquipmentNames.slangKey: lowercase letters and digits, the
 * key the lookups use): the fixed words of the grammar (weight classes, unit words, comparators, ...) and
 * the words of every equipment name and slang term. A whole name is a word too, matched run together and
 * shown with its spaces ("mediumlaser" is "medium laser").
 * Autocorrect suggests from these; autocomplete can use the same words later.
 */
public final class SearchWords {
  /** A word as it's typed ("medium"), and whether it's a fixed word of the grammar rather than equipment. */
  @Value
  public static class Word {
    String key;
    String text;
    boolean fixed;
  }

  private final Map<String, Word> byKey;

  private SearchWords(Map<String, Word> byKey) {
    this.byKey = byKey;
  }

  /** The words of these phrases ("at least", "medium laser"); a fixed word wins over equipment spelled the same. */
  public static SearchWords of(Collection<String> fixed, Collection<String> equipment) {
    Map<String, Word> byKey = new LinkedHashMap<>();
    fixed.forEach(phrase -> add(byKey, phrase, true));
    equipment.forEach(phrase -> add(byKey, phrase, false));
    return new SearchWords(Collections.unmodifiableMap(byKey));
  }

  private static void add(Map<String, Word> byKey, String phrase, boolean fixed) {
    String typed = phrase.toLowerCase().strip();
    String[] words = typed.split("\\s+");
    for (String word : words) {
      put(byKey, word, fixed);
    }
    if (words.length > 1) {
      put(byKey, String.join(" ", words), fixed);
    }
  }

  private static void put(Map<String, Word> byKey, String word, boolean fixed) {
    // "(vehicle)", "[half]", "light,": suggested without the brackets and punctuation around it
    String text = word.replaceAll("^[(\\[]+|[)\\],]+$", "");
    String key = EquipmentNames.slangKey(text);
    // a number is never misspelled
    if (key.isEmpty() || key.chars().allMatch(Character::isDigit)) {
      return;
    }
    Word known = byKey.get(key);
    if (known == null || (fixed && !known.isFixed())) {
      byKey.put(key, new Word(key, text, fixed));
    }
  }

  public boolean contains(String key) {
    return byKey.containsKey(key);
  }

  public Word get(String key) {
    return byKey.get(key);
  }

  public Collection<Word> all() {
    return byKey.values();
  }
}
