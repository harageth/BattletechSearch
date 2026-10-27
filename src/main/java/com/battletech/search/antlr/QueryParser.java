package com.battletech.search.antlr;

import com.battletech.search.entities.Unit;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import me.BattletechLexer;
import me.BattletechParser;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

/**
 * Turns a search query into a Unit describing what to search for.
 * Any lexer or parser error fails the whole query instead of letting ANTLR guess a recovery.
 */
public class QueryParser {

  public static Unit parse(String query, EquipmentSlangRepository slangRepo, EquipmentRepository equipRepo) {
    BattletechLexer lexer = new BattletechLexer(CharStreams.fromString(query));
    lexer.removeErrorListeners();
    lexer.addErrorListener(ThrowingErrorListener.INSTANCE);

    BattletechParser parser = new BattletechParser(new CommonTokenStream(lexer));
    parser.removeErrorListeners();
    parser.addErrorListener(ThrowingErrorListener.INSTANCE);

    TestVisitor visitor = new TestVisitor(lexer.getVocabulary(), slangRepo, equipRepo);
    return (Unit) visitor.visitQuery(parser.query());
  }

  static class ThrowingErrorListener extends BaseErrorListener {
    static final ThrowingErrorListener INSTANCE = new ThrowingErrorListener();

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line,
        int charPositionInLine, String msg, RecognitionException e) {
      throw new FailedParseException("Unable to parse query at position " + charPositionInLine + ": " + msg);
    }
  }
}
