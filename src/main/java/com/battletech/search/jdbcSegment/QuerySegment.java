package com.battletech.search.jdbcSegment;

import java.util.HashMap;
import java.util.Map;

public class QuerySegment {
  Map<String, Object> parameters;
  String template;

  public QuerySegment(String queryTemplate) {
    template = queryTemplate;
    parameters = new HashMap<String, Object>();
  }

  public void addParameter(String name, Object parameter) {
    parameters.put(name, parameter);
  }

  public void addParameters(Map<String, Object> params) {
    parameters.putAll(params);
  }

  public static QuerySegment merge(QuerySegment qs1, QuerySegment qs2) {


    return null;
  }

}
