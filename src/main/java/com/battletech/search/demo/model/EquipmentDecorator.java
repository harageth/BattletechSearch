package com.battletech.search.demo.model;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.model.search.Comparison;
import lombok.Data;

@Data
public class EquipmentDecorator extends UnitEquipment {
  UnitEquipment decoratedEquipment;
  Comparison comparison;
  int quantity;

  public EquipmentDecorator(UnitEquipment decoratedEquipment) {
    this.decoratedEquipment = decoratedEquipment;
  }

  public EquipmentDecorator(UnitEquipment decoratedEquipment, Comparison comparitor, int quantity) {
    this.decoratedEquipment = decoratedEquipment;
    this.comparison = comparitor;
    this.quantity = quantity;
  }

  public void setEquipment(Equipment equipment) {
    decoratedEquipment.setEquipment(equipment);
  }
  public Equipment getEquipment() {
    return decoratedEquipment.getEquipment();
  }

  // this should actually be in a builder maybe
  public void buildComparison(String quantity, String comparison) {
    if(quantity.equalsIgnoreCase("multiple")) {
      this.quantity = 1;
      this.comparison = Comparison.GREATER_THAN;
    }else if(comparison == null) {
      this.quantity = Integer.parseInt(quantity);
      this.comparison = Comparison.EQUAL;
    }else if(!comparison.isEmpty()) {
      // build it into one of the comparisons and translate
      this.quantity = Integer.parseInt(quantity);
      if(comparison.equalsIgnoreCase("at least")) {
        this.comparison = Comparison.EQUAL_OR_GREATER;
      }else if(comparison.equalsIgnoreCase("equal")) {
        this.comparison = Comparison.EQUAL;
      }else if(comparison.equalsIgnoreCase("less than")) {
        this.comparison = Comparison.LESS_THAN;
      }
    }
  }

  @Override
  public String getQuery() {
    StringBuilder builder = new StringBuilder(
        "SELECT unit_id FROM unit_equipment JOIN unit_mech_equipment ON unit_equipment.id = unit_mech_equipment.mech_equipment_id WHERE equipment_id = '"
    );
    builder.append(decoratedEquipment.getEquipment().getId());
    builder.append("' GROUP BY unit_mech_equipment.unit_id HAVING COUNT(*) ");
    builder.append(comparison.getText() + " ");
    builder.append(quantity);
    /*if(location != null) {

    }*/
    /*
    SELECT unit_id FROM equipment JOIN unit_equipment ON equipment.id = unit_equipment.equipment_id WHERE equipment = 'ER Large Laser'
    GROUP BY unit_equipment.unit_id HAVING COUNT(*) > 2
     */
    // if location not null then add location
    // we should have a comparison and a quantity though.
    return builder.toString();
  }

}
