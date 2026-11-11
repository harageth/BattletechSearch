package com.battletech.search.model;

import com.battletech.search.model.search.LogicalOperator;
import com.battletech.search.utils.ComponentNames;
import java.util.stream.Collectors;
import lombok.Data;

/** Units with a component of these types ("an xl engine", "endo steel"), optionally of one tech. */
@Data
public class ComponentFilter implements UnitFilter {
  final ComponentNames.Component component;
  // "clan xl engine"; null for any tech
  final Tech tech;
  LogicalOperator operator;
  boolean negated;

  @Override
  public String getQuery() {
    // column names and enum names, not user text
    StringBuilder builder = new StringBuilder("SELECT id FROM unit WHERE ")
        .append(component.kind().getColumn()).append(" IN (")
        .append(component.types().stream().map(type -> "'" + type + "'").collect(Collectors.joining(", ")))
        .append(")");
    if (tech != null) {
      builder.append(" AND ").append(component.kind().getTechColumn()).append(" = '").append(tech.name()).append("'");
    }
    return builder.toString();
  }

  @Override
  public LogicalOperator getLogicOperator() {
    return operator;
  }
}
