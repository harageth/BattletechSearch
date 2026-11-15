package com.battletech.search.antlr;

import com.battletech.search.model.FireControl;
import com.battletech.search.model.Tech;
import com.battletech.search.model.WeightClass;
import com.battletech.search.utils.ComponentNames;
import com.battletech.search.utils.EquipmentNames;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
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
      new UnitWord("vtol", "vtols"),
      new UnitWord("omnimech", "omnimechs"),
      new UnitWord("biped", "bipeds"),
      new UnitWord("quad", "quads"),
      new UnitWord("tripod", "tripods"),
      new UnitWord("lam", "lams"),
      new UnitWord("quadvee", "quadvees"));
  // in front of the unit word: "omni mechs", "non-omni vehicles"
  static final List<String> OMNI_WORDS = List.of("omni", "non-omni");
  // before the quantity ("at least 2") and after it ("2 or more"); the grammar takes either anywhere,
  // but swapping one for the other only reads right within a group
  static final List<String> COMPARATORS_BEFORE = List.of(
      "at least", "at most", "exactly", "no more than", "greater than", "fewer than", "less than");
  static final List<String> COMPARATORS_AFTER = List.of("or more", "or fewer", "or less");
  static final List<String> OPERATORS = List.of("and", "or");
  // between the unit and the weapons; all the same STOPWORD token
  static final List<String> WITH_WORDS = List.of("with", "having", "that have", "which have", "carrying", "armed with");

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

  public static List<String> withWords() {
    return WITH_WORDS;
  }

  public static Map<String, Tech> techs() {
    return EquipmentNames.techWords();
  }

  public static List<String> fireControls() {
    return FireControl.searchWords();
  }

  public static List<String> omniWords() {
    return OMNI_WORDS;
  }

  /** Each kind's components as typed ("engine" -> "xl engine", "light engine", ...). */
  public static Map<String, List<String>> components() {
    Map<String, List<String>> components = new LinkedHashMap<>();
    ComponentNames.names().forEach((kind, names) -> components.put(kind.getWord(), names));
    return components;
  }

  // what to offer instead of a name as MegaMek writes it; each must find that equipment
  private static final Map<String, String> TYPED_INSTEAD = Map.of(
      // user decision (2026-10-29): binary lasers are just "blazers" (a hand-written term, db/data/V3_21)
      "binary laser (blazer) cannon", "blazer");

  /**
   * How a query names this equipment (a weapon as typed, "lrm 20"): the spelling people use for it if
   * there is one, else the name itself if it can be typed, else null.
   */
  public static String typedName(String name) {
    String instead = TYPED_INSTEAD.get(name);
    if (instead != null && isTypeable(instead)) {
      return instead;
    }
    return isTypeable(name) ? name : null;
  }

  // "Rifle (Cannon, Heavy)": a comma can't go in a bracket
  private static final Pattern COMMA = Pattern.compile(",\\s*");
  // "CommsGear:5": a size after a colon
  private static final Pattern SIZE = Pattern.compile(":(\\d+)$");
  // "ELRM 10 Ammo": a number with a word after it would start the next chunk
  private static final Pattern MIDDLE_NUMBER = Pattern.compile("(?<=\\S) (\\d+)(?= \\S)");
  private static final Pattern PLAIN_WORD = Pattern.compile("[A-Za-z]+");

  /**
   * A term (MegaMek's "Rifle (Cannon, Heavy)", "ELRM 10 Ammo", "CommsGear:5", "C3 Master Boosted System
   * with TAG") spelled so a query can take it as written: "Rifle (Cannon Heavy)", "ELRM10 Ammo",
   * "CommsGear 5", "C3 Master Boosted System with-TAG" (a word the query reads as a keyword joins the
   * next). Only spacing and punctuation change, which a search ignores, so it still finds the same slang
   * term. A term that can be typed already is returned as it is.
   */
  public static String typeableSpelling(String term) {
    if (isTypeable(EquipmentNames.typed(term))) {
      return term;
    }
    String spelled = SIZE.matcher(COMMA.matcher(term).replaceAll(" ")).replaceAll(" $1");
    String[] words = MIDDLE_NUMBER.matcher(spelled).replaceAll("$1").split(" ");
    StringBuilder joined = new StringBuilder(words[0]);
    for (int i = 1; i < words.length; i++) {
      String before = words[i - 1];
      boolean keyword = PLAIN_WORD.matcher(before).matches() && !isTypeable(before.toLowerCase());
      joined.append(keyword ? "-" : " ").append(words[i]);
    }
    return joined.toString();
  }

  /**
   * Whether a query can name this equipment as typed, as one equipment name: "lrm 20" and "flamer
   * (vehicle)" can, "rifle (cannon, heavy)" can't (a comma in a bracket), and neither can a name the
   * grammar splits into two chunks.
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
    if (errors.count > 0 || line.chunks() == null || !line.chunks().more().isEmpty()
        || line.chunks().lead().chunk() == null || line.chunks().lead().chunk().equipmentChunk() == null) {
      return false;
    }
    String parsed = line.chunks().lead().chunk().equipmentChunk().equipmentName().children.stream()
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
