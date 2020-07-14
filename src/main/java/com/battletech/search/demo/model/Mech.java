package com.battletech.search.demo.model;

import java.util.Map;

public class Mech extends Unit {

  public Mech() {
    this.setMovement(new Movement());
  }

  Map<Location, Equipment> equipment;
}
