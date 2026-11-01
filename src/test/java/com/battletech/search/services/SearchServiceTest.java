package com.battletech.search.services;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.battletech.search.SearchFixtures;
import com.battletech.search.TestcontainersConfiguration;
import com.battletech.search.model.search.FailedParseException;
import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;

/**
 * End-to-end search results against the fixture units (SearchFixtures: src/test/resources/megamek),
 * imported the way the admin import does it, slang included.
 */
@SpringBootTest
@Import({TestcontainersConfiguration.class, SearchFixtures.class})
class SearchServiceTest {
  @Autowired
  SearchService service;

  private List<String> search(String query) throws IOException {
    return service.performQuery(query).stream()
        .map(SearchServiceTest::nameAndDesignation)
        .collect(Collectors.toList());
  }

  private static String nameAndDesignation(Map<String, Object> row) {
    return row.get("name") + " " + row.get("designation");
  }

  @Test
  void weightClassWithAndedComparators() throws IOException {
    // the Jenner JR7-D is light with four medium lasers but no SRM 6
    assertThat(search("light units with at most 2 mediumlaser and at least 1 srm6"))
        .containsExactly("Commando COM-2D");
  }

  @Test
  void atLeast() throws IOException {
    assertThat(search("mechs with at least 4 ppc")).containsExactly("Annihilator ANH-1E");
    assertThat(search("mechs with at least 2 ppc"))
        .containsExactlyInAnyOrder("Annihilator ANH-1E", "Awesome AWS-8Q", "Warhammer WHM-6R");
  }

  @Test
  void weightClassAndUnitType() throws IOException {
    assertThat(search("assault mechs with at least 3 ppc"))
        .containsExactlyInAnyOrder("Annihilator ANH-1E", "Awesome AWS-8Q");
    assertThat(search("heavy mechs with less than 2 ppc"))
        .contains("Black Knight BL-6-KNT").doesNotContain("Warhammer WHM-6R");
  }

  @Test
  void exactlyAndGreaterThan() throws IOException {
    assertThat(search("mechs with exactly 4 largelaser")).containsExactly("Charger CGR-SB 'Challenger'");
    assertThat(search("mechs with greater than 5 erlargelaser")).containsExactly("Supernova 5");
  }

  @Test
  void andOr() throws IOException {
    assertThat(search("mechs with at least 4 ppc and at least 2 mediumlaser"))
        .containsExactly("Annihilator ANH-1E");
    assertThat(search("units with at least 4 mediumlaser or at least 3 largelaser"))
        .contains("Annihilator ANH-1E", "Atlas AS7-D", "Blackjack BJ-1", "Jenner JR7-D", "Charger CGR-SB 'Challenger'")
        .doesNotContain("Rifleman RFL-3N");
  }

  @Test
  void vehicleUnitTypes() throws IOException {
    assertThat(search("vtol with at least 1 mediumlaser")).containsExactly("Cavalry Attack Helicopter (BA)");
    assertThat(search("vehicle with at least 2 lrm20")).contains("DI Morgan Assault Tank (LRM)");
  }

  @Test
  void resultsAreOrderedByName() throws IOException {
    List<Map<String, Object>> rows = service.performQuery("mechs with at least 1 mediumlaser");
    List<String> names = rows.stream().map(row -> (String) row.get("name")).collect(Collectors.toList());
    // the database's collation skips spaces: "Blackjack" before "Black Knight"
    assertThat(names).hasSizeGreaterThan(2)
        .isSortedAccordingTo(Comparator.comparing(name -> name.replace(" ", "").toLowerCase()));
  }

  @Test
  void unknownEquipmentFailsToParse() {
    assertThatThrownBy(() -> search("mechs with at least 2 nonexistentgun"))
        .isInstanceOf(FailedParseException.class)
        .hasMessage("Unable to parse: nonexistentgun");
  }

  @Test
  void quantityWithoutComparatorMeansExactly() throws IOException {
    assertThat(search("mechs with 4 largelaser")).isEqualTo(search("mechs with exactly 4 largelaser"));
    assertThat(search("units with 2 ppc")).containsExactly("Warhammer WHM-6R");
  }

