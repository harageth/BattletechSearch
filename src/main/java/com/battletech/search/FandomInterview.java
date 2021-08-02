package com.battletech.search;

import java.util.LinkedList;
import java.util.List;


// data transformation for an api for a database
public class FandomInterview {

  @Autowired
  verticalMatchingService;

  List<MatchedVertical> trafficToVerticalTransform(UserTraffic userTraffic) {

    if(userTraffic.visitedUrls == null) {
      return List.of();
    }
    //need a list of matchedverticals
    List<MatchedVertical> matchedVerticals = new LinkedList<MatchedVertical>();
    int badUrl = 0;
    for(String url : userTraffic.visitedUrls) {
      // we can get a matched vertical for this one url
      try {
        MatchedVertical vertical = verticalMatchingService.getVertical(url);
        matchedVerticals.add(vertical);
      }catch(VerticalMatchingServiceException e) {
        // what do we want to do here?
        // we have information that we dont know about.
        badUrl++;
        // not reinjecting data into the pipeline
      }
    }

    counterGoodURL.increment(matchedVerticals.size());
    counterBadURL.increment(badUrl);

    return matchedVerticals;
  }


  class UserTraffic {
    String userId;
    List<String> visitedUrls;
  }

  class MatchedVertical {
    String url;
    List<String> verticals;
  }




/*
  // "black-box", external API to call for vertical matching (assume it is already instantiated for you)
  MatchedVertical verticalMatchingService.getVertical(String url) throws VerticalMatchingServiceException;
  List<MatchedVertical> verticalMatchingService.getVerticals(List<String> url) throws VerticalMatchingServiceException;

  // A general, typed exception for the vertical matching service
  class VerticalMatchingServiceException extends Exception {}

  // A simple data class for the matched vertical results


  // A simple data class for the user traffic input

 */

}
