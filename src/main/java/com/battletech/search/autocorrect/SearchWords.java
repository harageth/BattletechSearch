package com.battletech.search.autocorrect;

import com.battletech.search.utils.EquipmentNames;
import java.math.BigInteger;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.Value;

/**
 * Every word a search can contain, by its key (EquipmentNames.slangKey: lowercase letters and digits, the
 * key the lookups use): the fixed words of the grammar (weight classes, unit words, comparators, ...) and
 * the words of every equipment name and slang term. A whole name is a word too, matched run together and
 * shown with its spaces ("mediumlaser" is "medium laser").
 * Autocorrect suggests from these; autocomplete from the whole phrases.
 */
public final class SearchWords {
  /** A word as it's typed ("medium"), and whether it's a fixed word of the grammar rather than equipment. */
  @Value
  public static class Word {
    String key;
    String text;
    boolean fixed;
  }

  /**
   * What a whole phrase is, in the order autocomplete offers them (user, 2026-11-22): words of the grammar,
   * groups, items, and last the grammar's other spellings ("helo", "omnimek"), which would crowd out the rest.
   */
  public enum Kind { FIXED, GROUP, EQUIPMENT, SPELLING }

  /** A whole phrase autocomplete can offer: "at least", "lasers", "medium laser". */
  @Value
  public static class Phrase {
    String key;
    String text;
    Kind kind;
  }

  // a run of digits or of anything else
  private static final Pattern RUN = Pattern.compile("\\d+|\\D+");

  private final Map<String, Word> byKey;
  private final List<Phrase> phrases;

  private SearchWords(Map<String, Word> byKey, List<Phrase> phrases) {
    this.byKey = byKey;
    this.phrases = phrases;
  }

  /** The words of these phrases ("at least", "medium laser"); a fixed word wins over equipment spelled the same. */
  public static SearchWords of(Collection<String> fixed, Collection<String> equipment) {
    return of(fixed, equipment, List.of());
  }

  /** The same, with the whole phrases autocomplete offers. */
  public static SearchWords of(Collection<String> fixed, Collection<String> equipment, List<Phrase> phrases) {
    Map<String, Word> byKey = new LinkedHashMap<>();
    fixed.forEach(phrase -> add(byKey, phrase, true));
    equipment.forEach(phrase -> add(byKey, phrase, false));
    return new SearchWords(Collections.unmodifiableMap(byKey), List.copyOf(phrases));
  }

  /**
   * Whole phrases by kind, then alphabetically with numbers by value ("lrm 5" before "lrm 10"); one spelled the
   * same as an earlier kind's is left out.
   */
  public static List<Phrase> phrases(Collection<String> fixed, Collection<String> groups, Collection<String> equipment,
      Collection<String> spellings) {
    Map<String, Phrase> byKey = new LinkedHashMap<>();
    addPhrases(byKey, fixed, Kind.FIXED);
    addPhrases(byKey, groups, Kind.GROUP);
    addPhrases(byKey, equipment, Kind.EQUIPMENT);
    addPhrases(byKey, spellings, Kind.SPELLING);
    return byKey.values().stream()
        .sorted(Comparator.comparing(Phrase::getKind).thenComparing(Phrase::getText, SearchWords::compareNaturally))
        .toList();
  }

  // alphabetically, but a run of digits by its value: "lrm 5" < "lrm 10" < "lrm 10 ammo"
  static int compareNaturally(String a, String b) {
    Matcher left = RUN.matcher(a);
    Matcher right = RUN.matcher(b);
    while (left.find() && right.find()) {
      String x = left.group();
      String y = right.group();
      int compared = Character.isDigit(x.charAt(0)) && Character.isDigit(y.charAt(0))
          ? new BigInteger(x).compareTo(new BigInteger(y)) : x.compareTo(y);
      if (compared != 0) {
        return compared;
      }
    }
    return Integer.compare(a.length(), b.length()) != 0 ? Integer.compare(a.length(), b.length()) : a.compareTo(b);
  }

  private static void addPhrases(Map<String, Phrase> byKey, Collection<String> phrases, Kind kind) {
    for (String phrase : phrases) {
      String text = phrase.toLowerCase(Locale.ROOT).strip();
      String key = EquipmentNames.slangKey(text);
      if (!key.isEmpty()) {
        byKey.putIfAbsent(key, new Phrase(key, text, kind));
      }
    }
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

  public List<Phrase> phrases() {
    return phrases;
  }
}
