package com.battletech.search.web;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.services.EquipmentService;
import com.battletech.search.services.SearchService;
import com.battletech.search.services.UnitService;
import java.util.List;
import java.util.Map;
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

  @MockitoBean
  UnitService unitService;

  @MockitoBean
  EquipmentService equipmentService;

  @Test
  void rendersResults() throws Exception {
    when(searchService.performQuery("mechs with 2 ppc"))
        .thenReturn(List.of(Map.of("name", "Awesome", "designation", "AWS-8Q")));

    mvc.perform(get("/search/").param("query", "mechs with 2 ppc"))
        .andExpect(status().isOk())
        .andExpect(content().string(containsString("AWS-8Q")))
        .andExpect(content().string(containsString("<a href=\"https://www.sarna.net/wiki/Awesome#AWS-8Q\">Sarna Link</a>")))
        .andExpect(content().string(containsString("value=\"mechs with 2 ppc\"")))
        .andExpect(content().string(not(containsString("class=\"error\""))));
  }

  @Test
  void showsParseErrorsOnThePage() throws Exception {
    when(searchService.performQuery("mechs with"))
        .thenThrow(new FailedParseException("Unable to parse query at position 10: missing QUANTITY"));

    mvc.perform(get("/search/").param("query", "mechs with"))
        .andExpect(status().isOk())
        .andExpect(content().string(containsString("Unable to parse query at position 10")))
        .andExpect(content().string(containsString("value=\"mechs with\"")));
  }
}
