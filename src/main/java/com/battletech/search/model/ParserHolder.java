package com.battletech.search.model;

import com.battletech.search.entities.Unit;
import java.util.LinkedList;
import java.util.List;
import lombok.Data;

@Data
public class ParserHolder {
  List<String> errorMessages;
  Unit unit;
  boolean defaultUnit;

  public ParserHolder() {
    errorMessages = new LinkedList();
  }

  public void addError(String message) {
    errorMessages.add(message);
  }
}
