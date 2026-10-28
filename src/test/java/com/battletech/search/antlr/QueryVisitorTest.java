package com.battletech.search.antlr;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.EquipmentDecorator;
import com.battletech.search.model.Tech;
import com.battletech.search.model.UnitDecorator;
import com.battletech.search.model.WeightClass;
import com.battletech.search.model.search.Comparison;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.model.search.LogicalOperator;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
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
    // Every non-empty equipment name resolves to a single matching row by default, like the real data
    when(equipRepo.findAllBySlangOrEquipmentName(anyString())).thenAnswer(invocation -> {
      String name = invocation.getArgument(0);
      return name.isEmpty() ? List.of() : List.of(equipment(name, Tech.INNER_SPHERE));
    });
  }

  private static Equipment equipment(String name, Tech tech) {
    Equipment equipment = new Equipment(name, tech);
    equipment.setId(UUID.randomUUID());
    return equipment;
  }

  private UnitDecorator parse(String query) {
    return (UnitDecorator) QueryParser.parse(query, mock(EquipmentSlangRepository.class), equipRepo);
  }

  private static EquipmentDecorator chunk(Unit unit, int index) {
    return (EquipmentDecorator) unit.getMechEquipment().get(index);
  }

  @Test
  void fullQuery() {
    UnitDecorator unit = parse("light units with at most 2 mediumlaser and at least 1 srm6");

    assertThat(unit.getDecoratedUnit().getClass()).isEqualTo(Unit.class);
    assertThat(unit.getDecoratedUnit().getWeightClass()).isEqualTo(WeightClass.LIGHT);
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

  @Test
  void tanksAreAllGroundVehicles() {
    assertThat(parse("tanks with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Tank.class);
    assertThat(parse("Tank with at least 1 ppc").getDecoratedUnit()).isExactlyInstanceOf(Tank.class);
  }

  // Motive type isn't stored for vehicles yet, so searching by it is rejected rather than guessed
  @Test
  void motiveTypesAreNotSupportedYet() {
    assertThatThrownBy(() -> parse("tracked with at least 1 ppc"))
        .isInstanceOf(FailedParseException.class)
        .hasMessage("Searching by motive type (tracked) isn't supported yet");
    assertThatThrownBy(() -> parse("wheeled with at least 1 ppc"))
        .hasMessage("Searching by motive type (wheeled) isn't supported yet");
    assertThatThrownBy(() -> parse("hovertanks with at least 1 ppc"))
        .hasMessage("Searching by motive type (hovercraft) isn't supported yet");
  }

  @Test
  void weightClasses() {
    assertThat(parse("assault mechs with at least 1 ppc").getDecoratedUnit().getWeightClass())
        .isEqualTo(WeightClass.ASSAULT);
    assertThat(parse("ultra light mechs with at least 1 ppc").getDecoratedUnit().getWeightClass())
        .isEqualTo(WeightClass.ULTRA_LIGHT);
    assertThat(parse("mechs with at least 1 ppc").getDecoratedUnit().getWeightClass()).isNull();
  }

  @Test
  void comparators() {
    assertThat(chunk(parse("mechs with exactly 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL);
    assertThat(chunk(parse("mechs with = 3 ppc"), 0).getComparison()).isEqualTo(Comparison.EQUAL);
    assertThat(chunk(parse("mechs with greater than 3 ppc"), 0).getComparison()).isEqualTo(Comparison.GREATER_THAN);
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
  void multiWordEquipmentIsJoinedAndLowercased() {
    assertThat(chunk(parse("mechs with at least 1 Medium Laser"), 0).getEquipment().getName())
        .isEqualTo("medium laser");
  }

  @Test
  void equipmentMatchingSeveralRowsIsChained() {
    Equipment isPpc = equipment("ppc", Tech.INNER_SPHERE);
    Equipment clanPpc = equipment("ppc", Tech.CLAN);
    when(equipRepo.findAllBySlangOrEquipmentName("ppc")).thenReturn(List.of(isPpc, clanPpc));

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
    when(equipRepo.findAllBySlangOrEquipmentName("nonexistentgun")).thenReturn(List.of());
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
