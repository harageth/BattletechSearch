package com.battletech.search.demo.model;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.model.search.Comparison;
import com.battletech.search.demo.model.search.LogicalOperator;
import lombok.Data;

@Data
public class EquipmentDecorator extends UnitEquipment {
  UnitEquipment decoratedEquipment;
  Comparison comparison;
  int quantity;
  LogicalOperator operator;

  public EquipmentDecorator(UnitEquipment decoratedEquipment) {
    this.decoratedEquipment = decoratedEquipment;
  }

  public EquipmentDecorator(UnitEquipment decoratedEquipment, Comparison comparitor, int quantity) {
    this.decoratedEquipment = decoratedEquipment;
    this.comparison = comparitor;
    this.quantity = quantity;
  }

  public LogicalOperator getLogicOperator() {
    if(operator == null && decoratedEquipment != null) {
      return ((EquipmentDecorator)decoratedEquipment).getLogicOperator();
    }else if(operator == null && decoratedEquipment == null) {
      return null;
    }else {
      return operator;
    }
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
      //ATLEAST | EQUAL | LESSTHANCOMPARATOR | GREATERTHANCOMPARATOR | NOMORE
      // build it into one of the comparisons and translate
      this.quantity = Integer.parseInt(quantity);
      if(comparison.equalsIgnoreCase("ATLEAST")) {
        this.comparison = Comparison.EQUAL_OR_GREATER;
      }else if(comparison.equalsIgnoreCase("NOMORE")) {
        this.comparison = Comparison.EQUAL_OR_LESS;
      }else if(comparison.equalsIgnoreCase("EQUAL")) {
        this.comparison = Comparison.EQUAL;
      }else if(comparison.equalsIgnoreCase("LESSTHANCOMPARATOR")) {
        this.comparison = Comparison.LESS_THAN;
      }else if(comparison.equalsIgnoreCase("GREATERTHANCOMPARATOR")) {
        this.comparison = Comparison.GREATER_THAN;
      }
    }
  }

  @Override
  public String getQuery() {
    /*Annotation[] debug = this.getClass().getSuperclass().getAnnotations();
    List<Annotation> ann = Arrays.stream(this.getClass().getSuperclass().getAnnotations())
        .filter(annotation -> annotation.getClass().equals(Entity.class)).collect(Collectors.toList());
    String tableName = "";
    if(ann!=null) {
      tableName = ((Entity) ann.get(0)).name();
    }else {
      // throw exception
    }*/
    /*Annotation ann2 = Arrays.stream(this.getEquipment().getClass().getAnnotations())
        .filter(annotation -> annotation.equals(Entity.class)).collect(Collectors.toList()).get(0);
    String tableName2 = "";
    if(ann2!=null) {
      tableName2 = ((Entity) ann2).name();
    }else {
      // throw exception
    }*/

    String query = "";
    if(decoratedEquipment != null){
      query = decoratedEquipment.getQuery();
    }
    StringBuilder builder = new StringBuilder("");
    if(!query.isEmpty()) {
      builder.append(
          query
              + " UNION ");
    }
    builder.append("SELECT unit_id FROM unit_equipment JOIN unit_mech_equipment ON unit_equipment.id = unit_mech_equipment.mech_equipment_id WHERE equipment_id = '");
    builder.append(this.getEquipment().getId());
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
