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
import com.battletech.search.services.EquipmentService.EquipmentGroup;
import com.battletech.search.services.EquipmentService.EquipmentTerms;
import com.battletech.search.services.EquipmentService.EquipmentTree;
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
    EquipmentTerms lrm = new EquipmentTerms("LRM 20", List.of("IS", "Clan"), List.of("long range missile 20"),
        List.of("OS LRM-20"));
    EquipmentTerms laser = new EquipmentTerms("Medium Laser", List.of("IS"), List.of("ml"), List.of());
    EquipmentTerms ams = new EquipmentTerms("AMS", List.of("Clan"), List.of("ams"), List.of());
    EquipmentGroup standardLrms = new EquipmentGroup("standard lrms", 1, List.of(lrm), List.of());
    EquipmentGroup lrms = new EquipmentGroup("lrms", 1, List.of(), List.of(standardLrms));
    EquipmentGroup missiles = new EquipmentGroup("missiles", 1, List.of(), List.of(lrms));
    EquipmentGroup lasers = new EquipmentGroup("lasers", 1, List.of(laser), List.of());
    EquipmentGroup energy = new EquipmentGroup("energy weapons", 1, List.of(), List.of(lasers));
    EquipmentTerms ammo = new EquipmentTerms("LRM 20 Ammo", List.of("IS"), List.of(), List.of());
    EquipmentGroup ammoGroup = new EquipmentGroup("ammo", 1, List.of(ammo), List.of());
    when(equipmentService.equipmentTree())
        .thenReturn(new EquipmentTree(List.of(missiles, energy), List.of(ammoGroup), List.of(ams)));
  }

  private String page() throws Exception {
    return mvc.perform(get("/equipment")).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
  }

  @Test
  void showsTheGroupTree() throws Exception {
    String page = page();
    // top groups open, the ones under them closed, each with its term for the filter
    assertThat(page).contains("<details class=\"equipment-group\" data-group=\"missiles\" open=\"open\">")
        .contains("<details class=\"equipment-group\" data-group=\"lrms\">")
        .contains("<details class=\"equipment-group\" data-group=\"standard lrms\">")
        .contains("<summary><code>standard lrms</code> <span class=\"equipment-count\">1</span></summary>");
    // nested: standard lrms inside lrms inside missiles, and LRM 20 inside standard lrms
    assertThat(page.indexOf("data-group=\"missiles\"")).isLessThan(page.indexOf("data-group=\"lrms\""));
    assertThat(page.indexOf("data-group=\"standard lrms\"")).isLessThan(page.indexOf("<td>LRM 20</td>"));
    assertThat(page.indexOf("<td>LRM 20</td>")).isLessThan(page.indexOf("data-group=\"energy weapons\""));
    // then the equipment section: its groups (closed), then the items in no group, all counted
    assertThat(page).contains("<summary>Other equipment <span class=\"equipment-count\">2</span></summary>")
        .contains("<details class=\"equipment-group\" data-group=\"ammo\">");
    assertThat(page.indexOf("Other equipment")).isGreaterThan(page.indexOf("<td>Medium Laser</td>"))
        .isLessThan(page.indexOf("data-group=\"ammo\""));
    assertThat(page.indexOf("<td>LRM 20 Ammo</td>")).isLessThan(page.indexOf("<td>AMS</td>"));
  }

  @Test
  void listsEquipmentAndItsSlang() throws Exception {
    mvc.perform(get("/equipment"))
        .andExpect(status().isOk())
        .andExpect(content().string(containsString("<td>LRM 20</td>")))
        .andExpect(content().string(containsString("<td>IS, Clan</td>")))
        .andExpect(content().string(containsString("<td>long range missile 20</td>")))
        .andExpect(content().string(containsString("OS LRM-20")))
        // the list only covers what official units carry
        .andExpect(content().string(containsString("<b>Only what official units carry:</b>")))
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
    // the top groups and the ones under them
    words.addAll(List.of("missiles", "lrms", "energy weapons", "lasers", "ammo"));
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
