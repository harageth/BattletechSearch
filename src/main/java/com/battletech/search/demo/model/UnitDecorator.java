package com.battletech.search.demo.model;

import com.battletech.search.demo.entities.MechEquipment;
import com.battletech.search.demo.entities.Unit;
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
  public void setMechEquipment(List<MechEquipment> mechEquipments) {
    decoratedUnit.setMechEquipment(mechEquipments);
  }

  @Override
  public List<MechEquipment> getMechEquipment() {
    return decoratedUnit.getMechEquipment();
  }

  @Override
  public void setWeightClass(WeightClass weightClass) {
    decoratedUnit.setWeightClass(weightClass);
  }

  @Override
  public String getQuery() {
    StringBuilder builder = new StringBuilder("SELECT name, designation FROM unit WHERE ");
    if(decoratedUnit.weightClass != null) {
      builder.append("weight_class = '" +decoratedUnit.getWeightClass().toString() + "' AND ");
    }
    builder.append(" id IN (");
    for(MechEquipment equip : decoratedUnit.getMechEquipment()) {
      String query = equip.getQuery();
      builder.append(query);
    }
    builder.append(") ORDER BY name");
    return builder.toString();

  }
}
