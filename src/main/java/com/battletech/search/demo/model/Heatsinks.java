package com.battletech.search.demo.model;

import javax.persistence.Embeddable;
import lombok.Data;

@Data
@Embeddable
public class Heatsinks {
  Tech techType;
  HeatsinkType type;
  int quantity;

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
