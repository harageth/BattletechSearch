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
  // quads; tripods add a center leg
  FRONT_LEFT_LEG("Front Left Leg"),
  FRONT_RIGHT_LEG("Front Right Leg"),
  REAR_LEFT_LEG("Rear Left Leg"),
  REAR_RIGHT_LEG("Rear Right Leg"),
  CENTER_LEG("Center Leg"),
  FRONT("Front"),
  REAR("Rear"),
  LEFT("Left"),
  RIGHT("Right"),
  // superheavy vehicles
  FRONT_LEFT("Front Left"),
  FRONT_RIGHT("Front Right"),
  REAR_LEFT("Rear Left"),
  REAR_RIGHT("Rear Right"),
  FRONTTURRET("Front Turret"),
  REARTURRET("Rear Turret"),
  BODY("Body"),
  // VTOL mast mounts
  ROTOR("Rotor");

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
