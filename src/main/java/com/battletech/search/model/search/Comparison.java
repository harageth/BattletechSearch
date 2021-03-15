package com.battletech.search.model.search;

public enum Comparison {
  LESS_THAN("<"),
  GREATER_THAN(">"),
  EQUAL("="),
  EQUAL_OR_GREATER(">="),
  EQUAL_OR_LESS("<=");

  private String text;

  Comparison(String text) {
    this.text = text;
  }

  public String getText() {
    return this.text;
  }

  public static Comparison fromString(String text) {
    for (Comparison b : Comparison.values()) {
      if (b.text.equalsIgnoreCase(text)) {
        return b;
      }
    }
    return null;
  }

  public static Comparison buildComparison(String input) {
    if(input.equalsIgnoreCase("multiple")) {
      // quantity = 1;
      return Comparison.GREATER_THAN;
    }

    return null;
  }
}
