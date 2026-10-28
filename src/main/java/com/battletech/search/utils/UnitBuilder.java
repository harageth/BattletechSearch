package com.battletech.search.utils;

import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.UnitDecorator;
import com.battletech.search.model.MotiveSystem;

public class UnitBuilder {

  public static Unit buildUnit(String unitType) {
    UnitDecorator unit = new UnitDecorator();


    if(unitType.equalsIgnoreCase("mech")) {
      unit.setDecoratedUnit(new Mech());
    }else if(unitType.equalsIgnoreCase("vee") | unitType.equalsIgnoreCase("vehicle")) {
      unit.setDecoratedUnit(new Vehicle());
    }else if(unitType.equalsIgnoreCase("tank")) {
      // every ground vehicle, whatever its motive type
      unit.setDecoratedUnit(new Tank());
    }else if(unitType.equalsIgnoreCase("tracked")) {
      unit.setDecoratedUnit(tank(MotiveSystem.Tracked));
    }else if(unitType.equalsIgnoreCase("wheeled")) {
      unit.setDecoratedUnit(tank(MotiveSystem.Wheeled));
    }else if(unitType.equalsIgnoreCase("hovercraft")) {
      unit.setDecoratedUnit(tank(MotiveSystem.Hover));
    }else if(unitType.equalsIgnoreCase("VTOL")) {
      unit.setDecoratedUnit(new Vtol());
    }else if(unitType.equalsIgnoreCase("genericunit")) {
      unit.setDecoratedUnit(new Unit());
    }else {
      unit.setDecoratedUnit(new Unit());
    }
    return unit;
  }

  private static Tank tank(MotiveSystem motive) {
    Tank tank = new Tank();
    tank.setMotiveSystem(motive);
    return tank;
  }
}
