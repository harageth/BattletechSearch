package com.battletech.search.services;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.battletech.search.TestcontainersConfiguration;
import com.battletech.search.model.search.FailedParseException;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;

/**
 * End-to-end search results against the baseline unit data loaded by Flyway.
 * These pin current behavior so refactors can be checked against it.
 */
@SpringBootTest
@Import(TestcontainersConfiguration.class)
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
    assertThat(search("light units with at most 2 mediumlaser and at least 1 srm6"))
        .containsExactlyInAnyOrder(
            "Commando COM-5S",
            "Commando COM-3A",
            "Commando COM-2D",
            "Cossack C-SK1",
            "Longshot LNG-1B",
            "packrat lrpv pkr-t5 (ml)",
            "pegasus scout hover tank (standard)",
            "Raven RVN-3L",
            "Raven RVN-4X",
            "Raven RVN-2X",
            "Raven RVN-3X",
            "Raven RVN-1X");
  }

  @Test
  void atLeast() throws IOException {
    assertThat(search("mechs with at least 4 ppc"))
        .containsExactlyInAnyOrder("Annihilator ANH-1E", "Awesome AWS-9Q (Klatt)", "Awesome AWS-9Q");
    // includes mechs whose PPCs the baseline stores as "particlecannon" (e.g. Devastator DVS-2)
    assertThat(search("mechs with at least 2 ppc")).hasSize(66);
  }

  @Test
  void weightClassAndUnitType() throws IOException {
    assertThat(search("assault mechs with at least 3 ppc"))
        .containsExactlyInAnyOrder(
            "Annihilator ANH-1E",
            "Awesome AWS-8Q",
            "Awesome AWS-8Q (Buck)",
            "Awesome AWS-9Q (Klatt)",
            "Awesome AWS-9Q",
            "Titan TI-1Ar");
    assertThat(search("heavy mechs with less than 2 ppc")).hasSize(36);
  }

  @Test
  void exactlyAndGreaterThan() throws IOException {
    assertThat(search("mechs with exactly 4 largelaser")).containsExactly("Charger CGR-SB 'Challenger'");
    assertThat(search("mechs with greater than 5 erlargelaser")).containsExactly("Supernova (Standard)");
  }

  @Test
  void andOr() throws IOException {
    assertThat(search("mechs with at least 4 ppc and at least 2 mediumlaser"))
        .containsExactly("Annihilator ANH-1E");
    assertThat(search("units with at least 6 mediumlaser or at least 3 largelaser")).hasSize(44);
  }

  @Test
  void vehicleUnitTypes() throws IOException {
    assertThat(search("vtol with at least 1 mediumlaser")).hasSize(18);
    assertThat(search("vehicle with at least 2 lrm20")).hasSize(27);
  }

  @Test
  void resultsAreOrderedByName() throws IOException {
    List<Map<String, Object>> rows = service.performQuery("mechs with at least 2 ppc");
    List<String> names = rows.stream().map(row -> (String) row.get("name")).collect(Collectors.toList());
    assertThat(names).isSortedAccordingTo(String::compareTo);
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
    assertThat(search("units with 2 ppc")).isNotEmpty();
  }

  @Test
  void equipmentNamesCanHaveSpaces() throws IOException {
    List<String> largeLasers = search("mechs with exactly 4 largelaser");
    assertThat(search("mechs with exactly 4 large laser")).isEqualTo(largeLasers);
    assertThat(search("mechs with exactly 4 Large Laser")).isEqualTo(largeLasers);
    assertThat(search("mechs with at least 2 ER Large Laser")).isEqualTo(search("mechs with at least 2 erlargelaser"));
  }

  @Test
  void findsEquipmentStoredUnderOlderSpellings() throws IOException {
    // the baseline stores the Blackjack BJ-1's AC/2s as "autocannon/2" and others as "ac/2"
    assertThat(search("mechs with at least 2 ppc")).contains("Devastator DVS-2");
    assertThat(search("mechs with exactly 2 ac 2")).contains("Blackjack BJ-1");
    assertThat(search("mechs with exactly 2 autocannon 2")).isEqualTo(search("mechs with exactly 2 ac 2"));
    // "lbxac10" and "lb10-xac", "mg" and "machinegun" are both in the baseline too
    assertThat(search("units with at least 1 lb 10-x ac")).containsAll(search("units with at least 1 lbxac10"));
    assertThat(search("units with at least 1 machine gun")).containsAll(search("units with at least 1 mg"));
  }

  @Test
  void equipmentNamesCanEndInANumber() throws IOException {
    List<String> lrm20 = search("units with at least 2 lrm20");
    assertThat(lrm20).isNotEmpty();
    assertThat(search("units with at least 2 lrm 20")).isEqualTo(lrm20);
    assertThat(search("units with at least 2 LRM 20")).isEqualTo(lrm20);
    assertThat(search("mechs with exactly 2 srm 6")).isEqualTo(search("mechs with exactly 2 srm6"));
    assertThat(search("mechs with at least 2 lrm 20 and at least 2 srm 6"))
        .isEqualTo(search("mechs with at least 2 lrm20 and at least 2 srm6"));
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
    List<String> tanks = search("tanks with at least 2 lrm20");
    List<String> vtols = search("vtol with at least 2 lrm20");

    assertThat(tanks).isNotEmpty();
    assertThat(search("vehicle with at least 2 lrm20"))
        .containsExactlyInAnyOrderElementsOf(Stream.concat(tanks.stream(), vtols.stream()).toList());
  }

  @Test
  void baselineVehiclesHaveNoMotiveType() throws IOException {
    // the V2 baseline predates motive types; imported units have them (see UnitServiceImportTest)
    assertThat(search("tracked with at least 2 lrm20")).isEmpty();
  }

  @Test
  void syntaxErrorsFail() {
    assertThatThrownBy(() -> search("mechs with"))
        .isInstanceOf(FailedParseException.class)
        .hasMessageStartingWith("Unable to parse query");
  }
}
