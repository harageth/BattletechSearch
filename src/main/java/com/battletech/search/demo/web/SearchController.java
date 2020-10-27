package com.battletech.search.demo.web;

import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.services.SearchService;
import com.battletech.search.demo.services.UnitService;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/")
public class SearchController {
  SearchService searchService;
  UnitService unitService;


  @Autowired
  public SearchController(SearchService searchService, UnitService unitService) {
    //initialize any class level things here
    this.searchService = searchService;
    this.unitService = unitService;
  }

  // this should be a post mapping with a body value
  @GetMapping("/search/")
  public List<Map<String, Object>> search(@RequestParam("query") String query) throws IOException {

    return searchService.performQuery(query);
  }

  @GetMapping("/readFile/")
  public List<Unit> readStuffIn() throws IOException {
    // read in file and submit to database
    unitService.persistUnits();
    //Unit mech = ReadMegaMek.ReadMTF();
    //return Collections.singletonList(mech);
    return null;
  }


}
