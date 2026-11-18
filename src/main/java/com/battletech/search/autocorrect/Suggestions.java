package com.battletech.search.autocorrect;

import java.util.List;
import lombok.Value;

/**
 * What a search may have meant: the one corrected query (null if there's none), and for each misspelled
 * word, up to 3 words to swap in. Offsets count UTF-16 code units, as the search box does.
 */
@Value
public class Suggestions {
  public static final Suggestions NONE = new Suggestions(null, List.of());

  String query;
  List<WordSuggestion> words;

  /** A misspelled word at [start, stop) of the query, and what it may have been. */
  @Value
  public static class WordSuggestion {
    int start;
    int stop;
    String text;
    List<String> suggestions;
  }
}
