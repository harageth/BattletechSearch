package com.battletech.search.antlr;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.model.FireControl;
import com.battletech.search.model.TurretMount;
import com.battletech.search.model.WeightClass;
import com.battletech.search.utils.EquipmentNames;
import java.util.List;
import java.util.Map;
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
      BattletechLexer.TRACKED, BattletechLexer.HOVERCRAFT, BattletechLexer.OMNIMECH, BattletechLexer.BIPED,
      BattletechLexer.QUAD, BattletechLexer.TRIPOD, BattletechLexer.LAM, BattletechLexer.QUADVEE);

  private static List<Integer> tokenTypes(String text) {
    BattletechLexer lexer = new BattletechLexer(CharStreams.fromString(text));
    return lexer.getAllTokens().stream().map(Token::getType).toList();
  }

  @Test
  void keywordsAreEachOneKeywordToken() {
    // autocorrect knows every spelling the grammar takes, so each must really be one keyword, not a word
    for (String keyword : QueryVocabulary.keywords()) {
      assertThat(tokenTypes(keyword)).as(keyword).hasSize(1).noneMatch(type -> type == BattletechLexer.WORD);
    }
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
      List<Integer> types = tokenTypes(unit.singular());
      // "support vehicle": support or combat in front of a vehicle word
      if (types.size() == 2) {
        assertThat(types.get(0)).as(unit.singular()).isIn(BattletechLexer.SUPPORT, BattletechLexer.COMBAT);
        types = types.subList(1, 2);
      }
      assertThat(types).as(unit.singular()).hasSize(1).allMatch(UNITS::contains);
      assertThat(tokenTypes(unit.plural())).as(unit.plural()).isEqualTo(tokenTypes(unit.singular()));
    }
    assertThat(QueryVocabulary.units()).extracting(QueryVocabulary.UnitWord::plural).contains("support vehicles", "combat tanks");
  }

  @Test
  void wordsForWithAreOneStopword() {
    assertThat(QueryVocabulary.withWords()).contains("with", "having", "that have", "which have", "carrying", "armed with");
    for (String with : QueryVocabulary.withWords()) {
      assertThat(tokenTypes(with)).as(with).containsExactly(BattletechLexer.STOPWORD);
      assertThat(tokenTypes(with.toUpperCase())).as(with).containsExactly(BattletechLexer.STOPWORD);
    }
  }

  @Test
  void multiWordPhrasesTakeAnySpacing() {
    List<String> phrases = new java.util.ArrayList<>(QueryVocabulary.comparatorsBefore());
    phrases.addAll(QueryVocabulary.comparatorsAfter());
    phrases.addAll(QueryVocabulary.withWords());
    for (String phrase : phrases) {
      assertThat(tokenTypes(phrase.replace(" ", "    "))).as(phrase).isEqualTo(tokenTypes(phrase));
      assertThat(tokenTypes(phrase.replace(" ", " \t "))).as(phrase).isEqualTo(tokenTypes(phrase));
    }
    // a line break still ends the line
    assertThat(tokenTypes("at\nleast")).hasSize(3);
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
    assertThat(QueryVocabulary.turretMounts()).containsExactly("turret", "sponson", "pintle");
    for (String mount : QueryVocabulary.turretMounts()) {
      TurretMount.Filter filter = TurretMount.fromSearch(EquipmentNames.normalize(mount + " lrm 20"));
      assertThat(filter).as(mount).isNotNull();
      assertThat(filter.rest()).isEqualTo("lrm20");
      // a plain word, so it parses in front of a weapon name
      assertThat(QueryVocabulary.isTypeable(mount + " lrm 20")).as(mount).isTrue();
    }
  }

  @Test
  void typeableNamesAreOneEquipmentName() {
    assertThat(QueryVocabulary.isTypeable("lrm 20")).isTrue();
    assertThat(QueryVocabulary.isTypeable("streak srm 6")).isTrue();
    assertThat(QueryVocabulary.isTypeable("ac/20")).isTrue();
    assertThat(QueryVocabulary.isTypeable("lb 10-x ac")).isTrue();
    // a bracketed part, an apostrophe and "triple strength" are words of a name (2026-11-01)
    assertThat(QueryVocabulary.isTypeable("flamer (vehicle)")).isTrue();
    assertThat(QueryVocabulary.isTypeable("'mech mortar 1")).isTrue();
    assertThat(QueryVocabulary.isTypeable("industrial triple strength myomer")).isTrue();
    // but a bracket can't hold a comma (user, 2026-11-14): commas separate lists
    assertThat(QueryVocabulary.isTypeable("rifle (cannon, heavy)")).isFalse();
    // a number before "ammo" stays in the name (user, 2026-11-17); before another word it ends it
    assertThat(QueryVocabulary.isTypeable("lrm 20 ammo")).isTrue();
    assertThat(QueryVocabulary.isTypeable("mml 7 lrm ammo")).isFalse();
    assertThat(QueryVocabulary.isTypeable("")).isFalse();
  }

  @Test
  void equipmentThatCantBeTypedIsOfferedAsASpellingThatCan() {
    assertThat(QueryVocabulary.typedName("lrm 20")).isEqualTo("lrm 20");
    // user decision: binary lasers are just "blazers"
    assertThat(QueryVocabulary.typedName("binary laser (blazer) cannon")).isEqualTo("blazer");
    // a bracketed part can be typed (2026-11-01)
    assertThat(QueryVocabulary.typedName("flamer (vehicle)")).isEqualTo("flamer (vehicle)");
    // each spelling finds the equipment it stands for
    for (String name : List.of("binary laser (blazer) cannon", "flamer (vehicle)")) {
      assertThat(EquipmentNames.canonical(QueryVocabulary.typedName(name))).as(name)
          .isEqualTo(EquipmentNames.normalize(name));
    }
    // a number in the middle can before "ammo" (user, 2026-11-17), but not before another word
    assertThat(QueryVocabulary.typedName("lrm 20 ammo")).isEqualTo("lrm 20 ammo");
    assertThat(QueryVocabulary.typedName("mml 7 lrm ammo")).isNull();
  }

  @Test
  void theGuideShowsEveryTermSoASearchCanTakeIt() {
    // MegaMek's other names that can't be typed as written; the guide lists them respelled (2026-11-14)
    Map<String, String> respelled = Map.of(
        "Rifle (Cannon, Heavy)", "Rifle (Cannon Heavy)",
        "MML 7 LRM Ammo", "MML7 LRM Ammo",
        "CommsGear:5", "CommsGear 5",
        "C3 Master Boosted System with TAG", "C3 Master Boosted System with-TAG");
    respelled.forEach((term, shown) -> {
      assertThat(QueryVocabulary.typeableSpelling(term)).isEqualTo(shown);
      assertThat(QueryVocabulary.isTypeable(EquipmentNames.typed(shown))).as(shown).isTrue();
      // only spacing and punctuation change, so it's the same slang term
      assertThat(EquipmentNames.slangKey(shown)).isEqualTo(EquipmentNames.slangKey(term));
    });
    assertThat(QueryVocabulary.typeableSpelling("Flamer (Vehicle)")).isEqualTo("Flamer (Vehicle)");
    // a number before "ammo" is typed as it is (user, 2026-11-17)
    assertThat(QueryVocabulary.typeableSpelling("ELRM 10 Ammo")).isEqualTo("ELRM 10 Ammo");
  }
}
