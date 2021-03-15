package com.battletech.search.model;

import javax.persistence.Embeddable;
import lombok.Data;

@Data
@Embeddable
public class Heatsinks {

  Tech techType;
  HeatsinkType type;
  @com.sun.istack.Nullable
  int heatsinkQuantity; // maybe heatsinks should be equipment like everything else...

  public enum HeatsinkType {
    SINGLE("SINGLE"),
    DOUBLE("DOUBLE");

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
