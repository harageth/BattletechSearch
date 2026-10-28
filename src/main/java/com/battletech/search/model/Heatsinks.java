package com.battletech.search.model;

import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Data;

@Data
@Embeddable
public class Heatsinks {

  @Enumerated(EnumType.STRING)
  Tech techType;
  @Enumerated(EnumType.STRING)
  HeatsinkType type;
  int heatsinkQuantity; // maybe heatsinks should be equipment like everything else...

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
