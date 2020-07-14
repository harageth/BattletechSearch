package com.battletech.search.demo.model.search;

/**
 * This class should contain the information needed to string along QuerySegments.
 * Each one should contain quantity, item its searching for, and comparison type
 */
public class QuerySegment {
  int quantity;
  String queryItem;
  Comparison comparison;
}
