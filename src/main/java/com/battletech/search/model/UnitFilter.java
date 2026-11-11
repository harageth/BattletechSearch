package com.battletech.search.model;

import com.battletech.search.model.search.LogicalOperator;

/**
 * One condition a searched unit must meet, as a subquery of unit ids: equipment counts
 * (EquipmentDecorator), component types (ComponentFilter), engine rating (EngineRatingFilter).
 * UnitDecorator joins them with "id IN (...)", or "id NOT IN (...)" when negated.
 */
public interface UnitFilter {
  /** Selects unit ids; built from enums, ids and numbers, never from what was typed. */
  String getQuery();

  /** How this joins the next filter ("and" / "or"); null means "and". */
  LogicalOperator getLogicOperator();

  /** Set from the "and" / "or" after this filter's chunk. */
  void setOperator(LogicalOperator operator);

  /** "without ...": the unit must not match. */
  boolean isNegated();
}
