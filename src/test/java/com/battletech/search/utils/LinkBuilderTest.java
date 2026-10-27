package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class LinkBuilderTest {

  @Test
  void simpleName() {
    assertThat(LinkBuilder.buildSarnaUnitURI("Commando", "COM-5S"))
        .isEqualTo("https://www.sarna.net/wiki/Commando#COM-5S");
  }

  @Test
  void spacesBecomeUnderscoresAndSpecialCharactersAreEncoded() {
    assertThat(LinkBuilder.buildSarnaUnitURI("pegasus scout hover tank", "(standard)"))
        .isEqualTo("https://www.sarna.net/wiki/pegasus_scout_hover_tank#(standard)");
    assertThat(LinkBuilder.buildSarnaUnitURI("Charger", "CGR-SB 'Challenger'"))
        .isEqualTo("https://www.sarna.net/wiki/Charger#CGR-SB_'Challenger'");
    assertThat(LinkBuilder.buildSarnaUnitURI("Mad Cat", "Prime #2"))
        .isEqualTo("https://www.sarna.net/wiki/Mad_Cat#Prime_%232");
  }
}
