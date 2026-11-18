package com.battletech.search.web;

import com.battletech.search.autocorrect.Autocorrect;
import com.battletech.search.autocorrect.Suggestions;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * What a search that doesn't parse may have meant (Autocorrect), for the search box: it asks after you stop
 * typing and offers each misspelled word's suggestions in its list.
 */
@RestController
public class SuggestionController {
  private final Autocorrect autocorrect;

  public SuggestionController(Autocorrect autocorrect) {
    this.autocorrect = autocorrect;
  }

  @GetMapping("/api/suggestions")
  public Suggestions suggestions(@RequestParam("query") String query) {
    return autocorrect.suggest(query);
  }
}
