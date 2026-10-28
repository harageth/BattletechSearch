package com.battletech.search.web;

import com.battletech.search.model.dto.SearchResultsDTO;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.services.SearchService;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

// Admin actions (imports, slang) are actuator endpoints in the admin package, on a localhost-only port
@Slf4j
@Controller
@RequestMapping("/")
public class SearchController {
  private final SearchService searchService;

  public SearchController(SearchService searchService) {
    this.searchService = searchService;
  }

  // this should be a post mapping with a body value
  @GetMapping("/search/")
  public ModelAndView search(@RequestParam("query") String query) throws IOException {
    ModelAndView modelAndView = new ModelAndView("search");
    modelAndView.addObject("query", query);
    SearchResultsDTO dto = new SearchResultsDTO();
    try {
      List<Map<String, Object>> results = searchService.performQuery(query);
      for(Map<String, Object> value: results) {
        dto.addUnit(value.get("name").toString(), value.get("designation").toString());
      }
    } catch (FailedParseException e) {
      modelAndView.addObject("error", e.getMessage());
    }

    modelAndView.addObject("form", dto);
    return modelAndView;
  }
}
