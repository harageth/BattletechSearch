package com.battletech.search.model;

import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.model.search.Comparison;
import com.battletech.search.model.search.LogicalOperator;
import com.battletech.search.model.search.QuantityConverter;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.Data;

@Data
public class EquipmentDecorator extends UnitEquipment {
  UnitEquipment decoratedEquipment;
  Comparison comparison;
  int quantity;
  LogicalOperator operator;
  // only count launchers with one of these ("artemis lrm 20"); null counts all
  Set<FireControl> fireControls;
  // the equipment exists but not in the tech asked for ("clan plasma rifle"), so no unit matches
  boolean matchesNothing;

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
    }else if(quantity.equalsIgnoreCase("any")) {
      // "any lasers": at least one, whatever comparator is in front
      this.quantity = 1;
      this.comparison = Comparison.EQUAL_OR_GREATER;
    }else if(comparison == null) {
      this.quantity = QuantityConverter.toInt(quantity);
      this.comparison = Comparison.EQUAL;
    }else if(!comparison.isEmpty()) {
      //ATLEAST | EQUAL | LESSTHANCOMPARATOR | GREATERTHANCOMPARATOR | NOMORE
      // build it into one of the comparisons and translate
      this.quantity = QuantityConverter.toInt(quantity);
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
    // Every matching equipment row (e.g. the IS and Clan medium laser) is counted together, so
    // "at least 4 medium laser" counts a mixed-tech mech's IS and Clan lasers. "clan medium laser"
    // narrows the rows to one tech before this (QueryVisitor).
    if(matchesNothing) {
      return "SELECT unit_id FROM unit_mech_equipment WHERE false";
    }
    List<String> ids = new LinkedList<>();
    for(UnitEquipment equip = this; equip != null;
        equip = equip instanceof EquipmentDecorator decorator ? decorator.getDecoratedEquipment() : null) {
      ids.add("'" + equip.getEquipment().getId() + "'");
    }
    StringBuilder builder = new StringBuilder();
    builder.append("SELECT unit_id FROM unit_equipment JOIN unit_mech_equipment ON unit_equipment.id = unit_mech_equipment.mech_equipment_id WHERE equipment_id IN (");
    // ids from the equipment table, not user text
    builder.append(String.join(", ", ids));
    builder.append(")");
    if(fireControls != null && !fireControls.isEmpty()) {
      // enum names, not user text
      builder.append(" AND fire_control IN (")
          .append(fireControls.stream().map(fireControl -> "'" + fireControl.name() + "'").sorted()
              .collect(Collectors.joining(", ")))
          .append(")");
    }
    builder.append(" GROUP BY unit_mech_equipment.unit_id HAVING COUNT(*) ");
    builder.append(comparison.getText() + " ");
    builder.append(quantity);
    // TODO: if location not null then add location
    return builder.toString();
  }

}
