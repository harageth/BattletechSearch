package com.battletech.search.model;

public enum Locomotion {
  BIPED("BIPED"),
  QUAD("QUAD");

  private String text;

  Locomotion(String text) {
    this.text = text;
  }

  public String getText() {
    return this.text;
  }

  public static Locomotion fromString(String text) {
    for (Locomotion b : Locomotion.values()) {
      if (b.text.equalsIgnoreCase(text)) {
        return b;
      }
    }
    return null;
  }
}
