package com.battletech.search.demo.model;

public enum Tech {
  MIXED_TECH("Mixed Tech"),
  CLAN("CLAN"),
  INNER_SPHERE("Inner Sphere");

  private String text;

  Tech(String text) {
    this.text = text;
  }

  public String getText() {
    return this.text;
  }

  public static Tech fromString(String text) {
    for (Tech b : Tech.values()) {
      if (b.text.equalsIgnoreCase(text)) {
        return b;
      }
    }
    return null;
  }
}
