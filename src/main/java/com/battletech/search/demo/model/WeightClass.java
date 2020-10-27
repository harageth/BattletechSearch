package com.battletech.search.demo.model;

public enum WeightClass {
  ULTRA_LIGHT("Ultra Light"),
  LIGHT("Light"),
  MEDIUM("Medium"),
  HEAVY("Heavy"),
  ASSAULT("Assault"),
  ULTRA_HEAVY("Ultra Heavy");

  private String text;

  WeightClass(String text) {
    this.text = text;
  }

  public String getText() {
    return this.text;
  }

  public static WeightClass fromString(String text) {
    for (WeightClass b : WeightClass.values()) {
      if (b.text.equalsIgnoreCase(text)) {
        return b;
      }
    }
    return null;
  }
}
