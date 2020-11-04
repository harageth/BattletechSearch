package com.battletech.search.demo.model;

import com.battletech.search.demo.entities.Mech;
import com.battletech.search.demo.entities.Tank;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.entities.Vehicle;
import com.battletech.search.demo.entities.Vtol;
import java.util.List;
import lombok.Data;

@Data
public class UnitDecorator extends Unit {
  Unit decoratedUnit;

  public UnitDecorator() { }
  public UnitDecorator(Unit decoratedUnit) {
    this.decoratedUnit = decoratedUnit;
  }

  @Override
  public void setMechEquipment(List<UnitEquipment> mechEquipments) {
    decoratedUnit.setMechEquipment(mechEquipments);
  }

  @Override
  public List<UnitEquipment> getMechEquipment() {
    return decoratedUnit.getMechEquipment();
  }

  @Override
  public void setWeightClass(WeightClass weightClass) {
    decoratedUnit.setWeightClass(weightClass);
  }

  @Override
  public String getQuery() {
    StringBuilder builder = new StringBuilder("SELECT name, designation FROM unit WHERE ");

    if(decoratedUnit.getClass().isInstance(Unit.class)) {
      // do nothing
    }else if(decoratedUnit.getClass().isInstance(Vtol.class)) {
      builder.append("dtype = 'Vtol' AND ");
    }else if(decoratedUnit.getClass().isInstance(Tank.class)) {
      builder.append("dtype = 'Tank' AND ");
    }else if(decoratedUnit.getClass().isInstance(Mech.class)) {
      builder.append("dtype = 'Mech' AND ");
    }else if(decoratedUnit.getClass().isInstance(Vehicle.class)) {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol')");
    }

    if(decoratedUnit.weightClass != null) {
      builder.append("weight_class = '" +decoratedUnit.getWeightClass().toString() + "' AND ");
    }
    builder.append(" id IN (");
    for(UnitEquipment equip : decoratedUnit.getMechEquipment()) {
      String query = equip.getQuery();
      builder.append(query);
    }
    builder.append(") ORDER BY name");
    return builder.toString();

  }
}
