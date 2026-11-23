package com.battletech.search.autocorrect;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.battletech.search.SearchFixtures;
import com.battletech.search.TestcontainersConfiguration;
import com.battletech.search.antlr.QueryParser;
import com.battletech.search.repositories.EquipmentRepository;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

/** Completing the word being typed, against the fixture units (SearchFixtures; user, 2026-11-22). */
@SpringBootTest
@AutoConfigureMockMvc
@Import({TestcontainersConfiguration.class, SearchFixtures.class})
class AutocompleteTest {
  @Autowired
  Autocomplete autocomplete;

  @Autowired
  EquipmentRepository equipRepo;

  @Autowired
  MockMvc mvc;

  private Completions complete(String query) {
    return autocomplete.complete(query, query.length());
  }

  private static List<String> texts(Completions completions) {
    return completions.getOptions().stream().map(Completions.Option::getText).toList();
  }

  @Test
  void completesTheWordsOfTheGrammar() {
    assertThat(texts(complete("hea"))).startsWith("heavy");
    assertThat(texts(complete("HEA"))).startsWith("heavy");
    // even where a longer name starts ("heavy medium laser"); the plural, and other spellings after everything else
    assertThat(texts(complete("heavy me"))).startsWith("mechs");
    assertThat(texts(complete("helo"))).contains("helos");
    assertThat(texts(complete("he")).get(0)).isEqualTo("heavy");
    assertThat(texts(complete("mechs wi"))).contains("with", "without");
    assertThat(texts(complete("mechs with at le"))).contains("at least");
    assertThat(texts(complete("mechs with 2 or mo"))).contains("or more");
    assertThat(texts(complete("inner sp"))).contains("inner sphere");
    assertThat(texts(complete("mechs with 2 tur"))).contains("turret");
    assertThat(texts(complete("mechs that ha"))).contains("that have");
  }

  @Test
  void completesEquipmentAcrossWords() {
    Completions medium = complete("mechs with 2 medium la");
    assertThat(texts(medium)).contains("medium laser");
    // the whole name is replaced
    assertThat(medium.getOptions()).extracting(Completions.Option::getStart).containsOnly("mechs with 2 ".length());
    assertThat(medium.getStop()).isEqualTo("mechs with 2 medium la".length());
    assertThat(texts(complete("mechs with 2 med"))).contains("medium laser");
    assertThat(texts(complete("mechs with 2 lrm 2"))).contains("lrm 20");
    assertThat(texts(complete("mechs with an xl en"))).contains("xl engine");
    // an unfinished name goes on after a space
    assertThat(texts(complete("mechs with 2 medium "))).contains("medium laser");
  }

  @Test
  void grammarWordsThenGroupsThenItems() {
    List<String> options = texts(complete("mechs with 2 la"));
    assertThat(options).startsWith("lasers").contains("large laser");
    assertThat(options.indexOf("lasers")).isLessThan(options.indexOf("large laser"));
    assertThat(texts(complete("me"))).startsWith("mechs", "medium");
    for (String query : new String[] {"mechs with 2 la", "mechs with 2 me", "mechs with a", "me", "mechs with li"}) {
      assertThat(texts(complete(query))).as(query).hasSizeLessThanOrEqualTo(8).doesNotHaveDuplicates();
    }
  }

  @Test
  void onlyWhatFitsThere() {
    // a weight class or unit word isn't equipment
    assertThat(texts(complete("mechs with 2 hea"))).doesNotContain("heavy");
    // nor where an ending would make it one ("medium" + " lasers")
    assertThat(texts(complete("mechs with 2 med"))).doesNotContain("medium");
    // a second "with" parses, but isn't meant
    assertThat(texts(complete("mechs with ar"))).doesNotContain("armed with");
    assertThat(texts(complete("mechs ar"))).contains("armed with");
    assertThat(texts(complete("mechs with 2 vehi"))).doesNotContain("vehicles");
    // the first unit word is the only one
    assertThat(texts(complete("mechs tan"))).doesNotContain("tanks");
    // every equipment option is a search as it is
    for (String query : new String[] {"mechs with 2 la", "mechs with 2 me", "tanks with lr"}) {
      Completions found = complete(query);
      assertThat(texts(found)).as(query).isNotEmpty();
      found.getOptions().stream().filter(option -> option.getText().contains(" ")).forEach(option -> assertThat(
          QueryParser.parse(query.substring(0, option.getStart()) + option.getText(), equipRepo)).isNotNull());
    }
  }

