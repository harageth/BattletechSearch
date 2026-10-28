package com.battletech.search.model;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** Every tech base spelling in the pinned mm-data commit (.mtf techbase: and .blk <type>). */
class TechTest {

  @ParameterizedTest
  @CsvSource(delimiter = '|', value = {
      "Inner Sphere                       | INNER_SPHERE | INNER_SPHERE",
      "Clan                               | CLAN         | CLAN",
      "Mixed (IS Chassis)                 | MIXED_TECH   | INNER_SPHERE",
      "Mixed (Clan Chassis)               | MIXED_TECH   | CLAN",
      "IS Level 1                         | INNER_SPHERE | INNER_SPHERE",
      "IS Level 4                         | INNER_SPHERE | INNER_SPHERE",
      "Clan Level 2                       | CLAN         | CLAN",
      "Clan Level 3                       | CLAN         | CLAN",
      "Mixed (IS Chassis) Advanced        | MIXED_TECH   | INNER_SPHERE",
      "Mixed (IS Chassis) Experimental    | MIXED_TECH   | INNER_SPHERE",
      "Mixed (Clan Chassis) Experimental  | MIXED_TECH   | CLAN",
      // the vehicle bug this replaced: "chassis" contains "is"
      "mixed (clan chassis) experimental  | MIXED_TECH   | CLAN",
  })
  void readsMegaMekTechBases(String techBase, Tech tech, Tech chassis) {
    assertThat(Tech.fromTechBase(techBase)).isEqualTo(tech);
    assertThat(Tech.chassisTech(techBase)).isEqualTo(chassis);
  }

  @ParameterizedTest
  @CsvSource({"IS, INNER_SPHERE", "Clan, CLAN"})
  void readsHeatSinkTechWords(String word, Tech tech) {
    assertThat(Tech.fromTechBase(word)).isEqualTo(tech);
  }
}
