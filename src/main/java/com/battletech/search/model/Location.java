package com.battletech.search.model;

public enum Location {
  RIGHT_TORSO("Right Torso"),
  LEFT_TORSO("Left Torso"),
  CENTER_TORSO("Center Torso"),
  HEAD("Head"),
  RIGHT_ARM("Right Arm"),
  LEFT_ARM("Left Arm"),
  RIGHT_LEG("Right Leg"),
  LEFT_LEG("Left Leg"),
  FRONT("Front"),
  REAR("Rear"),
  LEFT("Left"),
  RIGHT("Right"),
  FRONTTURRET("Front Turret"),
  REARTURRET("Rear Turret"),
  BODY("Body");

  private String text;

  Location(String text) {
    this.text = text;
  }

  public String getText() {
    return this.text;
  };

  public static Location fromString(String text) {
    for (Location b : Location.values()) {
      if (b.text.equalsIgnoreCase(text)) {
        return b;
      }
    }
    return null;
  }
}
