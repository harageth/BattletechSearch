package com.battletech.search.antlr;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Mech;
import com.battletech.search.model.MotiveSystem;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.EquipmentDecorator;
import com.battletech.search.model.FireControl;
import com.battletech.search.model.Tech;
import com.battletech.search.model.UnitDecorator;
import com.battletech.search.model.WeightClass;
import com.battletech.search.model.search.Comparison;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.model.search.LogicalOperator;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.utils.EquipmentNames;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * Parses queries the same way SearchService does, with a mocked equipment lookup, and checks
 * the unit/equipment structure the visitor builds. No database needed.
 */
class QueryVisitorTest {
  EquipmentRepository equipRepo;

  @BeforeEach
  void setUp() {
    equipRepo = mock(EquipmentRepository.class);
    // Every non-empty equipment name resolves to a single matching row by default, like the real data.
    // Like the slang tables, MegaMek's names find the display name ("ac 20" -> "ac/20").
    when(equipRepo.findAllByNameOrSlang(anyString(), anyString())).thenAnswer(invocation -> {
      String name = invocation.getArgument(0);
      return name.isEmpty() ? List.of() : List.of(equipment(EquipmentNames.canonical(name), Tech.INNER_SPHERE));
    });
  }

  private static Equipment equipment(String name, Tech tech) {
    Equipment equipment = new Equipment(name, tech);
    equipment.setId(UUID.randomUUID());
    return equipment;
  }

  private UnitDecorator parse(String query) {
    return (UnitDecorator) QueryParser.parse(query, equipRepo);
  }

  private static EquipmentDecorator chunk(Unit unit, int index) {
    return (EquipmentDecorator) unit.getMechEquipment().get(index);
  }

