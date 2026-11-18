package com.battletech.search.autocorrect;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class TypoMatcherTest {
  private static final SearchWords WORDS = SearchWords.of(
      List.of("heavy", "mechs", "with", "without", "at least", "and", "clan", "omni", "lasers"),
      List.of("Medium Laser", "ER Medium Laser", "XL Engine", "Heavy PPC", "Flamer (Vehicle)", "LRM 20"));

  private static List<String> suggest(String typed) {
    return TypoMatcher.candidates(typed, WORDS).stream().map(TypoMatcher.Candidate::getText).toList();
  }

  @Test
  void aSwapAMissingAnExtraOrAWrongLetterIsOneEdit() {
    assertThat(TypoMatcher.distance("wtih", "with")).isEqualTo(1);
    assertThat(TypoMatcher.distance("mehcs", "mechs")).isEqualTo(1);
    assertThat(TypoMatcher.distance("engnie", "engine")).isEqualTo(1);
    assertThat(TypoMatcher.distance("lest", "least")).isEqualTo(1);
    assertThat(TypoMatcher.distance("heavvy", "heavy")).isEqualTo(1);
    assertThat(TypoMatcher.distance("mediun", "medium")).isEqualTo(1);
    assertThat(TypoMatcher.distance("lazers", "lasers")).isEqualTo(1);
    assertThat(TypoMatcher.distance("mediumm", "medium")).isEqualTo(1);
    assertThat(TypoMatcher.distance("abc", "abc")).isZero();
  }

  @Test
  void howFarOffAWordMayBeGoesByItsLength() {
    // as Elasticsearch's "fuzziness: AUTO" (user, 2026-11-18)
    assertThat(TypoMatcher.allowedEdits(2)).isZero();
    assertThat(TypoMatcher.allowedEdits(3)).isEqualTo(1);
    assertThat(TypoMatcher.allowedEdits(5)).isEqualTo(1);
    assertThat(TypoMatcher.allowedEdits(6)).isEqualTo(2);
    assertThat(suggest("hevy")).containsExactly("heavy");
    assertThat(suggest("mehcs")).containsExactly("mechs");
    assertThat(suggest("wtih")).containsExactly("with");
    assertThat(suggest("engnie")).containsExactly("engine");
    // a 5-letter word two edits off gets nothing
    assertThat(suggest("hxxvy")).isEmpty();
    // nor does a word of 1 or 2 letters
    assertThat(suggest("hw")).isEmpty();
  }

  @Test
  void aKnownWordIsNoTypo() {
    assertThat(suggest("heavy")).isEmpty();
    assertThat(suggest("HEAVY")).isEmpty();
    // equipment words, and whole names run together
    assertThat(suggest("medium")).isEmpty();
    assertThat(suggest("mediumlaser")).isEmpty();
    assertThat(suggest("lrm20")).isEmpty();
  }

  @Test
  void aWholeNameIsShownWithItsSpaces() {
    // matched run together, suggested as typed
    assertThat(suggest("mediumlasr")).contains("medium laser");
    assertThat(suggest("mediumlasr")).doesNotContain("mediumlaser");
  }

  @Test
  void twoWordsRunTogetherAreSplit() {
    assertThat(suggest("heavymechs")).contains("heavy mechs");
  }

  @Test
  void equallyCloseWordsPutTheGrammarsFirstThenGoAlphabetically() {
    SearchWords words = SearchWords.of(List.of("heavy"), List.of("heavi", "heave"));
    assertThat(TypoMatcher.candidates("heavq", words)).extracting(TypoMatcher.Candidate::getText)
        .containsExactly("heavy", "heave", "heavi");
  }

  @Test
  void bracketsArentPartOfASuggestedWord() {
    // "Flamer (Vehicle)": "vehicle" as typed, not "(vehicle)"
    assertThat(suggest("vehicel")).containsExactly("vehicle");
  }
}
