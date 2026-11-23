package com.battletech.search.autocorrect;

import com.battletech.search.antlr.QueryParser;
import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.model.WeightClass;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.utils.EquipmentNames;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.Value;
import org.springframework.stereotype.Service;

/**
 * Completes the word being typed in the search box (user, 2026-11-22): the last words in front of the caret are
 * matched as the start of a whole phrase (SearchWords), so "2 medium la" gives "medium laser". As in Autocorrect,
 * the parser decides what fits: a phrase is offered if the query with it parses, or would with an ending added.
 * Nothing is searched.
 */
@Service
public class Autocomplete {
  private static final int MAX_OPTIONS = 8;
  private static final int MAX_TRIES = 40;
  // the longest name's words, and the shortest start of a word, that are matched
  private static final int MAX_WORDS = 6;
  private static final int MIN_LETTERS = 2;
  private static final int MAX_QUERY = 500;
  // what can finish a query after a word of the grammar: "clan" (units), "at least" (1 laser), "artemis" (lrms),
  // "rating of" (300)
  private static final List<String> ENDINGS = List.of("", " units", " lasers", " 1 laser", " with lasers", " lrms", " 300");
  private static final Set<String> VEHICLE_WORDS = Set.of("support", "combat");
  private static final Pattern WORD = Pattern.compile("\\S+");

  private final EquipmentRepository equipRepo;
  private final SearchWordsLoader loader;

  public Autocomplete(EquipmentRepository equipRepo, SearchWordsLoader loader) {
    this.equipRepo = equipRepo;
    this.loader = loader;
  }

  public Completions complete(String query, int caretAt) {
    if (query == null || query.length() > MAX_QUERY) {
      return new Completions(0, List.of(), false);
    }
    int caret = Math.max(0, Math.min(caretAt, query.length()));
    boolean complete = !query.isBlank() && parses(query);
    String before = query.substring(0, caret);
    String after = query.substring(caret);
    // in the middle of a word there's nothing to add
    boolean insideWord = !after.isEmpty() && !Character.isWhitespace(after.charAt(0));
    boolean afterSpace = !before.isEmpty() && Character.isWhitespace(before.charAt(before.length() - 1));
    // after a space only longer names go on: "2 lrm " (a whole search already) lists the LRM 20 (user, 2026-11-22)
    if (before.isBlank() || insideWord) {
      return new Completions(caret, List.of(), complete);
    }
    return new Completions(caret, options(before, after, afterSpace), complete);
  }

  // Words of the grammar from every start ("heavy me": mechs), names only from the longest text that begins any
  // ("medium la": medium laser, not the lasers too); in the order of their kinds, then alphabetically
  private List<Completions.Option> options(String before, String after, boolean afterSpace) {
    List<Found> found = new ArrayList<>();
    boolean named = false;
    int tries = 0;
    for (int start : wordStarts(before)) {
      String typed = before.substring(start);
      if (!longEnough(typed, afterSpace)) {
        continue;
      }
      boolean namedHere = false;
      for (SearchWords.Phrase phrase : matching(typed, afterSpace)) {
        boolean name = phrase.getKind() == SearchWords.Kind.GROUP || phrase.getKind() == SearchWords.Kind.EQUIPMENT;
        if (tries == MAX_TRIES || (name && named) || found.stream().filter(one -> one.getStart() == start).count() == MAX_OPTIONS) {
          continue;
        }
        tries++;
        if (fits(before.substring(0, start), phrase, after)) {
          found.add(new Found(start, phrase));
          namedHere |= name;
        }
      }
      named |= namedHere;
    }
    return found.stream()
        // as SearchWords.phrases orders them: numbers by value, "lrm 5" before "lrm 10"
        .sorted(Comparator.comparing((Found one) -> one.getPhrase().getKind())
            .thenComparing(one -> one.getPhrase().getText(), SearchWords::compareNaturally))
        .limit(MAX_OPTIONS)
        .map(one -> new Completions.Option(one.getStart(), one.getPhrase().getText()))
        .toList();
  }

  /** A phrase that fits, and where the text it replaces starts. */
  @Value
  private static class Found {
    int start;
    SearchWords.Phrase phrase;
  }

  // where each of the last words starts, the earliest first, so the longest text is matched first
  private static List<Integer> wordStarts(String before) {
    List<Integer> starts = new ArrayList<>();
    Matcher word = WORD.matcher(before);
    while (word.find()) {
      starts.add(word.start());
    }
    return starts.subList(Math.max(0, starts.size() - MAX_WORDS), starts.size());
  }

  // a word is matched from its second letter; a number ending a name ("lrm 1") and a space inside one ("medium ")
  // count as they are
  private static boolean longEnough(String typed, boolean afterSpace) {
    String[] words = typed.strip().split("\\s+");
    String last = EquipmentNames.slangKey(words[words.length - 1]);
    boolean number = words.length > 1 && !last.isEmpty() && last.chars().allMatch(Character::isDigit);
    return afterSpace || number || last.length() >= MIN_LETTERS;
  }

  private List<SearchWords.Phrase> matching(String typed, boolean afterSpace) {
    String key = EquipmentNames.slangKey(typed);
    if (key.length() < MIN_LETTERS || key.chars().allMatch(Character::isDigit)) {
      return List.of();
    }
    // after a space the phrase has to go on with another word: "medium " isn't "mediumlaser"
    String spaced = afterSpace ? typed.strip().toLowerCase(Locale.ROOT).replaceAll("\\s+", " ") + " " : "";
    return loader.words().phrases().stream()
        .filter(phrase -> phrase.getKey().startsWith(key) && !phrase.getKey().equals(key))
        .filter(phrase -> phrase.getText().startsWith(spaced))
        .toList();
  }

  // with more of the query after the caret the whole of it has to parse; at the end an equipment name does too,
  // and a word of the grammar only has to be one that a query can go on from
  private boolean fits(String text, SearchWords.Phrase phrase, String after) {
    String word = phrase.getText();
    // the grammar takes "with armed with lasers", but nobody means it
    if (QueryVocabulary.withWords().contains(word) && endsWithWithWord(text)) {
      return false;
    }
    if (!after.isBlank()) {
      return parses(text + word + after);
    }
    return endings(phrase).stream().anyMatch(ending -> parses(text + word + ending));
  }

  // a weight class goes before a unit: "2 medium" + " lasers" would parse, but as the medium laser's name
  private static List<String> endings(SearchWords.Phrase phrase) {
    if (phrase.getKind() == SearchWords.Kind.GROUP || phrase.getKind() == SearchWords.Kind.EQUIPMENT) {
      return List.of("");
    }
    if (WeightClass.fromString(phrase.getText()) != null) {
      return List.of(" units");
    }
    return VEHICLE_WORDS.contains(phrase.getText()) ? List.of(" vehicles") : ENDINGS;
  }

  private static boolean endsWithWithWord(String text) {
    String typed = " " + text.strip().toLowerCase(Locale.ROOT).replaceAll("\\s+", " ");
    return QueryVocabulary.withWords().stream().anyMatch(word -> typed.endsWith(" " + word));
  }

  private boolean parses(String query) {
    try {
      QueryParser.parse(query, equipRepo);
      return true;
    } catch (FailedParseException e) {
      return false;
    }
  }
}
