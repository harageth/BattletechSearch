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
import com.battletech.search.model.ComponentFilter;
import com.battletech.search.model.EngineRatingFilter;
import com.battletech.search.model.EquipmentDecorator;
import com.battletech.search.model.FireControl;
import com.battletech.search.model.Locomotion;
import com.battletech.search.utils.ComponentNames;
import com.battletech.search.model.Tech;
import com.battletech.search.model.UnitDecorator;
import com.battletech.search.model.UnitFilter;
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

  private static EquipmentDecorator chunk(UnitDecorator unit, int index) {
    return (EquipmentDecorator) unit.getFilters().get(index);
  }

  @Test
  void fullQuery() {
    UnitDecorator unit = parse("light units with at most 2 mediumlaser and at least 1 srm6");

    assertThat(unit.getDecoratedUnit().getClass()).isEqualTo(Unit.class);
    assertThat(unit.getWeightClasses()).containsExactly(WeightClass.LIGHT);
    assertThat(unit.getFilters()).hasSize(2);

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
  void aMotiveTypeCanComeBeforeAVehicleWord() {
    for (String unit : new String[] {"tracked vehicles", "tracked vees", "tracked tanks", "Tracked Vehicle"}) {
      assertThat(tank(unit + " with at least 1 ppc").getMotiveSystem()).as(unit).isEqualTo(MotiveSystem.Tracked);
    }
    assertThat(tank("wheeled vehicles with at least 1 ppc").getMotiveSystem()).isEqualTo(MotiveSystem.Wheeled);
    assertThat(tank("hover tanks with at least 1 ppc").getMotiveSystem()).isEqualTo(MotiveSystem.Hover);
    assertThat(tank("hovercraft vees").getMotiveSystem()).isEqualTo(MotiveSystem.Hover);
    assertThat(tank("heavy tracked vehicles").getMotiveSystem()).isEqualTo(MotiveSystem.Tracked);
    assertThat(parse("vtol vehicles with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Vtol.class);
    assertThat(parse("vehicles except tracked vees").getQuery())
        .contains("AND NOT COALESCE((dtype = 'Tank' AND motive_system = 'Tracked'), false)");
  }

  @Test
  void weightClasses() {
    assertThat(parse("assault mechs with at least 1 ppc").getWeightClasses()).containsExactly(WeightClass.ASSAULT);
    assertThat(parse("ultra light mechs with at least 1 ppc").getWeightClasses()).containsExactly(WeightClass.ULTRA_LIGHT);
    assertThat(parse("mechs with at least 1 ppc").getWeightClasses()).isEmpty();
    assertThat(parse("assault mechs with at least 1 ppc").getQuery()).contains("AND weight_class IN ('ASSAULT')");
  }

  @Test
  void anUnknownWeightClassFails() {
    // left out, it would search every weight class
    assertThatThrownBy(() -> parse("hevy mechs with at least 1 ppc"))
        .isInstanceOf(FailedParseException.class)
        .hasMessage("Unknown weight class: hevy");
    assertThatThrownBy(() -> parse("light or hevy mechs"))
        .isInstanceOf(FailedParseException.class)
        .hasMessage("Unknown weight class: hevy");
  }

  @Test
  void everySpellingOfAUnitWordWorksAfterNon() {
    // the same words as the unit tokens: "hover" and "helicopter" are spellings of hovercraft and vtol
    assertThat(parse("non-hover tanks").getQuery())
        .contains("AND NOT COALESCE((dtype = 'Tank' AND motive_system = 'Hover'), false)");
    assertThat(parse("non hovertank vehicles").getQuery())
        .contains("AND NOT COALESCE((dtype = 'Tank' AND motive_system = 'Hover'), false)");
    assertThat(parse("non-helicopter vehicles").getQuery()).isEqualTo(parse("non-vtol vehicles").getQuery());
    assertThat(parse("non-vees units").getQuery()).isEqualTo(parse("non-vehicle units").getQuery());
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
      assertThat(parse(query).getFilters()).as(query).hasSize(1);
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
    return unit.getFilters().stream().map(filter -> ((EquipmentDecorator) filter).getEquipment().getName()).toList();
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
    assertThat(unit.getFilters()).hasSize(2);
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
    // "with" can come again ("without ppcs but with 2 lrm 20"), so what's missing is after it
    assertThatThrownBy(() -> parse("mechs with at least 2 ppc with"))
        .hasMessage("Unable to parse query: expected a quantity like '2' or 'at least 2' after 'with'." + example);
    assertThatThrownBy(() -> parse("mechs with at least 2 ppc's"))
        .hasMessage("Unable to parse query: can't use ''' (character 26). Use letters, numbers, '-' and '/'.");
    assertThatThrownBy(() -> parse(""))
        .hasMessage("Unable to parse query: the query is empty." + example);
  }

  @Test
  void aUnitAloneIsAQuery() {
    assertThat(parse("lams").getFilters()).isEmpty();
    assertThat(parse("heavy mechs").getQuery()).contains("dtype = 'Mech'").contains("weight_class IN ('HEAVY')");
    assertThat(parse("units").getQuery()).doesNotContain("id IN");
  }

  @Test
  void bodyPlanUnitWordsAreMechs() {
    for (String query : List.of("lams", "quadvees", "tripods", "quads", "bipeds", "lam", "QuadVee")) {
      assertThat(parse(query).getDecoratedUnit()).as(query).isExactlyInstanceOf(Mech.class);
    }
    assertThat(parse("lams").getLocomotion()).isEqualTo(Locomotion.LAM);
    assertThat(parse("quadvees").getLocomotion()).isEqualTo(Locomotion.QUADVEE);
    assertThat(parse("quads").getLocomotion()).isEqualTo(Locomotion.QUAD);
    assertThat(parse("heavy tripods with 2 ppc").getQuery()).contains("AND locomotion = 'TRIPOD'");
    assertThat(parse("mechs").getLocomotion()).isNull();
  }

  @Test
  void omniOrNot() {
    assertThat(parse("omnimechs").getDecoratedUnit()).isExactlyInstanceOf(Mech.class);
    assertThat(parse("omnimechs").getOmniFilter()).isTrue();
    assertThat(parse("omnis").getOmniFilter()).isTrue();
    assertThat(parse("omni mechs").getOmniFilter()).isTrue();
    assertThat(parse("heavy omni mechs with 2 ppc").getQuery()).contains("AND omni = true");
    assertThat(parse("omni vehicles").getDecoratedUnit()).isExactlyInstanceOf(Vehicle.class);
    for (String query : List.of("non-omni mechs", "non omni mechs", "nonomni mechs")) {
      assertThat(parse(query).getOmniFilter()).as(query).isFalse();
    }
    assertThat(parse("mechs").getOmniFilter()).isNull();
    // before or after the weight class
    UnitDecorator nonOmniAssault = parse("non-omni assault mechs with at least 2 ppc");
    assertThat(nonOmniAssault.getOmniFilter()).isFalse();
    assertThat(nonOmniAssault.getWeightClasses()).containsExactly(WeightClass.ASSAULT);
    assertThat(parse("assault omni mechs").getOmniFilter()).isTrue();
  }

  @Test
  void componentsBeforeEquipment() {
    ComponentFilter engine = component(parse("mechs with an xl engine"), 0);
    assertThat(engine.getComponent().kind()).isEqualTo(ComponentNames.Kind.ENGINE);
    assertThat(engine.getComponent().types()).containsExactly("XL");
    assertThat(engine.getTech()).isNull();
    assertThat(engine.getQuery()).isEqualTo("SELECT id FROM unit WHERE engine_type IN ('XL')");
    assertThat(component(parse("mechs with a clan xl engine"), 0).getQuery())
        .isEqualTo("SELECT id FROM unit WHERE engine_type IN ('XL') AND engine_tech = 'CLAN'");
    assertThat(component(parse("mechs with endo steel"), 0).getComponent().types())
        .containsExactly("ENDO_STEEL", "ENDO_STEEL_PROTOTYPE");
    assertThat(component(parse("mechs with 1 ferro-fibrous armor"), 0).getComponent().types())
        .containsExactly("FERRO_FIBROUS", "FERRO_FIBROUS_PROTOTYPE");
    assertThat(component(parse("mechs with a small cockpit"), 0).getComponent().types()).containsExactly("SMALL");
    assertThat(component(parse("mechs with an xl gyro"), 0).getComponent().kind()).isEqualTo(ComponentNames.Kind.GYRO);
    // the repository isn't asked about components
    assertThat(parse("mechs with an xl engine and 2 ppc").getFilters().get(1)).isInstanceOf(EquipmentDecorator.class);
  }

  @Test
  void aChunkCanLeaveOutItsNumberFirstOrAfterAndOr() {
    EquipmentDecorator ppcs = chunk(parse("mechs with ppcs"), 0);
    assertThat(ppcs.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(ppcs.getQuantity()).isEqualTo(1);
    UnitDecorator mixed = parse("mechs with 2 ppc and endo steel or ferro-fibrous armor");
    assertThat(mixed.getFilters()).hasSize(3);
    assertThat(mixed.getFilters().get(0).getLogicOperator()).isEqualTo(LogicalOperator.AND);
    assertThat(mixed.getFilters().get(1)).isInstanceOf(ComponentFilter.class);
    assertThat(mixed.getFilters().get(1).getLogicOperator()).isEqualTo(LogicalOperator.OR);
    // without "and" / "or" the next chunk needs its number, so this is still two chunks
    assertThat(names(parse("mechs with 2 ppc 3 srm6"))).containsExactly("ppc", "srm6");
  }

  @Test
  void aUnitHasOneOfEachComponent() {
    assertThatThrownBy(() -> parse("mechs with 2 xl engines")).isInstanceOf(FailedParseException.class)
        .hasMessage("A unit has one engine: xl engines");
    assertThatThrownBy(() -> parse("mechs with at most 1 xl engine")).hasMessage("A unit has one engine: xl engine");
    assertThatThrownBy(() -> parse("mechs with a clan small cockpit")).hasMessage("A cockpit has no tech: clan small cockpit");
    assertThat(parse("mechs with at least 1 xl engine").getFilters()).hasSize(1);
  }

  @Test
  void withoutMeansNone() {
    UnitDecorator unit = parse("mechs without an xl engine");
    assertThat(component(unit, 0).isNegated()).isTrue();
    assertThat(unit.getQuery()).contains("AND (id NOT IN (SELECT id FROM unit WHERE engine_type IN ('XL')))");
    EquipmentDecorator ppc = chunk(parse("mechs without ppcs"), 0);
    assertThat(ppc.isNegated()).isTrue();
    assertThat(ppc.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    assertThat(ppc.getQuantity()).isEqualTo(1);
    UnitDecorator mixed = parse("assault mechs with 2 lrm 20 and without any lasers");
    assertThat(mixed.getFilters()).hasSize(2);
    assertThat(mixed.getFilters().get(0).isNegated()).isFalse();
    assertThat(mixed.getFilters().get(1).isNegated()).isTrue();
    assertThat(mixed.getQuery()).contains(") AND id NOT IN (");
    assertThatThrownBy(() -> parse("mechs without 2 ppc"))
        .hasMessage("'without' means none at all: use 'with fewer than 2 ppc'");
  }

  @Test
  void otherWordsForWithout() {
    String ids = "'[0-9a-f-]{36}'";
    String without = parse("mechs without ppcs").getQuery().replaceAll(ids, "ID");
    for (String query : List.of("mechs with no ppcs", "mechs no ppcs", "mechs lacking ppcs", "mechs that don't have ppcs",
        "mechs that dont have ppcs", "mechs which do not have ppcs", "mechs that   do not have ppcs")) {
      assertThat(parse(query).getQuery().replaceAll(ids, "ID")).as(query).isEqualTo(without);
    }
    // "but" is "and", "but no" / "but not" are "and without"
    assertThat(parse("mechs with 2 ppc but no lasers").getQuery().replaceAll(ids, "ID"))
        .isEqualTo(parse("mechs with 2 ppc and without lasers").getQuery().replaceAll(ids, "ID"));
    assertThat(parse("mechs with 2 ppc but not lasers").getQuery().replaceAll(ids, "ID"))
        .isEqualTo(parse("mechs with 2 ppc and without lasers").getQuery().replaceAll(ids, "ID"));
    // "no more than" is still a comparator
    assertThat(chunk(parse("mechs with no more than 2 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL_OR_LESS);
  }

  @Test
  void withoutCarriesOverAList() {
    UnitDecorator neither = parse("mechs without ppcs or lasers");
    assertThat(neither.getFilters()).extracting(UnitFilter::isNegated).containsExactly(true, true);
    // neither: "or" becomes "and" between the two
    assertThat(neither.getFilters().get(0).getLogicOperator()).isEqualTo(LogicalOperator.AND);
    assertThat(parse("mechs without an xl engine or a light engine").getFilters())
        .extracting(UnitFilter::isNegated).containsExactly(true, true);
    EquipmentDecorator laser = chunk(parse("mechs without ppcs and a laser"), 1);
    assertThat(laser.isNegated()).isTrue();
    assertThat(laser.getComparison()).isEqualTo(Comparison.EQUAL_OR_GREATER);
    // a count of its own, an engine rating or "with" ends the list
    assertThat(parse("mechs without ppcs and 2 lrm 20").getFilters()).extracting(UnitFilter::isNegated)
        .containsExactly(true, false);
    assertThat(parse("mechs without ppcs or lasers but with 2 lrm 20").getFilters()).extracting(UnitFilter::isNegated)
        .containsExactly(true, true, false);
    assertThat(parse("mechs without ppcs and an engine rating of at least 300").getFilters())
        .extracting(UnitFilter::isNegated).containsExactly(true, false);
    // each "without" written out: either one
    UnitDecorator either = parse("mechs without ppcs or without lasers");
    assertThat(either.getFilters().get(0).getLogicOperator()).isEqualTo(LogicalOperator.OR);
    // after a "with" list, nothing is negated
    assertThat(parse("mechs with 2 ppc and lasers").getFilters()).extracting(UnitFilter::isNegated)
        .containsExactly(false, false);
  }

  @Test
  void unitsCanBeLeftOut() {
    UnitDecorator nonLam = parse("non-lam mechs");
    assertThat(nonLam.getDecoratedUnit()).isExactlyInstanceOf(Mech.class);
    assertThat(nonLam.getExclusions()).extracting(UnitDecorator::getLocomotion).containsExactly(Locomotion.LAM);
    assertThat(nonLam.getQuery()).contains("AND NOT COALESCE((dtype = 'Mech'  AND locomotion = 'LAM'), false)");
    for (String query : List.of("non lam mechs", "nonlam mechs", "mechs except lams", "mechs that aren't lams",
        "mechs that are not lams", "mechs but not lams", "mechs which aren't lams")) {
      assertThat(parse(query).getExclusions()).as(query).extracting(UnitDecorator::getLocomotion)
          .containsExactly(Locomotion.LAM);
    }
    assertThat(parse("mechs except lams, quads and tripods").getExclusions()).extracting(UnitDecorator::getLocomotion)
        .containsExactly(Locomotion.LAM, Locomotion.QUAD, Locomotion.TRIPOD);
    assertThat(parse("units that aren't vtols with 2 ppc").getExclusions()).extracting(UnitDecorator::getDecoratedUnit)
        .hasExactlyElementsOfTypes(Vtol.class);
    assertThat(parse("mechs that aren't omnis").getExclusions()).extracting(UnitDecorator::getOmniFilter)
        .containsExactly(true);
    assertThat(parse("heavy non-quad non-omni mechs with 2 ppc").getOmniFilter()).isFalse();
    // "mechs except ppcs" isn't a unit: it's "without ppcs"
    assertThat(parse("mechs except ppcs").getFilters()).extracting(UnitFilter::isNegated).containsExactly(true);
  }

  @Test
  void engineRating() {
    for (String query : List.of("mechs with an engine rating of at least 300", "mechs with engine rating at least 300",
        "mechs with engine rating 300 or more")) {
      EngineRatingFilter rating = (EngineRatingFilter) parse(query).getFilters().get(0);
      assertThat(rating.getComparison()).as(query).isEqualTo(Comparison.EQUAL_OR_GREATER);
      assertThat(rating.getRating()).as(query).isEqualTo(300);
    }
    assertThat(((EngineRatingFilter) parse("mechs with engine rating 300").getFilters().get(0)).getComparison())
        .isEqualTo(Comparison.EQUAL);
    assertThat(parse("mechs with engine rating at most 200 and 2 ppc").getQuery())
        .contains("id IN (SELECT id FROM unit WHERE engine_rating <= 200) AND id IN (");
    assertThatThrownBy(() -> parse("mechs with fuel rating 300")).hasMessage("Can only search engine rating: fuel rating");
  }

  private static ComponentFilter component(UnitDecorator unit, int index) {
    return (ComponentFilter) unit.getFilters().get(index);
  }
}
