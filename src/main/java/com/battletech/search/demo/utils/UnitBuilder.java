package com.battletech.search.demo.utils;

import com.battletech.search.demo.entities.Mech;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.entities.Vehicle;
import com.battletech.search.demo.entities.Vtol;
import com.battletech.search.demo.model.UnitDecorator;

public class UnitBuilder {

  public static Unit buildUnit(String unitType) {
    UnitDecorator unit = new UnitDecorator();

    if(unitType.equalsIgnoreCase("mech")) {
      unit.setDecoratedUnit(new Mech());
    }else if(unitType.equalsIgnoreCase("vee") | unitType.equalsIgnoreCase("vehicle")) {
      unit.setDecoratedUnit(new Vehicle());
    }else if(unitType.equalsIgnoreCase("VTOL")) {
      unit.setDecoratedUnit(new Vtol());
    }else if(unitType.equalsIgnoreCase("genericunit")) {
      unit.setDecoratedUnit(new Unit());
    }else {
      unit.setDecoratedUnit(new Unit());
    }
    return unit;
  }

}
