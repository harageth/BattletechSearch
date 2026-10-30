package com.battletech.search.web;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.TestcontainersConfiguration;
import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.model.Tech;
import com.battletech.search.web.VocabularyController.Vocabulary;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

/** The search box's word lists and scripts, from the real server against the baseline data. */
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Import(TestcontainersConfiguration.class)
class VocabularyControllerTest {
  @Autowired
  TestRestTemplate rest;

  @Test
  void listsTheWordsAQueryCanUse() {
    ResponseEntity<Vocabulary> response = rest.getForEntity("/api/vocabulary", Vocabulary.class);
    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(response.getHeaders().getCacheControl()).isEqualTo("max-age=3600");
    Vocabulary vocabulary = response.getBody();
    assertThat(vocabulary.weightClasses()).isEqualTo(QueryVocabulary.weightClasses());
    assertThat(vocabulary.units()).isEqualTo(QueryVocabulary.units());
    assertThat(vocabulary.comparatorsBefore()).contains("at least", "no more than");
    assertThat(vocabulary.comparatorsAfter()).containsExactly("or more", "or fewer", "or less");
    assertThat(vocabulary.withWords()).isEqualTo(QueryVocabulary.withWords());
    assertThat(vocabulary.techs()).containsEntry("clan", Tech.CLAN).containsEntry("is", Tech.INNER_SPHERE);
    assertThat(vocabulary.fireControls()).contains("artemis", "apollo");
  }

  @Test
  void listsTheWeaponsOfEachFamilyThatUnitsHave() {
    Vocabulary vocabulary = rest.getForObject("/api/vocabulary", Vocabulary.class);
    assertThat(vocabulary.families()).containsKeys("lasers", "lrms", "srms", "streaks", "ppcs", "autocannons");
    assertThat(vocabulary.families().get("lrms")).contains("lrm 20", "lrm 10").doesNotContain("lrt 20");
    assertThat(vocabulary.families().get("ppcs")).contains("ppc", "er ppc");
    assertThat(vocabulary.equipment().get("streak srm 6")).containsExactly("srms", "streaks");
    // only what a query can type: "Flamer (Vehicle)" has parentheses
    assertThat(vocabulary.families().get("flamers")).contains("flamer").doesNotContain("flamer (vehicle)");
    assertThat(vocabulary.families().values()).allSatisfy(members ->
        assertThat(members).allMatch(QueryVocabulary::isTypeable));
  }

  @Test
  void servesTheScriptsAndTheParserForTheBrowser() {
    for (String script : new String[] {"/js/query-input.js", "/js/query-analysis.js",
        "/js/grammar/me/BattletechParser.js", "/js/grammar/me/BattletechLexer.js", "/vendor/antlr4/antlr4.web.js"}) {
      ResponseEntity<String> response = rest.getForEntity(script, String.class);
      assertThat(response.getStatusCode()).as(script).isEqualTo(HttpStatus.OK);
      // module scripts only run when served as JavaScript
      assertThat(response.getHeaders().getContentType().isCompatibleWith(MediaType.valueOf("text/javascript")))
          .as(script + " is " + response.getHeaders().getContentType()).isTrue();
    }
  }
}
