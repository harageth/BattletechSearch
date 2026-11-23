package com.battletech.search.autocorrect;

import java.util.List;
import lombok.Value;

/**
 * What the words in front of the caret may be the start of: up to 8 options, each put in place of the query from
 * its start to stop (the caret), and whether the query is a whole search as it is. Offsets count UTF-16 code
 * units, as the search box does.
 */
@Value
public class Completions {
  int stop;
  List<Option> options;
  boolean complete;

  /** "mechs" in place of the query's text from its start: "heavy me" has it from 6, "heavy medium laser" from 0. */
  @Value
  public static class Option {
    int start;
    String text;
  }
}
