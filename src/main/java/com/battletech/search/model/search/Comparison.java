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

  /** A comparator token's symbolic name (ATLEAST, NOMORE, ...); no comparator (null) means exactly. */
  public static Comparison fromToken(String symbolicName) {
    if(symbolicName == null || symbolicName.isEmpty()) {
      return EQUAL;
    }
    return switch(symbolicName.toUpperCase()) {
      case "ATLEAST" -> EQUAL_OR_GREATER;
      case "NOMORE" -> EQUAL_OR_LESS;
      case "LESSTHANCOMPARATOR" -> LESS_THAN;
      case "GREATERTHANCOMPARATOR" -> GREATER_THAN;
      default -> EQUAL;
    };
  }

  public static Comparison fromString(String text) {
    for (Comparison b : Comparison.values()) {
      if (b.text.equalsIgnoreCase(text)) {
        return b;
      }
    }
    return null;
  }
}
