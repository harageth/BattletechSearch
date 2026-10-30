package com.battletech.search.antlr;

import com.battletech.search.entities.Unit;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import me.BattletechLexer;
import me.BattletechParser;
import me.BattletechParser.WeightClassContext;
import me.BattletechParser.WeightClassesContext;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.misc.IntervalSet;

/**
 * Turns a search query into a Unit describing what to search for.
 * Any lexer or parser error fails the whole query instead of letting ANTLR guess a recovery.
 */
public class QueryParser {
  static final String EXAMPLE = "Try something like 'mechs with at least 2 ppc'.";

  public static Unit parse(String query, EquipmentSlangRepository slangRepo, EquipmentRepository equipRepo) {
    BattletechLexer lexer = new BattletechLexer(CharStreams.fromString(query));
    lexer.removeErrorListeners();
    lexer.addErrorListener(ThrowingErrorListener.INSTANCE);

    BattletechParser parser = new BattletechParser(new CommonTokenStream(lexer));
    parser.removeErrorListeners();
    parser.addErrorListener(ThrowingErrorListener.INSTANCE);

    QueryVisitor visitor = new QueryVisitor(lexer.getVocabulary(), slangRepo, equipRepo);
    return (Unit) visitor.visitQuery(parser.query());
  }

  /** Throws on the first error, translating ANTLR's message into something a user can act on. */
  static class ThrowingErrorListener extends BaseErrorListener {
    static final ThrowingErrorListener INSTANCE = new ThrowingErrorListener();
    static final String EQUIPMENT = "an equipment name";
    static final String WEIGHT_CLASS = "a weight class like 'heavy'";

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line,
        int charPositionInLine, String msg, RecognitionException e) {
      int column = charPositionInLine + 1;
      if (!(recognizer instanceof Parser parser) || !(offendingSymbol instanceof Token token)) {
        // lexer errors look like "token recognition error at: '''"
        String character = msg.substring(msg.indexOf("at: ") + 4);
        throw new FailedParseException("Unable to parse query: can't use " + character
            + " (character " + column + "). Use letters, numbers, '-' and '/'.");
      }

      TokenStream tokens = parser.getTokenStream();
      int index = token.getTokenIndex();
      Token previous = index > 0 ? tokens.get(index - 1) : null;
      // After "2" or "2 or fewer" only an equipment name fits, but when ANTLR fails while choosing
      // between the equipmentChunk alternatives its expected set still includes a quantity.
      String expected = followsQuantity(tokens, index) ? EQUIPMENT
          : followsWeightClassOperator(parser, previous) ? WEIGHT_CLASS
          : describe(parser.getExpectedTokens());
      if (token.getType() == Token.EOF) {
        if (previous == null) {
          throw new FailedParseException("Unable to parse query: the query is empty. " + EXAMPLE);
        }
        throw new FailedParseException("Unable to parse query: expected " + expected
            + " after '" + previous.getText() + "'. " + EXAMPLE);
      }
      if (expected == null) {
        throw new FailedParseException("Unable to parse query: didn't expect '" + token.getText()
            + "' (character " + column + "). " + EXAMPLE);
      }
      throw new FailedParseException("Unable to parse query: expected " + expected + " before '"
          + token.getText() + "' (character " + column + "). " + EXAMPLE);
    }

    /** The thing the user left out, or null if the query should have ended. */
    private static String describe(IntervalSet expected) {
      if (expected.contains(BattletechParser.QUANTITY)) {
        return "a quantity like '2' or 'at least 2'";
      }
      if (expected.contains(BattletechParser.STOPWORD)) {
        return "'with'";
      }
      if (expected.contains(BattletechParser.WORD)) {
        return EQUIPMENT;
      }
      return null;
    }

    /** Whether the tokens before index are a quantity, optionally followed by a comparator. */
    private static boolean followsQuantity(TokenStream tokens, int index) {
      int previous = index - 1;
      if (previous >= 0 && isComparator(tokens.get(previous).getType())) {
        previous--;
      }
      return previous >= 0 && tokens.get(previous).getType() == BattletechParser.QUANTITY;
    }

    /** Whether this is right after the "or" or "," in "light, medium or heavy", where only a weight class fits. */
    private static boolean followsWeightClassOperator(Parser parser, Token previous) {
      ParserRuleContext context = parser.getContext();
      return previous != null
          && (previous.getType() == BattletechParser.OR || previous.getType() == BattletechParser.AND
              || previous.getType() == BattletechParser.COMMA)
          && (context instanceof WeightClassesContext || context instanceof WeightClassContext);
    }

    private static boolean isComparator(int type) {
      return type == BattletechParser.ATLEAST || type == BattletechParser.NOMORE
          || type == BattletechParser.EQUAL || type == BattletechParser.LESSTHANCOMPARATOR
          || type == BattletechParser.GREATERTHANCOMPARATOR;
    }
  }
}
