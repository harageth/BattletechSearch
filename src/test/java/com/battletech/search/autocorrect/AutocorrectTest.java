package com.battletech.search.autocorrect;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.battletech.search.SearchFixtures;
import com.battletech.search.TestcontainersConfiguration;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

/**
 * Misspelled searches against the fixture units (SearchFixtures), and what autocorrect offers for them (user,
 * 2026-11-18): the corrected query, and up to 3 spellings for each misspelled word.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Import({TestcontainersConfiguration.class, SearchFixtures.class})
class AutocorrectTest {
  @Autowired
  Autocorrect autocorrect;

  @Autowired
  MockMvc mvc;

  @Test
  void suggestsWhatAMisspelledSearchMeant() {
    // a typo is corrected to what fits where it is, wherever the error showed up: "mehcs" is read as a
    // weight class, "at lest" as equipment, "wtih" is a syntax error
    Map<String, String> meant = Map.ofEntries(
        Map.entry("hevy mechs", "heavy mechs"),
        Map.entry("mehcs with 2 ppc", "mechs with 2 ppc"),
        Map.entry("mechs with at lest 2 ppc", "mechs with at least 2 ppc"),
        Map.entry("mechs with 2 clna lrm 20", "mechs with 2 clan lrm 20"),
        Map.entry("mechs with 2 ppc adn 1 srm 6", "mechs with 2 ppc and 1 srm 6"),
        Map.entry("mechs wtih 2 ppc", "mechs with 2 ppc"),
        Map.entry("mechs with 2 mediun lasers", "mechs with 2 medium lasers"),
        Map.entry("mechs with an xl engnie", "mechs with an xl engine"),
        Map.entry("heavymechs", "heavy mechs"),
        Map.entry("omin mechs", "omni mechs"),
        Map.entry("mechs withot ppcs", "mechs without ppcs"),
        Map.entry("mechs with 2 laesrs", "mechs with 2 lasers"),
        Map.entry("tanks with a turet lrm 20", "tanks with a turret lrm 20"),
        Map.entry("Heavy Mehcs with 2 PPC", "Heavy mechs with 2 PPC"));
    meant.forEach((typed, query) -> assertThat(autocorrect.suggest(typed).getQuery()).as(typed).isEqualTo(query));
  }

  @Test
  void eachMisspelledWordGetsUpToThreeSpellingsThatFit() {
    Suggestions suggestions = autocorrect.suggest("hevy mechs with 2 mediun lasers");
    assertThat(suggestions.getQuery()).isEqualTo("heavy mechs with 2 medium lasers");
    assertThat(suggestions.getWords()).extracting(Suggestions.WordSuggestion::getText)
        .containsExactly("hevy", "mediun");
    Suggestions.WordSuggestion hevy = suggestions.getWords().get(0);
    assertThat(hevy.getStart()).isZero();
    assertThat(hevy.getStop()).isEqualTo(4);
    assertThat(hevy.getSuggestions()).first().isEqualTo("heavy");
    Suggestions.WordSuggestion mediun = suggestions.getWords().get(1);
    assertThat(mediun.getStart()).isEqualTo(18);
    assertThat(mediun.getSuggestions()).hasSizeLessThanOrEqualTo(3).contains("medium");
  }

  @Test
  void nothingToSuggest() {
    // it parses
    assertThat(autocorrect.suggest("mechs with 2 ppc")).isEqualTo(Suggestions.NONE);
    // a word the index doesn't know isn't a typo when the query parses ("lrm 20s")
    assertThat(autocorrect.suggest("mechs with 2 lrm 20s")).isEqualTo(Suggestions.NONE);
    // nothing close
    assertThat(autocorrect.suggest("mechs with 2 zzzzzzzz").getQuery()).isNull();
    // a real query, never rewritten into another (user, 2026-11-18): Clan mechs with two LRM 20s
    assertThat(autocorrect.suggest("clan mechs with 2 lrm 20").getQuery()).isNull();
    assertThat(autocorrect.suggest("")).isEqualTo(Suggestions.NONE);
  }

  @Test
  void wordsInTheWrongPlaceAreMovedWhereTheyFit() {
    // every word is right, but the grammar stops at some of them; those move to the nearest place that
    // parses (user, 2026-11-18)
    Map<String, String> meant = Map.ofEntries(
        Map.entry("mechs with 2 ppc or more", "mechs with 2 or more ppc"),
        Map.entry("mechs heavy with 2 ppc", "heavy mechs with 2 ppc"),
        Map.entry("with 2 ppc heavy mechs", "heavy mechs with 2 ppc"),
        Map.entry("mechs with ppc at least 2", "mechs with at least 2 ppc"));
    meant.forEach((typed, query) -> assertThat(autocorrect.suggest(typed).getQuery()).as(typed).isEqualTo(query));
    // a move is only tried when no spelling parses, and not with one
    assertThat(autocorrect.suggest("mechs hevy with 2 ppc").getQuery()).isNull();
  }

  @Test
  void theSearchBoxAsksForThemAsJson() throws Exception {
    mvc.perform(get("/api/suggestions").param("query", "mehcs with 2 ppc"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.query").value("mechs with 2 ppc"))
        .andExpect(jsonPath("$.words[0].start").value(0))
        .andExpect(jsonPath("$.words[0].stop").value(5))
        .andExpect(jsonPath("$.words[0].text").value("mehcs"))
        .andExpect(jsonPath("$.words[0].suggestions[0]").value("mechs"));
    mvc.perform(get("/api/suggestions").param("query", "mechs with 2 ppc"))
        .andExpect(jsonPath("$.query").doesNotExist())
        .andExpect(jsonPath("$.words").isEmpty());
  }
}
