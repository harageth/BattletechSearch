package com.battletech.search.demo.model.search;

import java.util.Arrays;

/**
 * This class should contain the information needed to string along QuerySegments.
 * Each one should contain quantity, item its searching for, and comparison type
 */
public class QuerySegment {
  //instead store havings and where segments that get to be combined together

  int quantity;
  String queryItem;
  Comparison comparison;

  /*
  SELECT mech.id, COUNT(equipmentName) AS equipmentName FROM mechs JOIN equipment ON mechs.id = equipment.id WHERE mechs.thing = thing... AND equipment.name = name GROUP BY mech.id, equipment.name HAVING equipmentName COMPARATOR quantity
  Lets see if we can simplify through subqueries
  SELECT COUNT(equipmentName) AS equipmentName FROM equipment WHERE equipment.name = name (OPTIONAL AND location = location)

   */


}