  @Test
  void nothingToComplete() {
    for (String query : new String[] {"", " ", "h", "mechs with 2 l", "zzzz", "mechs with 2 zzzz", "mechs with 20",
        "hevy mechs wi"}) {
      assertThat(texts(complete(query))).as(query).isEmpty();
    }
    // not itself, and after a whole search and a space only longer names, not a new term
    assertThat(texts(complete("mechs with 2 medium laser"))).doesNotContain("medium laser");
    assertThat(texts(complete("mechs with 2 lrm 20 "))).allMatch(option -> option.startsWith("lrm 20 "));
    assertThat(texts(complete("mechs "))).isEmpty();
    assertThat(texts(complete("mechs with 2 ppc and 3 medium laser "))).isEmpty();
    assertThat(texts(autocomplete.complete("x".repeat(501), 501))).isEmpty();
  }

  @Test
  void saysWhetherTheQueryIsAWholeSearch() {
    assertThat(complete("mechs with 2 ppc ").isComplete()).isTrue();
    assertThat(complete("mechs ").isComplete()).isTrue();
    assertThat(complete("mechs with 2 medium ").isComplete()).isFalse();
    assertThat(complete("heavy ").isComplete()).isFalse();
    assertThat(complete("").isComplete()).isFalse();
  }

  @Test
  void aSpaceAfterAGroupListsItsLongerNames() {
    // "2 lrm" is already a whole search (any LRM); the sizes are listed beside the gray "and" (user, 2026-11-22)
    Completions lrm = complete("mechs with 2 lrm ");
    assertThat(lrm.isComplete()).isTrue();
    assertThat(texts(lrm)).contains("lrm 20").allMatch(option -> option.startsWith("lrm "));
    // sizes by value
    assertThat(texts(complete("mechs with 2 srm ")).stream().filter(option -> option.matches("srm \\d+")).toList())
        .containsExactly("srm 2", "srm 4", "srm 6");
    assertThat(lrm.getOptions()).extracting(Completions.Option::getStart).containsOnly("mechs with 2 ".length());
    assertThat(texts(complete("mechs with 2 ppc and 1 lrm "))).contains("lrm 20");
  }

  @Test
  void aWholeSearchGoesOnWithAnotherTerm() {
    // the operator, then the next term after it
    assertThat(texts(complete("mechs with 2 ppc an"))).startsWith("and");
    assertThat(texts(complete("mechs with 2 ppc o"))).isEmpty();
    assertThat(texts(complete("mechs with 2 ppc and 3 med"))).contains("medium laser").doesNotContain("medium");
    assertThat(texts(complete("mechs with 2 ppc or 1 lr"))).contains("lrms", "lrm 20");
    assertThat(texts(complete("mechs with 2 ppc and me"))).contains("medium laser");
    assertThat(texts(complete("heavy mechs with 2 ppc and wi"))).contains("with", "without");
    assertThat(texts(complete("mechs with 2 ppc and without la"))).startsWith("lasers");
    assertThat(texts(complete("mechs with 2 ppc and an xl en"))).containsExactly("xl engine");
    // each option replaces only the new term
    Completions second = complete("mechs with 2 ppc and 3 medium la");
    assertThat(texts(second)).contains("medium laser");
    assertThat(second.getOptions()).extracting(Completions.Option::getStart)
        .containsOnly("mechs with 2 ppc and 3 ".length());
    // a third term, after a term that has a number in its name
    assertThat(texts(complete("mechs with 2 lrm 20 and 1 med"))).contains("medium laser");
    // still a whole search before the new term, but not with half a term
    assertThat(complete("mechs with 2 ppc and 3 med").isComplete()).isFalse();
    assertThat(complete("mechs with 2 ppc and 3 medium laser").isComplete()).isTrue();
  }

  @Test
  void inTheMiddleOfAQueryTheRestHasToFit() {
    Completions heavy = autocomplete.complete("hea mechs with 2 ppc", 3);
    assertThat(texts(heavy)).containsExactly("heavy");
    assertThat(heavy.getOptions().get(0).getStart()).isZero();
    assertThat(heavy.getStop()).isEqualTo(3);
    // the caret inside a word
    assertThat(texts(autocomplete.complete("heavy mechs", 3))).isEmpty();
  }

  @Test
  void theSearchBoxAsksForThemAsJson() throws Exception {
    mvc.perform(get("/api/completions").param("query", "hea").param("caret", "3"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.stop").value(3))
        .andExpect(jsonPath("$.options[0].start").value(0))
        .andExpect(jsonPath("$.options[0].text").value("heavy"))
        .andExpect(jsonPath("$.complete").value(false));
    // a caret outside the query is moved to its end
    mvc.perform(get("/api/completions").param("query", "hea").param("caret", "99"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.stop").value(3));
    mvc.perform(get("/api/completions").param("query", "hea").param("caret", "-5"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.options").isEmpty());
  }
}
