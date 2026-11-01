package com.battletech.search.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.hamcrest.Matchers.containsString;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.battletech.search.antlr.QueryParser;
import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.antlr.QueryVocabulary.UnitWord;
import com.battletech.search.entities.Equipment;
import com.battletech.search.model.Tech;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.services.EquipmentService;
import com.battletech.search.services.EquipmentService.EquipmentTerms;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.util.HtmlUtils;

@WebMvcTest(EquipmentController.class)
class EquipmentControllerTest {
  private static final Pattern EXAMPLE_CELL = Pattern.compile("<td class=\"guide-example\">(.*?)</td>", Pattern.DOTALL);
  private static final Pattern EXAMPLE_LINK = Pattern.compile("<a href=\"/search/\\?query=[^\"]*\"><code>(.*?)</code></a>");
  private static final Pattern CODE = Pattern.compile("<code>(.*?)</code>");

  @Autowired
  MockMvc mvc;

  @MockitoBean
  EquipmentService equipmentService;

  @BeforeEach
  void setUp() {
    when(equipmentService.equipmentWithSlang()).thenReturn(List.of(
        new EquipmentTerms("LRM 20", List.of("IS", "Clan"), List.of("lrms", "lrm"), List.of("OS LRM-20"))));
    when(equipmentService.familyTerms()).thenReturn(List.of("lasers", "lrms"));
  }

  private String page() throws Exception {
    return mvc.perform(get("/equipment")).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
  }

  @Test
  void listsEquipmentAndItsSlang() throws Exception {
    mvc.perform(get("/equipment"))
        .andExpect(status().isOk())
        .andExpect(content().string(containsString("<td>LRM 20</td>")))
        .andExpect(content().string(containsString("<td>IS, Clan</td>")))
        .andExpect(content().string(containsString("<td>lrms, lrm</td>")))
        .andExpect(content().string(containsString("OS LRM-20")))
        // the search box, so a term can be tried right away
        .andExpect(content().string(containsString("data-query-input")))
        .andExpect(content().string(containsString("src=\"/js/equipment-filter.js\"")))
        .andExpect(content().string(containsString("<a href=\"/equipment\">Search guide</a>")));
  }

  @Test
  void theGuideListsTheWordsEachPartTakes() throws Exception {
    String page = page();
    // the unit words are described by hand, so a new one has to be added there
    for (UnitWord unit : QueryVocabulary.units()) {
      assertThat(page).as("unit word " + unit.plural()).contains("<code>" + unit.plural() + "</code>");
    }
    List<String> words = new ArrayList<>();
    words.addAll(QueryVocabulary.weightClasses());
    words.addAll(QueryVocabulary.omniWords());
    words.addAll(QueryVocabulary.withWords());
    words.addAll(QueryVocabulary.comparatorsBefore());
    words.addAll(QueryVocabulary.comparatorsAfter());
    words.addAll(QueryVocabulary.techs().keySet());
    words.addAll(QueryVocabulary.fireControls());
    QueryVocabulary.components().values().forEach(words::addAll);
    words.addAll(List.of("lasers", "lrms"));
    for (String word : words) {
      assertThat(page).contains("<code>" + HtmlUtils.htmlEscape(word) + "</code>");
    }
  }

  @Test
  void everyExampleInTheGuideParses() throws Exception {
    String page = page();
    List<String> examples = new ArrayList<>();
    Matcher cell = EXAMPLE_CELL.matcher(page);
    while (cell.find()) {
      Matcher code = CODE.matcher(cell.group(1));
      while (code.find()) {
        examples.add(HtmlUtils.htmlUnescape(code.group(1)));
      }
    }
    Matcher link = EXAMPLE_LINK.matcher(page);
    while (link.find()) {
      examples.add(HtmlUtils.htmlUnescape(link.group(1)));
    }
    assertThat(examples).hasSizeGreaterThan(30).contains("mechs without ppcs or lasers", "quadvees");

    // every equipment name is found, so only the grammar and the visitor are checked
    EquipmentRepository equipRepo = mock(EquipmentRepository.class);
    when(equipRepo.findAllByNameOrSlang(anyString(), anyString()))
        .thenAnswer(invocation -> List.of(new Equipment(invocation.getArgument(0), Tech.INNER_SPHERE)));
    for (String example : examples) {
      assertThatCode(() -> QueryParser.parse(example, equipRepo)).as(example).doesNotThrowAnyException();
    }
  }
}
