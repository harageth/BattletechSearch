package com.battletech.search.demo.services;

import com.battletech.search.demo.model.Mech;
import com.battletech.search.demo.model.Unit;
import com.battletech.search.demo.model.search.QuerySegment;
import java.util.List;
import java.util.regex.Pattern;
import org.springframework.stereotype.Controller;

@Controller
public class SearchService {

  public List<Unit> performQuery(String query) {
    List<QuerySegment> querySegments = getQuerySegments(query);

    Pattern mech = Pattern.compile("mech[s]*");
    Pattern vehicle = Pattern.compile("vehicle[s]*|vee[s]*");

    Unit searchUnit;

    if(query.matches(mech.pattern())) {
      searchUnit = new Mech();
    }else if (query.matches(vehicle.pattern())) {
      System.out.println("Unable to search for vehicles yet");
      searchUnit = new Unit();
    }else {
      //What do I really want to do wih the Unit object...
      searchUnit = new Unit();
    }

    String generatedQuery = searchUnit.getQuery();

    //pass to function that will decompose into a query and run against the List of Segments
    return null;
  }



  // A query should be of the format of
  // "Mechs with mutliple Large Lasers" or a more complex query "Things with at least 3 medium lasers and SRM's"
  public List<QuerySegment> getQuerySegments(String query) {
    /*
    So we need to find part of the query that matches to the language mapping
    If we can find where the language mapping is then we can use that as a starting point
    to figure out where the rest of the query parameters are.
     */



    /*
    1. Find what we are looking for
    2. split on logical operators while maintaining understanding of them
    3. identify what equipment is being looked at or which Unit Parameter
    4. identify quantity searching for
    5. identify comparator being used (this is probably implied)
    */
    return null;
  }

}
