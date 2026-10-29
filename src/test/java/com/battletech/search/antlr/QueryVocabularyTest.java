package com.battletech.search.antlr;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.model.FireControl;
import com.battletech.search.model.WeightClass;
import com.battletech.search.utils.EquipmentNames;
import java.util.List;
import java.util.Set;
import me.BattletechLexer;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.Token;
import org.junit.jupiter.api.Test;

/** The search box offers these words in place of each other, so each must still mean what it did. */
class QueryVocabularyTest {
  private static final Set<Integer> COMPARATORS = Set.of(BattletechLexer.ATLEAST, BattletechLexer.NOMORE,
      BattletechLexer.EQUAL, BattletechLexer.LESSTHANCOMPARATOR, BattletechLexer.GREATERTHANCOMPARATOR);
  private static final Set<Integer> UNITS = Set.of(BattletechLexer.GENERICUNIT, BattletechLexer.MECH,
      BattletechLexer.VEHICLE, BattletechLexer.VTOL, BattletechLexer.TANK, BattletechLexer.WHEELED,
      BattletechLexer.TRACKED, BattletechLexer.HOVERCRAFT);

  private static List<Integer> tokenTypes(String text) {
    BattletechLexer lexer = new BattletechLexer(CharStreams.fromString(text));
    return lexer.getAllTokens().stream().map(Token::getType).toList();
  }

  @Test
  void comparatorsAreOneComparatorToken() {
    for (String comparator : QueryVocabulary.comparatorsBefore()) {
      assertThat(tokenTypes(comparator)).as(comparator).hasSize(1).allMatch(COMPARATORS::contains);
    }
    for (String comparator : QueryVocabulary.comparatorsAfter()) {
      assertThat(tokenTypes(comparator)).as(comparator).hasSize(1).allMatch(COMPARATORS::contains);
    }
  }

  @Test
  void unitWordsAreOneUnitTokenInBothNumbers() {
    for (QueryVocabulary.UnitWord unit : QueryVocabulary.units()) {
      assertThat(tokenTypes(unit.singular())).as(unit.singular()).hasSize(1).allMatch(UNITS::contains);
      assertThat(tokenTypes(unit.plural())).as(unit.plural()).isEqualTo(tokenTypes(unit.singular()));
    }
  }

  @Test
  void operators() {
    assertThat(QueryVocabulary.operators().stream().map(QueryVocabularyTest::tokenTypes))
        .containsExactly(List.of(BattletechLexer.AND), List.of(BattletechLexer.OR));
  }

  @Test
  void weightClassesAreWordsTheSearchKnows() {
    assertThat(QueryVocabulary.weightClasses()).contains("ultra light", "assault");
    for (String weightClass : QueryVocabulary.weightClasses()) {
      assertThat(tokenTypes(weightClass)).as(weightClass).allMatch(type -> type == BattletechLexer.WORD);
      assertThat(WeightClass.fromString(weightClass)).isNotNull();
    }
  }

  @Test
  void techAndFireControlWordsAreTheOnesTheSearchReads() {
    QueryVocabulary.techs().forEach((word, tech) ->
        assertThat(EquipmentNames.splitTechWord(word + " ppc").tech()).as(word).isEqualTo(tech));
    assertThat(QueryVocabulary.fireControls()).containsExactly("artemis iv", "artemis v", "artemis", "apollo");
    for (String fireControl : QueryVocabulary.fireControls()) {
      FireControl.Filter filter = FireControl.fromSearch(EquipmentNames.normalize(fireControl + " lrm 20"));
      assertThat(filter).as(fireControl).isNotNull();
      assertThat(filter.launcher()).isEqualTo("lrm20");
    }
  }

  @Test
  void typeableNamesAreOneEquipmentName() {
    assertThat(QueryVocabulary.isTypeable("lrm 20")).isTrue();
    assertThat(QueryVocabulary.isTypeable("streak srm 6")).isTrue();
    assertThat(QueryVocabulary.isTypeable("ac/20")).isTrue();
    assertThat(QueryVocabulary.isTypeable("lb 10-x ac")).isTrue();
    // no parentheses in a query
    assertThat(QueryVocabulary.isTypeable("flamer (vehicle)")).isFalse();
    // the number ends the name, so "ammo" would start another chunk
    assertThat(QueryVocabulary.isTypeable("lrm 20 ammo")).isFalse();
    assertThat(QueryVocabulary.isTypeable("")).isFalse();
  }

  @Test
  void equipmentThatCantBeTypedIsOfferedAsASpellingThatCan() {
    assertThat(QueryVocabulary.typedName("lrm 20")).isEqualTo("lrm 20");
    // user decision: binary lasers are just "blazers"
    assertThat(QueryVocabulary.typedName("binary laser (blazer) cannon")).isEqualTo("blazer");
    assertThat(QueryVocabulary.typedName("flamer (vehicle)")).isEqualTo("vehicleflamer");
    // each spelling finds the equipment it stands for
    for (String name : List.of("binary laser (blazer) cannon", "flamer (vehicle)")) {
      assertThat(EquipmentNames.canonical(QueryVocabulary.typedName(name))).as(name)
          .isEqualTo(EquipmentNames.normalize(name));
    }
    assertThat(QueryVocabulary.typedName("some (thing)")).isNull();
  }
}
