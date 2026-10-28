package com.battletech.search.model;

import jakarta.persistence.Embeddable;
import lombok.Data;

@Data
@Embeddable
public class Heatsinks {

  Tech techType;
  HeatsinkType type;
  int heatsinkQuantity; // maybe heatsinks should be equipment like everything else...

  // stored by ordinal (heatsinks.type is an integer column), so only add new values at the end
  public enum HeatsinkType {
    SINGLE("SINGLE"),
    DOUBLE("DOUBLE"),
    LASER("LASER"),
    COMPACT("COMPACT");

    private String text;

    HeatsinkType(String text) {
      this.text = text;
    }

    public String getText() {
      return this.text;
    }

    public static HeatsinkType fromString(String text) {
      for (HeatsinkType b : HeatsinkType.values()) {
        if (b.text.equalsIgnoreCase(text)) {
          return b;
        }
      }
      return null;
    }
  };

}
