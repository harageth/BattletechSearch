package com.battletech.search.model.search;

public class FailedParseException extends RuntimeException{
  // an equipment name the grammar took but nothing is called ("ppc heavy mechs"), as the query wrote its
  // words, lowercase; null for other errors. Autocorrect tries moving its last words.
  private final String unknownName;

  public FailedParseException(String message) {
    this(message, null);
  }

  public FailedParseException(String message, String unknownName) {
    super(message);
    this.unknownName = unknownName;
  }

  public String getUnknownName() {
    return unknownName;
  }
}
