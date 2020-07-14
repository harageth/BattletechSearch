package com.battletech.search.demo.web;

import com.battletech.search.demo.model.Unit;
import com.battletech.search.demo.services.SearchService;
import com.fasterxml.jackson.annotation.JsonView;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.task.TaskExecutor;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/")
public class SearchController {
  SearchService searchService;


  @Autowired
  public SearchController(SearchService searchService) {
    //initialize any class level things here
    this.searchService = searchService;
  }

  @GetMapping("/search/{query}")
  public List<Unit> search(@PathVariable String query) {

    return searchService.performQuery(query);
  }


}
