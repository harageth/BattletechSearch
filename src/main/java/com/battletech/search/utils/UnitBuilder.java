package com.battletech.search.utils;

import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.UnitDecorator;
import com.battletech.search.model.search.FailedParseException;

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
    }else if(unitType.equalsIgnoreCase("tracked") || unitType.equalsIgnoreCase("wheeled")
        || unitType.equalsIgnoreCase("hovercraft")) {
      // TODO: motive type isn't stored for vehicles yet; search by it once it is
      throw new FailedParseException(
          "Searching by motive type (" + unitType.toLowerCase() + ") isn't supported yet");
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
