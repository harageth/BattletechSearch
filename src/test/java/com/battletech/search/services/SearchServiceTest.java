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
  void syntaxErrorsFail() {
    assertThatThrownBy(() -> search("mechs with"))
        .isInstanceOf(FailedParseException.class)
        .hasMessageStartingWith("Unable to parse query");
  }
}
