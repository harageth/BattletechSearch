package com.battletech.search.model;

import com.battletech.search.model.search.Comparison;
import com.battletech.search.model.search.LogicalOperator;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import lombok.Data;

/**
 * Units by barrier armor rating: "a bar rating of at least 7". The rating is in the armor type
 * (BAR_2 to BAR_10), so this is the BAR types whose rating compares.
 */
@Data
public class BarRatingFilter implements UnitFilter {
  final Comparison comparison;
  final int rating;
  LogicalOperator operator;

  /** The BAR armor types with a rating that compares; none for a rating no BAR armor has. */
  List<ArmorType> types() {
    return Arrays.stream(ArmorType.values())
        .filter(type -> type.getBarRating() != null && compares(type.getBarRating()))
        .toList();
  }

  private boolean compares(int bar) {
    return switch (comparison) {
      case LESS_THAN -> bar < rating;
      case GREATER_THAN -> bar > rating;
      case EQUAL -> bar == rating;
      case EQUAL_OR_GREATER -> bar >= rating;
      case EQUAL_OR_LESS -> bar <= rating;
    };
  }

  @Override
  public String getQuery() {
    List<ArmorType> types = types();
    if (types.isEmpty()) {
      return "SELECT id FROM unit WHERE false";
    }
    // built from the enum, not user text
    return "SELECT id FROM unit WHERE armor_type IN ("
        + types.stream().map(type -> "'" + type.name() + "'").collect(Collectors.joining(", ")) + ")";
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
