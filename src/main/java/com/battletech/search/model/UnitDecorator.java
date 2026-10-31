package com.battletech.search.model;

import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.search.LogicalOperator;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Collectors;
import lombok.Data;

@Data
public class UnitDecorator extends Unit {
  Unit decoratedUnit;
  String decoratedUnitType;
  // "medium or heavy mechs": a unit in any of them; empty for any weight
  List<WeightClass> weightClasses = List.of();
  // "lams", "quads": mechs with that body plan; null for any
  Locomotion locomotion;
  // "omni mechs" true, "non-omni mechs" false, null for either
  Boolean omniFilter;
  // the chunks after "with": equipment, components, engine rating
  List<UnitFilter> filters = List.of();
  // units left out: "non-lam mechs", "mechs except quads", "units that aren't vtols"
  List<UnitDecorator> exclusions = List.of();

  public UnitDecorator() { }
  public UnitDecorator(String decoratedUnitType) { this.decoratedUnitType = decoratedUnitType; }
  public UnitDecorator(Unit decoratedUnit) {
    this.decoratedUnit = decoratedUnit;
  }

  @Override
  public String getQuery() {
    StringBuilder builder = new StringBuilder("SELECT name, designation FROM unit WHERE ");
    builder.append(unitCondition());

    if(!weightClasses.isEmpty()) {
      // built from the enum, not user text
      builder.append(" AND weight_class IN (")
          .append(weightClasses.stream().map(weightClass -> "'" + weightClass.name() + "'").collect(Collectors.joining(", ")))
          .append(") ");
    }
    for(UnitDecorator excluded : exclusions) {
      // a NULL column (a vehicle's locomotion, a missing motive type) doesn't count as a match
      builder.append(" AND NOT COALESCE((").append(excluded.unitCondition().trim()).append("), false) ");
    }
    if(!filters.isEmpty()) {
      builder.append("AND (");
      Iterator<UnitFilter> iter = filters.iterator();
      while (iter.hasNext()) {
        UnitFilter filter = iter.next();
        builder.append(filter.isNegated() ? "id NOT IN (" : "id IN (");
        builder.append(filter.getQuery());
        builder.append(")");
        if (iter.hasNext()) {
          // chunks without an explicit "and"/"or" between them are ANDed
          LogicalOperator operator = filter.getLogicOperator();
          builder.append(" ");
          builder.append(operator != null ? operator.toString() : LogicalOperator.AND.toString());
          builder.append(" ");
        }
      }
      builder.append(")");
    }
    builder.append(" ORDER BY name");
    return builder.toString();
  }

  /** What the unit word says: its type, motive type, body plan and omni or not; built from enums. */
  String unitCondition() {
    StringBuilder builder = new StringBuilder();
    if(decoratedUnit.getClass().equals(Unit.class)) {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol' OR dtype = 'Mech') ");
    }else if(decoratedUnit.getClass().equals(Vtol.class)) {
      builder.append("dtype = 'Vtol' ");
    }else if(decoratedUnit.getClass().equals(Tank.class)) {
      builder.append("dtype = 'Tank' ");
      MotiveSystem motive = ((Tank) decoratedUnit).getMotiveSystem();
      if(motive != null) {
        // "tracked", "wheeled", "hovercraft"; built from the enum, not user text
        builder.append("AND motive_system = '").append(motive.name()).append("' ");
      }else {
        // "tank" means ground vehicles, so leave out boats; units without a motive type stay in
        builder.append("AND (motive_system IS NULL OR motive_system NOT IN (")
            .append(MotiveSystem.WATER.stream().map(water -> "'" + water.name() + "'").sorted()
                .collect(Collectors.joining(", ")))
            .append(")) ");
      }
    }else if(decoratedUnit.getClass().equals(Mech.class)) {
      builder.append("dtype = 'Mech' ");
    }else if(decoratedUnit.getClass().equals(Vehicle.class)) {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol') ");
    }else {
      builder.append("(dtype = 'Tank' OR dtype = 'Vtol' OR dtype = 'Mech') ");
    }
    if(locomotion != null) {
      // built from the enum, not user text
      builder.append(" AND locomotion = '").append(locomotion.name()).append("' ");
    }
    if(omniFilter != null) {
      builder.append(" AND omni = ").append(omniFilter).append(" ");
    }
    return builder.toString();
  }
}
