package com.battletech.search.model;

import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.search.LogicalOperator;
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
    if(decoratedUnit.getClass().equals(Unit.class)) {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol' OR dtype = 'Mech') ");
    }else if(decoratedUnit.getClass().equals(Vtol.class)) {
      builder.append("dtype = 'Vtol' ");
    }else if(decoratedUnit.getClass().equals(Tank.class)) {
      builder.append("dtype = 'Tank' ");
    }else if(decoratedUnit.getClass().equals(Mech.class)) {
      builder.append("dtype = 'Mech' ");
    }else if(decoratedUnit.getClass().equals(Vehicle.class)) {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol') ");
    }else {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol' OR dtype = 'Mech') ");
    }

    if(decoratedUnit.weightClass != null) {
      builder.append(" AND weight_class = '" +decoratedUnit.getWeightClass().toString() + "' ");
    }
    boolean bool = decoratedUnit.getMechEquipment().isEmpty();
    if(decoratedUnit.getMechEquipment() != null && !decoratedUnit.getMechEquipment().isEmpty()) {
      builder.append("AND (id IN (");
      Iterator<UnitEquipment> iter = decoratedUnit.getMechEquipment().iterator();
      while (iter.hasNext()) {
        UnitEquipment equip = iter.next();

        String query = equip.getQuery();
        builder.append(query);
        LogicalOperator operator = ((EquipmentDecorator) equip).getLogicOperator();
        if (operator != null && iter.hasNext()) {
          builder.append(") ");
          builder.append(operator.toString());
          builder.append(" id IN (");
        }
      }
      builder.append("))");
    }
    builder.append(" ORDER BY name");
    return builder.toString();

  }
}