  @Test
  void equipmentNamesCanHaveSpaces() throws IOException {
    List<String> largeLasers = search("mechs with exactly 4 largelaser");
    assertThat(search("mechs with exactly 4 large laser")).isEqualTo(largeLasers);
    assertThat(search("mechs with exactly 4 Large Laser")).isEqualTo(largeLasers);
    assertThat(search("mechs with at least 2 ER Large Laser")).isEqualTo(search("mechs with at least 2 erlargelaser"));
  }

  @Test
  void findsEquipmentByAnyOfItsMegaMekNames() throws IOException {
    // MegaMek's other names for a weapon are slang terms for it
    assertThat(search("mechs with exactly 2 ac 2")).contains("Blackjack BJ-1");
    assertThat(search("mechs with exactly 2 autocannon 2")).isEqualTo(search("mechs with exactly 2 ac 2"));
    assertThat(search("units with at least 1 lb 10-x ac")).contains("Centurion CN9-D")
        .isEqualTo(search("units with at least 1 lbxac10"));
    assertThat(search("units with at least 2 machine gun")).contains("Warhammer WHM-6R")
        .isEqualTo(search("units with at least 2 mg"));
  }

  @Test
  void equipmentNamesCanEndInANumber() throws IOException {
    List<String> lrm20 = search("units with at least 2 lrm20");
    assertThat(lrm20).isNotEmpty();
    assertThat(search("units with at least 2 lrm 20")).isEqualTo(lrm20);
    assertThat(search("units with at least 2 LRM 20")).isEqualTo(lrm20);
    assertThat(search("mechs with exactly 1 srm 6")).isEqualTo(search("mechs with exactly 1 srm6"));
    assertThat(search("mechs with at least 1 lrm 20 and at least 1 srm 6"))
        .isEqualTo(search("mechs with at least 1 lrm20 and at least 1 srm6"));
  }

  @Test
  void numberWordsMatchDigits() throws IOException {
    assertThat(search("mechs with at least four ppc")).isEqualTo(search("mechs with at least 4 ppc"));
  }

  @Test
  void orFewerIncludesTheQuantity() throws IOException {
    assertThat(search("heavy mechs with 1 or fewer ppc"))
        .containsExactlyInAnyOrderElementsOf(search("heavy mechs with at most 1 ppc"));
    assertThat(search("mechs with 4 or more ppc")).isEqualTo(search("mechs with at least 4 ppc"));
  }

  @Test
  void chunksWithoutOperatorAreAnded() throws IOException {
    assertThat(search("mechs with at least 4 ppc at least 2 mediumlaser"))
        .isEqualTo(search("mechs with at least 4 ppc and at least 2 mediumlaser"));
  }

  @Test
  void tanksAreVehiclesExceptVtols() throws IOException {
    List<String> tanks = search("tanks with at least 1 mediumlaser");
    List<String> vtols = search("vtol with at least 1 mediumlaser");

    assertThat(tanks).isNotEmpty();
    assertThat(vtols).isNotEmpty();
    assertThat(search("vehicle with at least 1 mediumlaser"))
        .containsExactlyInAnyOrderElementsOf(Stream.concat(tanks.stream(), vtols.stream()).toList());
  }

  @Test
  void mechsByBodyPlan() throws IOException {
    assertThat(search("lams")).containsExactly("Phoenix Hawk LAM Mk I PHX-HK1");
    assertThat(search("quadvees")).containsExactly("Boreas A");
    assertThat(search("tripods")).containsExactly("Poseidon PSD-V2");
    assertThat(search("quads")).containsExactly("Goliath GOL-1H");
    assertThat(search("bipeds")).contains("Mad Cat Prime", "Atlas AS7-D")
        .doesNotContain("Phoenix Hawk LAM Mk I PHX-HK1", "Boreas A", "Poseidon PSD-V2", "Goliath GOL-1H");
    assertThat(search("assault tripods with at least 2 ppc")).isEmpty();
  }

  @Test
  void omniOrNot() throws IOException {
    assertThat(search("omnimechs")).containsExactlyInAnyOrder("Boreas A", "Flamberge D", "Mad Cat Prime");
    assertThat(search("omni mechs")).isEqualTo(search("omnimechs"));
    assertThat(search("omni vehicles")).containsExactly("Badger (C) Tracked Transport A");
    List<String> mechs = search("mechs");
    assertThat(search("non-omni mechs")).hasSize(mechs.size() - 3).doesNotContain("Mad Cat Prime", "Boreas A");
  }

