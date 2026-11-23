package com.battletech.search.web;

import com.battletech.search.autocorrect.Autocomplete;
import com.battletech.search.autocorrect.Autocorrect;
import com.battletech.search.autocorrect.Completions;
import com.battletech.search.autocorrect.Suggestions;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * What a search that doesn't parse may have meant (Autocorrect), for the search box: it asks after you stop
 * typing and offers each misspelled word's suggestions in its list. And what the word being typed may become
 * (Autocomplete).
 */
@RestController
public class SuggestionController {
  private final Autocorrect autocorrect;
  private final Autocomplete autocomplete;

  public SuggestionController(Autocorrect autocorrect, Autocomplete autocomplete) {
    this.autocorrect = autocorrect;
    this.autocomplete = autocomplete;
  }

  @GetMapping("/api/suggestions")
  public Suggestions suggestions(@RequestParam("query") String query) {
    return autocorrect.suggest(query);
  }

  @GetMapping("/api/completions")
  public Completions completions(@RequestParam("query") String query, @RequestParam("caret") int caret) {
    return autocomplete.complete(query, caret);
  }
}
