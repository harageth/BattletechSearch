package com.battletech.search.model;

import com.battletech.search.model.search.Comparison;
import com.battletech.search.model.search.LogicalOperator;
import lombok.Data;

/** Units by engine rating: "an engine rating of at least 300". */
@Data
public class EngineRatingFilter implements UnitFilter {
  final Comparison comparison;
  final int rating;
  LogicalOperator operator;

  @Override
  public String getQuery() {
    // a comparison and a number, not user text
    return "SELECT id FROM unit WHERE engine_rating " + comparison.getText() + " " + rating;
  }

  @Override
  public LogicalOperator getLogicOperator() {
    return operator;
  }

  @Override
  public boolean isNegated() {
    return false;
  }
}
