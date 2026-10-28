package com.battletech.search.antlr;

import com.battletech.search.model.FireControl;
import com.battletech.search.model.Tech;
import com.battletech.search.model.WeightClass;
import com.battletech.search.utils.EquipmentNames;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import me.BattletechLexer;
import me.BattletechParser;
import me.BattletechParser.LineContext;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.tree.ParseTree;

/**
 * The words a query can use, spelled the way people type them, for the search box to offer in place
 * of each other. Comparators and unit words come from the grammar's tokens (QueryVocabularyTest
 * checks each one still lexes); weight classes, tech and fire control words come from where the
 * search reads them.
 */
public final class QueryVocabulary {
  /** One unit word in both numbers; some are the same. */
  public record UnitWord(String singular, String plural) {
  }

  static final List<UnitWord> UNITS = List.of(
      new UnitWord("unit", "units"),
      new UnitWord("mech", "mechs"),
      new UnitWord("vehicle", "vehicles"),
      new UnitWord("tank", "tanks"),
      new UnitWord("wheeled", "wheeled"),
      new UnitWord("tracked", "tracked"),
      new UnitWord("hovercraft", "hovercraft"),
      new UnitWord("vtol", "vtols"));
  // before the quantity ("at least 2") and after it ("2 or more"); the grammar takes either anywhere,
  // but swapping one for the other only reads right within a group
  static final List<String> COMPARATORS_BEFORE = List.of(
      "at least", "at most", "exactly", "no more than", "greater than", "fewer than", "less than");
  static final List<String> COMPARATORS_AFTER = List.of("or more", "or fewer", "or less");
  static final List<String> OPERATORS = List.of("and", "or");

  private QueryVocabulary() {
  }

  public static List<String> weightClasses() {
    return Arrays.stream(WeightClass.values()).map(weightClass -> weightClass.getText().toLowerCase()).toList();
  }

  public static List<UnitWord> units() {
    return UNITS;
  }

  public static List<String> comparatorsBefore() {
    return COMPARATORS_BEFORE;
  }

  public static List<String> comparatorsAfter() {
    return COMPARATORS_AFTER;
  }

  public static List<String> operators() {
    return OPERATORS;
  }

  public static Map<String, Tech> techs() {
    return EquipmentNames.techWords();
  }

  public static List<String> fireControls() {
    return FireControl.searchWords();
  }

  /**
   * Whether a query can name this equipment as typed, as one equipment name: "lrm 20" can, "flamer
   * (vehicle)" can't (no parentheses), and neither can a name the grammar splits into two chunks.
   */
  public static boolean isTypeable(String name) {
    BattletechLexer lexer = new BattletechLexer(CharStreams.fromString("units with 1 " + name));
    BattletechParser parser = new BattletechParser(new CommonTokenStream(lexer));
    ErrorCounter errors = new ErrorCounter();
    lexer.removeErrorListeners();
    lexer.addErrorListener(errors);
    parser.removeErrorListeners();
    parser.addErrorListener(errors);
    LineContext line = parser.query().line();
    if (errors.count > 0 || line.equipmentChunk().size() != 1) {
      return false;
    }
    String parsed = line.equipmentChunk(0).equipmentName().children.stream()
        .map(ParseTree::getText).collect(Collectors.joining(" "));
    return parsed.equals(name);
  }

  private static class ErrorCounter extends BaseErrorListener {
    int count;

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line,
        int charPositionInLine, String msg, RecognitionException e) {
      count++;
    }
  }
}