  @Test
  void fullQuery() {
    UnitDecorator unit = parse("light units with at most 2 mediumlaser and at least 1 srm6");

    assertThat(unit.getDecoratedUnit().getClass()).isEqualTo(Unit.class);
    assertThat(unit.getWeightClasses()).containsExactly(WeightClass.LIGHT);
    assertThat(unit.getMechEquipment()).hasSize(2);

    EquipmentDecorator first = chunk(unit, 0);
    assertThat(first.getEquipment().getName()).isEqualTo("mediumlaser");
    assertThat(first.getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
    assertThat(first.getQuantity()).isEqualTo(2);
    assertThat(first.getLogicOperator()).isEqualTo(LogicalOperator.AND);

    EquipmentDecorator second = chunk(unit, 1);
    assertThat(second.getEquipment().getName()).isEqualTo("srm6");
    assertThat(second.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(second.getQuantity()).isEqualTo(1);
    assertThat(second.getLogicOperator()).isNull();
  }

  @Test
  void unitTypes() {
    assertThat(parse("mechs with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Mech.class);
    assertThat(parse("vtol with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Vtol.class);
    assertThat(parse("vehicle with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Vehicle.class);
    assertThat(parse("units with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Unit.class);
    assertThat(parse("with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Unit.class);
  }

  @Test
  void unitTypesAreCaseInsensitiveAndPlural() {
    assertThat(parse("MECHS with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Mech.class);
    assertThat(parse("Units with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Unit.class);
  }

  private Tank tank(String query) {
    return (Tank) parse(query).getDecoratedUnit();
  }

  @Test
  void tanksAreAllGroundVehicles() {
    assertThat(parse("tanks with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Tank.class);
    assertThat(tank("Tank with at least 1 ppc").getMotiveSystem()).isNull();
    // boats are filed as tanks too, so plain "tank" leaves them out
    assertThat(parse("tanks with at least 1 ppc").getQuery())
        .contains("dtype = 'Tank' AND (motive_system IS NULL OR motive_system NOT IN ('Hydrofoil', 'Naval', 'Submarine'))");
  }

  @Test
  void motiveTypesNarrowTanks() {
    assertThat(tank("tracked with at least 1 ppc").getMotiveSystem()).isEqualTo(MotiveSystem.Tracked);
    assertThat(tank("wheeled with at least 1 ppc").getMotiveSystem()).isEqualTo(MotiveSystem.Wheeled);
    assertThat(tank("hovertanks with at least 1 ppc").getMotiveSystem()).isEqualTo(MotiveSystem.Hover);
    assertThat(parse("tracked with at least 1 ppc").getQuery()).contains("dtype = 'Tank' AND motive_system = 'Tracked'");
  }

  @Test
  void weightClasses() {
    assertThat(parse("assault mechs with at least 1 ppc").getWeightClasses()).containsExactly(WeightClass.ASSAULT);
    assertThat(parse("ultra light mechs with at least 1 ppc").getWeightClasses()).containsExactly(WeightClass.ULTRA_LIGHT);
    assertThat(parse("mechs with at least 1 ppc").getWeightClasses()).isEmpty();
    assertThat(parse("assault mechs with at least 1 ppc").getQuery()).contains("AND weight_class IN ('ASSAULT')");
  }

  @Test
  void severalWeightClasses() {
    assertThat(parse("medium or heavy mechs with at least 1 ppc").getWeightClasses())
        .containsExactly(WeightClass.MEDIUM, WeightClass.HEAVY);
    assertThat(parse("light or ultra light or medium units with at least 1 ppc").getWeightClasses())
        .containsExactly(WeightClass.LIGHT, WeightClass.ULTRA_LIGHT, WeightClass.MEDIUM);
    // "and" reads the same: a light and a medium mech are both "light and medium mechs"
    assertThat(parse("light and medium mechs with at least 1 ppc").getWeightClasses())
        .containsExactly(WeightClass.LIGHT, WeightClass.MEDIUM);
    assertThat(parse("medium or heavy mechs with at least 1 ppc").getQuery())
        .contains("AND weight_class IN ('MEDIUM', 'HEAVY')");
    // commas, with or without "or" after the last one
    assertThat(parse("light, medium or heavy mechs with at least 1 ppc").getWeightClasses())
        .containsExactly(WeightClass.LIGHT, WeightClass.MEDIUM, WeightClass.HEAVY);
    assertThat(parse("light, medium, or heavy mechs with at least 1 ppc").getWeightClasses())
        .containsExactly(WeightClass.LIGHT, WeightClass.MEDIUM, WeightClass.HEAVY);
    assertThat(parse("light,medium,heavy mechs with at least 1 ppc").getWeightClasses())
        .containsExactly(WeightClass.LIGHT, WeightClass.MEDIUM, WeightClass.HEAVY);
    assertThatThrownBy(() -> parse("light, mechs with at least 1 ppc"))
        .hasMessage("Unable to parse query: expected a weight class like 'heavy' before 'mechs' (character 8)."
            + " Try something like 'mechs with at least 2 ppc'.");
    assertThatThrownBy(() -> parse("medium or mechs with at least 1 ppc"))
        .hasMessage("Unable to parse query: expected a weight class like 'heavy' before 'mechs' (character 11)."
            + " Try something like 'mechs with at least 2 ppc'.");
  }

  @Test
  void otherWordsForWith() {
    // the mocked equipment gets a new id per lookup
    String ids = "'[0-9a-f-]{36}'";
    String with = parse("mechs with 2 medium lasers").getQuery().replaceAll(ids, "ID");
    for (String query : List.of("mechs having 2 medium lasers", "mechs that have 2 medium lasers",
        "mechs which have 2 medium lasers", "mechs carrying 2 medium lasers", "mechs armed with 2 medium lasers",
        "heavy mechs having 2 medium lasers", "mechs that   have 2 medium lasers", "mechs armed\twith 2 medium lasers")) {
      assertThat(parse(query).getMechEquipment()).as(query).hasSize(1);
    }
    assertThat(parse("mechs having 2 medium lasers").getQuery().replaceAll(ids, "ID")).isEqualTo(with);
  }

  @Test
  void anyMeansAtLeastOne() {
    EquipmentDecorator any = chunk(parse("mechs with any ppc"), 0);
    assertThat(any.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(any.getQuantity()).isEqualTo(1);
    assertThat(chunk(parse("mechs with ANY ppc"), 0).getQuantity()).isEqualTo(1);
    EquipmentDecorator second = chunk(parse("mechs with at least 2 ppc and any lasers"), 1);
    assertThat(second.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(second.getQuantity()).isEqualTo(1);
  }

  @Test
  void comparators() {
    assertThat(chunk(parse("mechs with exactly 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL);
    assertThat(chunk(parse("mechs with = 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL);
    assertThat(chunk(parse("mechs with greater than 3 ppc"), 0).getComparison()).isEqualTo(Comparison.GREATER_THAN);
    // any spacing inside a comparator
    assertThat(chunk(parse("mechs with at   least 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(chunk(parse("mechs with no  more   than 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
    assertThat(chunk(parse("mechs with 3 or\tfewer ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
    assertThat(chunk(parse("mechs with less than 3 ppc"), 0).getComparison()).isEqualTo(Comparison.LESS_THAN);
    assertThat(chunk(parse("mechs with fewer than 3 ppc"), 0).getComparison()).isEqualTo(Comparison.LESS_THAN);
    assertThat(chunk(parse("mechs with at most 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
    assertThat(chunk(parse("mechs with no more than 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
    assertThat(chunk(parse("mechs with at least 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
  }

  @Test
  void multipleMeansMoreThanOne() {
    EquipmentDecorator chunk = chunk(parse("mechs with at least multiple ppc"), 0);
    assertThat(chunk.getComparison()).isEqualTo(Comparison.GREATER_THAN);
    assertThat(chunk.getQuantity()).isEqualTo(1);
  }

  @Test
  void orOperator() {
    UnitDecorator unit = parse("mechs with at least 4 ppc or at least 3 largelaser");
    assertThat(chunk(unit, 0).getLogicOperator()).isEqualTo(LogicalOperator.OR);
  }

  @Test
  void multiWordEquipmentIsNormalized() {
    // equipment is stored without spaces, so the lookup strips them too
    assertThat(chunk(parse("mechs with at least 1 Medium Laser"), 0).getEquipment().getName())
        .isEqualTo("mediumlaser");
  }

  private static List<String> names(UnitDecorator unit) {
    return unit.getMechEquipment().stream().map(equip -> equip.getEquipment().getName()).toList();
  }

  @Test
  void equipmentNamesCanEndInANumber() {
    EquipmentDecorator lrm = chunk(parse("mechs with at least 2 lrm 20"), 0);
    assertThat(lrm.getEquipment().getName()).isEqualTo("lrm20");
    assertThat(lrm.getQuantity()).isEqualTo(2);
    assertThat(lrm.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);

    assertThat(names(parse("mechs with 2 lrm 20"))).containsExactly("lrm20");
    assertThat(names(parse("mechs with 2 Streak SRM 6"))).containsExactly("streaksrm6");
    assertThat(chunk(parse("mechs with 4 or more ac 20"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(names(parse("mechs with 4 or more ac 20"))).containsExactly("ac/20");
  }

  @Test
  void techIsOptional() {
    Equipment isPpc = equipment("ppc", Tech.INNER_SPHERE);
    Equipment clanPpc = equipment("ppc", Tech.CLAN);
    when(equipRepo.findAllByNameOrSlang(eq("ppc"), anyString())).thenReturn(List.of(isPpc, clanPpc));

    // without a tech, IS and Clan PPCs are counted together in one group
    String query = chunk(parse("mechs with at least 4 ppc"), 0).getQuery();
    assertThat(query).contains("equipment_id IN ('" + clanPpc.getId() + "', '" + isPpc.getId() + "')");
    assertThat(query).doesNotContain("UNION");

    EquipmentDecorator clan = chunk(parse("mechs with at least 4 clan ppc"), 0);
    assertThat(clan.getEquipment()).isSameAs(clanPpc);
    assertThat(clan.getDecoratedEquipment()).isNull();
    assertThat(chunk(parse("mechs with at least 4 IS ppc"), 0).getEquipment()).isSameAs(isPpc);
    assertThat(chunk(parse("mechs with at least 4 inner sphere ppc"), 0).getEquipment()).isSameAs(isPpc);
    // the mock's equipment is IS by default
    assertThat(chunk(parse("mechs with 2 is artemis lrm 20"), 0).getFireControls())
        .containsExactlyInAnyOrder(FireControl.ARTEMIS_IV, FireControl.ARTEMIS_V);
  }

  @Test
  void aPluralKeepsTheTechBuiltIntoItsName() {
    Equipment isLrm = equipment("lrm20", Tech.INNER_SPHERE);
    Equipment clanLrm = equipment("lrm20", Tech.CLAN);
    when(equipRepo.findAllByNameOrSlang(eq("lrm20"), anyString())).thenReturn(List.of(isLrm, clanLrm));
    // like the real data, no equipment is spelled as the plural, and the slang term "cllrm20" (MegaMek's
    // Clan LRM 20) links only the Clan row
    when(equipRepo.findAllByNameOrSlang(eq("cllrm20s"), anyString())).thenReturn(List.of());
    when(equipRepo.findAllByNameOrSlang(eq("cllrm20"), anyString())).thenReturn(List.of(clanLrm));

    assertThat(chunk(parse("mechs with 2 cllrm20s"), 0).getEquipment()).isSameAs(clanLrm);
    assertThat(chunk(parse("mechs with 2 cllrm20s"), 0).getDecoratedEquipment()).isNull();
    // an IS Clan LRM 20 doesn't exist
    assertThat(chunk(parse("mechs with 2 is cllrm20s"), 0).isMatchesNothing()).isTrue();
  }

  @Test
  void equipmentNotMadeInATechMatchesNoUnits() {
    // only an IS plasma rifle exists, so "clan plasma rifle" finds no units rather than failing to parse
    when(equipRepo.findAllByNameOrSlang(eq("plasmarifle"), anyString()))
        .thenReturn(List.of(equipment("plasmarifle", Tech.INNER_SPHERE)));

    EquipmentDecorator clan = chunk(parse("mechs with at least 1 clan plasma rifle"), 0);
    assertThat(clan.isMatchesNothing()).isTrue();
    assertThat(clan.getQuery()).isEqualTo("SELECT unit_id FROM unit_mech_equipment WHERE false");

    assertThat(chunk(parse("mechs with at least 1 is plasma rifle"), 0).isMatchesNothing()).isFalse();
  }

  @Test
  void fireControlNarrowsALauncher() {
    EquipmentDecorator artemis = chunk(parse("mechs with 2 artemis lrm 20"), 0);
    assertThat(artemis.getEquipment().getName()).isEqualTo("lrm20");
    assertThat(artemis.getFireControls()).containsExactlyInAnyOrder(FireControl.ARTEMIS_IV, FireControl.ARTEMIS_V);
    assertThat(artemis.getQuery()).contains("AND fire_control IN ('ARTEMIS_IV', 'ARTEMIS_V')");

    assertThat(chunk(parse("mechs with at least 1 Artemis IV SRM 6"), 0).getFireControls())
        .containsExactly(FireControl.ARTEMIS_IV);
    assertThat(chunk(parse("mechs with 1 apollo mrm 40"), 0).getFireControls()).containsExactly(FireControl.APOLLO);

    EquipmentDecorator plain = chunk(parse("mechs with 2 lrm 20"), 0);
    assertThat(plain.getFireControls()).isNull();
    assertThat(plain.getQuery()).doesNotContain("fire_control");
  }

  @Test
  void aNumberBeforeAWordStartsTheNextChunk() {
    // "3" is followed by a name, so it's the next chunk's quantity, not part of "ppc"
    UnitDecorator unit = parse("mechs with 2 ppc 3 srm6");
    assertThat(names(unit)).containsExactly("ppc", "srm6");
    assertThat(chunk(unit, 1).getQuantity()).isEqualTo(3);

    UnitDecorator both = parse("mechs with 2 lrm 20 3 srm 6");
    assertThat(names(both)).containsExactly("lrm20", "srm6");
    assertThat(chunk(both, 0).getQuantity()).isEqualTo(2);
    assertThat(chunk(both, 1).getQuantity()).isEqualTo(3);
  }

  @Test
  void numberedNamesWithOperatorsAndComparators() {
    UnitDecorator unit = parse("mechs with at least 2 lrm 20 and at most 1 srm 6 or 2 ac 10");
    assertThat(names(unit)).containsExactly("lrm20", "srm6", "ac/10");
    assertThat(chunk(unit, 0).getLogicOperator()).isEqualTo(LogicalOperator.AND);
    assertThat(chunk(unit, 1).getLogicOperator()).isEqualTo(LogicalOperator.OR);
    assertThat(chunk(unit, 1).getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);

    assertThat(names(parse("mechs with at least 2 lrm 20 at least 1 ppc"))).containsExactly("lrm20", "ppc");
  }

  @Test
  void unknownEquipmentIsReportedAsTyped() {
    when(equipRepo.findAllByNameOrSlang(eq("mediumlazer"), anyString())).thenReturn(List.of());
    assertThatThrownBy(() -> parse("mechs with at least 2 Medium Lazer"))
        .hasMessage("Unable to parse: medium lazer");
  }

  @Test
  void equipmentMatchingSeveralRowsIsChained() {
    Equipment isPpc = equipment("ppc", Tech.INNER_SPHERE);
    Equipment clanPpc = equipment("ppc", Tech.CLAN);
    when(equipRepo.findAllByNameOrSlang(eq("ppc"), anyString())).thenReturn(List.of(isPpc, clanPpc));

    EquipmentDecorator outer = chunk(parse("mechs with at least 2 ppc"), 0);
    assertThat(outer.getEquipment()).isSameAs(clanPpc);
    assertThat(outer.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(outer.getQuantity()).isEqualTo(2);

    UnitEquipment inner = outer.getDecoratedEquipment();
    assertThat(inner.getEquipment()).isSameAs(isPpc);
    assertThat(((EquipmentDecorator) inner).getQuantity()).isEqualTo(2);
  }

  @Test
  void unknownEquipmentThrows() {
    when(equipRepo.findAllByNameOrSlang(eq("nonexistentgun"), anyString())).thenReturn(List.of());
    assertThatThrownBy(() -> parse("mechs with at least 2 nonexistentgun"))
        .isInstanceOf(FailedParseException.class)
        .hasMessage("Unable to parse: nonexistentgun");
  }

  @Test
  void quantityWithoutComparatorMeansExactly() {
    EquipmentDecorator chunk = chunk(parse("mechs with 2 ppc"), 0);
    assertThat(chunk.getComparison()).isEqualTo(Comparison.EQUAL);
    assertThat(chunk.getQuantity()).isEqualTo(2);
    assertThat(chunk.getEquipment().getName()).isEqualTo("ppc");
  }

  @Test
  void quantityBeforeComparator() {
    EquipmentDecorator chunk = chunk(parse("mechs with 3 or fewer ppc"), 0);
    assertThat(chunk.getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
    assertThat(chunk.getQuantity()).isEqualTo(3);
    assertThat(chunk(parse("mechs with 3 or less ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
    assertThat(chunk(parse("mechs with 3 or more ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
  }

  @Test
  void numberWords() {
    assertThat(chunk(parse("mechs with at least four ppc"), 0).getQuantity()).isEqualTo(4);
    assertThat(chunk(parse("mechs with at least Ten ppc"), 0).getQuantity()).isEqualTo(10);
    assertThat(chunk(parse("mechs with a ppc"), 0).getQuantity()).isEqualTo(1);
    assertThat(chunk(parse("mechs with double ppc"), 0).getQuantity()).isEqualTo(2);
  }

  @Test
  void multiDigitQuantity() {
    EquipmentDecorator chunk = chunk(parse("mechs with at least 10 ppc"), 0);
    assertThat(chunk.getQuantity()).isEqualTo(10);
    assertThat(chunk.getEquipment().getName()).isEqualTo("ppc");
  }

  @Test
  void chunksWithoutOperator() {
    UnitDecorator unit = parse("mechs with at least 2 ppc at least 1 srm6");
    assertThat(unit.getMechEquipment()).hasSize(2);
    assertThat(chunk(unit, 0).getLogicOperator()).isNull();
  }

  @Test
  void whitespaceAndTrailingNewline() {
    assertThat(chunk(parse("mechs\twith  at least 2 ppc\r\n"), 0).getQuantity()).isEqualTo(2);
  }

  @Test
  void singleLetterWordsAreNotNewlines() {
    // the old NEWLINE rule matched the letters r and n
    assertThat(chunk(parse("mechs with at least 2 n"), 0).getEquipment().getName()).isEqualTo("n");
  }

  @Test
  void syntaxErrorsExplainWhatIsWrong() {
    String example = " Try something like 'mechs with at least 2 ppc'.";
    assertThatThrownBy(() -> parse("mechs with"))
        .isInstanceOf(FailedParseException.class)
        .hasMessage("Unable to parse query: expected a quantity like '2' or 'at least 2' after 'with'." + example);
    assertThatThrownBy(() -> parse("mechs with at least 2"))
        .hasMessage("Unable to parse query: expected an equipment name after '2'." + example);
    assertThatThrownBy(() -> parse("mechs with 2"))
        .hasMessage("Unable to parse query: expected an equipment name after '2'." + example);
    assertThatThrownBy(() -> parse("mechs with 2 or fewer"))
        .hasMessage("Unable to parse query: expected an equipment name after 'or fewer'." + example);
    assertThatThrownBy(() -> parse("mechs with at least ppc"))
        .hasMessage("Unable to parse query: expected a quantity like '2' or 'at least 2' before 'ppc' (character 21)." + example);
    assertThatThrownBy(() -> parse("mechs at least 2 ppc"))
        .hasMessage("Unable to parse query: expected 'with' before 'at least' (character 7)." + example);
    assertThatThrownBy(() -> parse("mechs with at least 2 ppc with"))
        .hasMessage("Unable to parse query: didn't expect 'with' (character 27)." + example);
    assertThatThrownBy(() -> parse("mechs with at least 2 ppc's"))
        .hasMessage("Unable to parse query: can't use ''' (character 26). Use letters, numbers, '-' and '/'.");
    assertThatThrownBy(() -> parse(""))
        .hasMessage("Unable to parse query: the query is empty." + example);
  }
}
