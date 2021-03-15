package com.battletech.search.model.search;

import java.util.Map;

/**
 * This class should contain the information needed to string along QuerySegments.
 * Each one should contain quantity, item its searching for, and comparison type
 */
public class QuerySegment {
  String sqlQuery;

  Map<String, Object> parameters;

  public void mergeQuerySegment(QuerySegment segment) {
    this.sqlQuery = this.sqlQuery + " " + segment.sqlQuery;
    this.parameters.putAll(segment.parameters);
  }
}
