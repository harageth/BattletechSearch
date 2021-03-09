package com.battletech.search.demo.model;

import com.battletech.search.demo.entities.Mech;
import com.battletech.search.demo.entities.Tank;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.entities.Vehicle;
import com.battletech.search.demo.entities.Vtol;
import com.battletech.search.demo.model.search.LogicalOperator;
import java.util.Iterator;
import java.util.List;
import lombok.Data;

@Data
public class UnitDecorator extends Unit {
  Unit decoratedUnit;
  String decoratedUnitType;

  public UnitDecorator() { }
  public UnitDecorator(String decoratedUnitType) { this.decoratedUnitType = decoratedUnitType; }
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
    Class<? extends Unit> value = decoratedUnit.getClass();
    if(decoratedUnit.getClass().isInstance(Unit.class)) {
      // do nothing
    }else if(decoratedUnit.getClass().equals(Vtol.class)) {
      builder.append("dtype = 'Vtol' AND ");
    }else if(decoratedUnit.getClass().equals(Tank.class)) {
      builder.append("dtype = 'Tank' AND ");
    }else if(decoratedUnit.getClass().equals(Mech.class)) {
      builder.append("dtype = 'Mech' AND ");
    }else if(decoratedUnit.getClass().equals(Vehicle.class)) {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol') AND ");
    }

    if(decoratedUnit.weightClass != null) {
      builder.append("weight_class = '" +decoratedUnit.getWeightClass().toString() + "' AND ");
    }
    builder.append(" (id IN (");
    Iterator<UnitEquipment> iter = decoratedUnit.getMechEquipment().iterator();
    while(iter.hasNext()) {
      UnitEquipment equip = iter.next();

      String query = equip.getQuery();
      builder.append(query);
      LogicalOperator operator = ((EquipmentDecorator)equip).getLogicOperator();
      if(operator!=null && iter.hasNext()) {
        builder.append(") ");
        builder.append(operator.toString());
        builder.append(" id IN (");
      }
    }
    builder.append(")) ORDER BY name");
    return builder.toString();

  }
}
