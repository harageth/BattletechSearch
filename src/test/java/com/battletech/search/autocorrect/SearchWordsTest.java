package com.battletech.search.autocorrect;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class SearchWordsTest {
  @Test
  void phrasesComeByKindThenWithNumbersByValue() {
    List<SearchWords.Phrase> phrases = SearchWords.phrases(List.of("heavy"), List.of("lrm ammo", "lrms"),
        List.of("lrm 20", "lrm 5", "lrm 10 ammo", "lrm 10", "lrm 15", "LRM 5"), List.of("helo"));
    assertThat(phrases).extracting(SearchWords.Phrase::getText)
        .containsExactly("heavy", "lrm ammo", "lrms", "lrm 5", "lrm 10", "lrm 10 ammo", "lrm 15", "lrm 20", "helo");
    assertThat(phrases).extracting(SearchWords.Phrase::getKind).containsSequence(
        SearchWords.Kind.FIXED, SearchWords.Kind.GROUP);
  }

  @Test
  void naturalOrder() {
    assertThat(SearchWords.compareNaturally("ac 2", "ac 10")).isNegative();
    assertThat(SearchWords.compareNaturally("ac 10", "ac 10 ammo")).isNegative();
    assertThat(SearchWords.compareNaturally("ac/2", "ac/20")).isNegative();
    assertThat(SearchWords.compareNaturally("mml 3", "mml 3")).isZero();
    assertThat(SearchWords.compareNaturally("a" + "9".repeat(40), "a" + "1" + "0".repeat(40))).isNegative();
  }
}