  @Test
  void components() throws IOException {
    assertThat(search("mechs with an xl engine")).containsExactlyInAnyOrder(
        "Centurion CN9-D", "Flamberge D", "Mad Cat Prime", "Poseidon PSD-V2", "Thresher (Edward)");
    assertThat(search("mechs with a clan xl engine"))
        .containsExactlyInAnyOrder("Flamberge D", "Mad Cat Prime", "Thresher (Edward)");
    assertThat(search("mechs with endo steel"))
        .contains("Black Knight BL-6-KNT", "Centurion CN9-D", "Supernova 5", "Mad Cat Prime", "Poseidon PSD-V2")
        .doesNotContain("Atlas AS7-D", "Warhammer WHM-6R");
    assertThat(search("mechs with endo steel and ferro-fibrous armor")).containsExactly("Mad Cat Prime");
    assertThat(search("mechs with a superheavy tripod cockpit")).containsExactly("Poseidon PSD-V2");
    assertThat(search("mechs with an engine rating of at least 300"))
        .contains("Atlas AS7-D", "Centurion CN9-D", "Goliath GOL-1H", "Mad Cat Prime", "Poseidon PSD-V2")
        .doesNotContain("Commando COM-2D", "Warhammer WHM-6R");
    assertThat(search("mechs with engine rating 300 or more")).isEqualTo(search("mechs with an engine rating of at least 300"));
  }

  @Test
  void withoutIsEverythingElse() throws IOException {
    List<String> mechs = search("mechs");
    List<String> xl = search("mechs with an xl engine");
    assertThat(search("mechs without an xl engine")).doesNotContainAnyElementsOf(xl)
        .containsExactlyInAnyOrderElementsOf(mechs.stream().filter(mech -> !xl.contains(mech)).toList());
    List<String> ppcs = search("mechs with ppcs");
    assertThat(ppcs).contains("Annihilator ANH-1E", "Warhammer WHM-6R");
    assertThat(search("mechs without ppcs"))
        .containsExactlyInAnyOrderElementsOf(mechs.stream().filter(mech -> !ppcs.contains(mech)).toList());
    assertThat(search("assault mechs with at least 2 ppc and without any lasers")).isEmpty();
  }

  @Test
  void withoutAListIsNoneOfIt() throws IOException {
    List<String> mechs = search("mechs");
    List<String> ppcs = search("mechs with ppcs");
    List<String> lasers = search("mechs with lasers");
    assertThat(search("mechs without ppcs or lasers")).isNotEmpty().containsExactlyInAnyOrderElementsOf(
        mechs.stream().filter(mech -> !ppcs.contains(mech) && !lasers.contains(mech)).toList());
    assertThat(search("mechs with no ppcs and no lasers")).isEqualTo(search("mechs without ppcs or lasers"));
    assertThat(search("mechs lacking ppcs")).isEqualTo(search("mechs without ppcs"));
    assertThat(search("mechs that don't have ppcs")).isEqualTo(search("mechs without ppcs"));
  }

  @Test
  void unitsLeftOut() throws IOException {
    List<String> mechs = search("mechs");
    assertThat(search("non-lam mechs")).hasSize(mechs.size() - 1).doesNotContain("Phoenix Hawk LAM Mk I PHX-HK1");
    assertThat(search("mechs except lams, quads, tripods and quadvees")).isEqualTo(search("bipeds"));
    assertThat(search("mechs that aren't omnis")).isEqualTo(search("non-omni mechs"));
    assertThat(search("units except mechs")).isEqualTo(search("vehicles"));
    assertThat(search("units that aren't vtols")).doesNotContain("Cavalry Attack Helicopter (BA)")
        .contains("Badger (C) Tracked Transport A", "Atlas AS7-D");
  }

  @Test
  void syntaxErrorsFail() {
    assertThatThrownBy(() -> search("mechs with"))
        .isInstanceOf(FailedParseException.class)
        .hasMessageStartingWith("Unable to parse query");
  }
}
