package com.battletech.search.web;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.services.SearchService;
import java.util.List;
import java.util.Map;
import java.util.stream.IntStream;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(SearchController.class)
class SearchControllerTest {
  @Autowired
  MockMvc mvc;

  @MockitoBean
  SearchService searchService;

  @Test
  void bothPagesGetTheSearchBox() throws Exception {
    when(searchService.performQuery("mechs with 2 ppc")).thenReturn(List.of());

    for (String page : new String[] {"/", "/search/?query=mechs with 2 ppc"}) {
      mvc.perform(get(page))
          .andExpect(status().isOk())
          .andExpect(content().string(containsString("<script type=\"importmap\">")))
          .andExpect(content().string(containsString("src=\"/js/query-input.js\"")))
          // the plain input the script enhances, which also works without it
          .andExpect(content().string(containsString("name=\"query\"")))
          .andExpect(content().string(containsString("data-query-input")));
    }
  }

  @Test
  void rendersResults() throws Exception {
    when(searchService.performQuery("mechs with 2 ppc"))
        .thenReturn(List.of(Map.of("name", "Awesome", "designation", "AWS-8Q")));

    mvc.perform(get("/search/").param("query", "mechs with 2 ppc"))
        .andExpect(status().isOk())
        .andExpect(content().string(containsString("AWS-8Q")))
        .andExpect(content().string(containsString("<a href=\"https://www.sarna.net/wiki/Awesome#AWS-8Q\">Sarna Link</a>")))
        .andExpect(content().string(containsString("value=\"mechs with 2 ppc\"")))
        .andExpect(content().string(containsString("1 unit found")))
        .andExpect(content().string(not(containsString("class=\"error\""))));
  }

  @Test
  void countsTheResults() throws Exception {
    List<Map<String, Object>> many = IntStream.range(0, 1248)
        .mapToObj(i -> Map.<String, Object>of("name", "Unit", "designation", "U-" + i)).toList();
    when(searchService.performQuery("tanks")).thenReturn(many);
    when(searchService.performQuery("mechs with 9 ppc")).thenReturn(List.of());

    mvc.perform(get("/search/").param("query", "tanks"))
        .andExpect(content().string(containsString("1,248 units found")));
    mvc.perform(get("/search/").param("query", "mechs with 9 ppc"))
        .andExpect(content().string(containsString("0 units found")));
  }

  @Test
  void showsParseErrorsOnThePage() throws Exception {
    when(searchService.performQuery("mechs with"))
        .thenThrow(new FailedParseException("Unable to parse query at position 10: missing QUANTITY"));

    mvc.perform(get("/search/").param("query", "mechs with"))
        .andExpect(status().isOk())
        .andExpect(content().string(containsString("Unable to parse query at position 10")))
        .andExpect(content().string(containsString("value=\"mechs with\"")))
        // a query that didn't parse found nothing; it wasn't searched
        .andExpect(content().string(not(containsString("found"))));
  }
}
