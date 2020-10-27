package com.battletech.search.demo.utils;

import com.battletech.search.demo.entities.Mech;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.model.UnitDecorator;

public class UnitBuilder {

  public static Unit buildUnit(String unitType) {
    UnitDecorator unit = new UnitDecorator();

    if(unitType.equalsIgnoreCase("mechs")) {
      unit.setDecoratedUnit(new Mech());
    }else if(unitType.equalsIgnoreCase("vee") | unitType.equalsIgnoreCase("vehicle")) {
      // new vehicle
    }else if(unitType.equalsIgnoreCase("mechs")) {

    }else if(unitType.equalsIgnoreCase("mechs")) {

    }else if(unitType.equalsIgnoreCase("mechs")) {

    }
    return unit;
  }

}
