package com.battletech.search.autocorrect;

import com.battletech.search.antlr.QueryParser;
import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.model.search.QuantityConverter;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.utils.EquipmentNames;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.Value;
import org.springframework.stereotype.Service;

/**
 * "Did you mean ...?" for a search that fails (user, 2026-11-18). Each word that isn't a known word
 * (SearchWords) is a possible typo; its closest known words (TypoMatcher) are tried in its place, and the
 * corrected queries go through the parser, closest first. The first that parses, equipment found, is the
 * suggestion: so a word is corrected to whatever fits where it is, wherever the error showed up ("mehcs"
 * read as a weight class is "mechs"). Nothing is searched: a suggestion is text to show, and a search the
 * user runs goes through the parser like any other. A query that parses gets no suggestions.
 *
 * When no spelling parses, words in the wrong place are tried somewhere else (user, 2026-11-18): the one to
 * three words where the grammar stopped ("mechs with 2 ppc or more") are moved to each other place, nearest
 * first, and the first that parses is the suggestion ("mechs with 2 or more ppc"). Only those words move, so
 * a suggestion doesn't rearrange words the grammar understood; one move, not with a spelling fix.
 */
@Service
public class Autocorrect {
  // what's tried: the first few misspelled words, each word's closest few known words
  private static final int MAX_WORDS = 4;
  private static final int CANDIDATES_PER_WORD = 3;
  private static final int MAX_TRIES = 100;
  // the most words moved together ("or more", "at least 2")
  private static final int MAX_MOVED = 3;
  // new imports show up within a minute
  private static final Duration WORDS_KEPT = Duration.ofMinutes(1);
  // a word between spaces; brackets and numbers are never misspelled
  private static final Pattern WORD = Pattern.compile("\\S+");
  private static final Pattern NOT_A_WORD = Pattern.compile(".*[()\\[\\]].*|[^a-zA-Z]*");

  private final EquipmentRepository equipRepo;
  private final SlangRepository slangRepo;
  private volatile SearchWords words;
  private volatile long wordsLoadedAt;

  public Autocorrect(EquipmentRepository equipRepo, SlangRepository slangRepo) {
    this.equipRepo = equipRepo;
    this.slangRepo = slangRepo;
  }

  /** A typed word that isn't a known one, and the known words to try in its place, closest first. */
  @Value
  private static class Typo {
    int start;
    int stop;
    String text;
    List<TypoMatcher.Candidate> candidates;
  }

  /** A choice of candidate (or the word as typed) for each typo, and how far it is from what was typed. */
  @Value
  private static class Try {
    int[] picks;
    int distance;
  }

  /** The query with some words moved, how many places they moved, and how many words they are. */
  @Value
  private static class Move {
    String query;
    int distance;
    int length;
  }

  public Suggestions suggest(String query) {
    if (query == null || query.isBlank() || parses(query)) {
      return Suggestions.NONE;
    }
    Suggestions spelled = spellings(query);
    if (spelled.getQuery() != null) {
      return spelled;
    }
    String moved = moved(query);
    return moved == null ? spelled : new Suggestions(moved, spelled.getWords());
  }

  // each misspelled word's closest known words, tried together through the parser
  private Suggestions spellings(String query) {
    SearchWords known = words();
    List<Typo> typos = new ArrayList<>();
    Matcher word = WORD.matcher(query);
    while (word.find() && typos.size() < MAX_WORDS) {
      String text = word.group();
      if (NOT_A_WORD.matcher(text).matches() || known.contains(EquipmentNames.slangKey(text))) {
        continue;
      }
      List<TypoMatcher.Candidate> candidates = distinct(TypoMatcher.candidates(text, known));
      if (!candidates.isEmpty()) {
        typos.add(new Typo(word.start(), word.end(), text, candidates));
      }
    }
    if (typos.isEmpty()) {
      return Suggestions.NONE;
    }
    String corrected = null;
    List<Set<String>> fits = typos.stream().<Set<String>>map(typo -> new LinkedHashSet<>()).toList();
    for (Try attempt : tries(typos)) {
      String candidate = apply(query, typos, attempt.getPicks());
      if (!parses(candidate)) {
        continue;
      }
      if (corrected == null) {
        corrected = candidate;
      }
      for (int i = 0; i < typos.size(); i++) {
        if (attempt.getPicks()[i] < typos.get(i).getCandidates().size()) {
          fits.get(i).add(typos.get(i).getCandidates().get(attempt.getPicks()[i]).getText());
        }
      }
    }
    List<Suggestions.WordSuggestion> perWord = new ArrayList<>();
    for (int i = 0; i < typos.size(); i++) {
      Typo typo = typos.get(i);
      // in the order the matcher ranked them, not the order the tries found them
      List<String> fit = typo.getCandidates().stream().map(TypoMatcher.Candidate::getText)
          .filter(fits.get(i)::contains).toList();
      if (!fit.isEmpty()) {
        perWord.add(new Suggestions.WordSuggestion(typo.getStart(), typo.getStop(), typo.getText(), fit));
      }
    }
    return new Suggestions(corrected, perWord);
  }

  // The words where the query stopped making sense, moved to the nearest place where it parses; null if
  // there's none. They're the words from there ("mechs heavy with") or the ones just before it ("2 ppc or
  // more" at the end of the query).
  private String moved(String query) {
    List<String> words = new ArrayList<>();
    Matcher word = WORD.matcher(query);
    while (word.find()) {
      words.add(word.group());
    }
    int stuck = stuck(query, words);
    if (stuck < 0) {
      return null;
    }
    List<Move> moves = new ArrayList<>();
    for (int length = 1; length <= MAX_MOVED; length++) {
      moveEverywhere(words, stuck, length, moves);
      moveEverywhere(words, stuck - length, length, moves);
    }
    moves.sort(Comparator.comparingInt(Move::getDistance).thenComparingInt(Move::getLength));
    return moves.stream().limit(MAX_TRIES).map(Move::getQuery).filter(this::parses).findFirst().orElse(null);
  }

  // The index of the word where the grammar stopped (the number of words if at the end), or for a name it
  // took that isn't equipment, the word after it: "with 2 ppc heavy mechs" reads as the name "ppc heavy
  // mechs", and "heavy mechs" are the words to move. -1 if neither.
  private int stuck(String query, List<String> words) {
    int at = QueryParser.syntaxErrorAt(query);
    if (at >= 0) {
      int end = 0;
      for (int i = 0; i < words.size(); i++) {
        end = query.indexOf(words.get(i), end) + words.get(i).length();
        if (end > at) {
          return i;
        }
      }
      return words.size();
    }
    FailedParseException failure = failure(query);
    if (failure == null || failure.getUnknownName() == null) {
      return -1;
    }
    List<String> name = List.of(failure.getUnknownName().split(" "));
    for (int i = 0; i + name.size() <= words.size(); i++) {
      if (words.subList(i, i + name.size()).stream().map(String::toLowerCase).toList().equals(name)) {
        return i + name.size();
      }
    }
    return -1;
  }

  // the words [start, start + length) put at each other place among the rest
  private static void moveEverywhere(List<String> words, int start, int length, List<Move> moves) {
    if (start < 0 || start + length > words.size()) {
      return;
    }
    List<String> moving = words.subList(start, start + length);
    List<String> rest = new ArrayList<>(words.subList(0, start));
    rest.addAll(words.subList(start + length, words.size()));
    for (int place = 0; place <= rest.size(); place++) {
      if (place != start) {
        List<String> moved = new ArrayList<>(rest.subList(0, place));
        moved.addAll(moving);
        moved.addAll(rest.subList(place, rest.size()));
        moves.add(new Move(String.join(" ", moved), Math.abs(place - start), length));
      }
    }
  }

  // each typo's closest few, one per spelling
  private static List<TypoMatcher.Candidate> distinct(List<TypoMatcher.Candidate> candidates) {
    Set<String> seen = new LinkedHashSet<>();
    return candidates.stream().filter(candidate -> seen.add(candidate.getText())).limit(CANDIDATES_PER_WORD).toList();
  }

  // every choice of candidates, the word as typed being one choice too (a word the index doesn't know may still
  // be right, like "20s" in "lrm 20s"), closest first; the query as typed is left out
  private static List<Try> tries(List<Typo> typos) {
    List<Try> tries = new ArrayList<>();
    collect(typos, 0, new int[typos.size()], 0, tries);
    tries.sort(Comparator.comparingInt(Try::getDistance).thenComparingInt(attempt -> sum(attempt.getPicks())));
    return tries.stream().filter(attempt -> attempt.getDistance() > 0).limit(MAX_TRIES).toList();
  }

  private static void collect(List<Typo> typos, int index, int[] picks, int distance, List<Try> tries) {
    if (index == typos.size()) {
      tries.add(new Try(picks.clone(), distance));
      return;
    }
    List<TypoMatcher.Candidate> candidates = typos.get(index).getCandidates();
    for (int pick = 0; pick <= candidates.size(); pick++) {
      picks[index] = pick;
      // the last choice is the word as typed
      int added = pick < candidates.size() ? candidates.get(pick).getDistance() : 0;
      collect(typos, index + 1, picks, distance + added, tries);
    }
  }

  private static int sum(int[] values) {
    int sum = 0;
    for (int value : values) {
      sum += value;
    }
    return sum;
  }

  // the query with each typo replaced by its pick, from the end so the earlier offsets stay right
  private static String apply(String query, List<Typo> typos, int[] picks) {
    StringBuilder corrected = new StringBuilder(query);
    for (int i = typos.size() - 1; i >= 0; i--) {
      Typo typo = typos.get(i);
      if (picks[i] < typo.getCandidates().size()) {
        corrected.replace(typo.getStart(), typo.getStop(), typo.getCandidates().get(picks[i]).getText());
      }
    }
    return corrected.toString();
  }

  // parses and finds its equipment; runs no search
  private boolean parses(String query) {
    return failure(query) == null;
  }

  // why the query doesn't parse, or null if it does
  private FailedParseException failure(String query) {
    try {
      QueryParser.parse(query, equipRepo);
      return null;
    } catch (FailedParseException e) {
      return e;
    }
  }

  private SearchWords words() {
    if (words == null || System.nanoTime() - wordsLoadedAt > WORDS_KEPT.toNanos()) {
      words = load();
      wordsLoadedAt = System.nanoTime();
    }
    return words;
  }

  // the grammar's words, and every equipment name and slang term the search looks up
  private SearchWords load() {
    List<String> fixed = new ArrayList<>();
    fixed.addAll(QueryVocabulary.weightClasses());
    QueryVocabulary.units().forEach(unit -> {
      fixed.add(unit.singular());
      fixed.add(unit.plural());
    });
    fixed.addAll(QueryVocabulary.comparatorsBefore());
    fixed.addAll(QueryVocabulary.comparatorsAfter());
    fixed.addAll(QueryVocabulary.operators());
    fixed.addAll(QueryVocabulary.withWords());
    fixed.addAll(QueryVocabulary.techs().keySet());
    fixed.addAll(QueryVocabulary.unitTechs().keySet());
    fixed.addAll(QueryVocabulary.fireControls());
    fixed.addAll(QueryVocabulary.turretMounts());
    fixed.addAll(QueryVocabulary.omniWords());
    QueryVocabulary.components().values().forEach(fixed::addAll);
    fixed.addAll(QueryVocabulary.keywords());
    fixed.addAll(QuantityConverter.numberWords());
    List<String> equipment = new ArrayList<>();
    // the display name first, so a whole name is shown as typed ("medium laser"), not as stored ("mediumlaser")
    for (Equipment item : equipRepo.findAll()) {
      if (item.getDisplayName() != null) {
        equipment.add(EquipmentNames.typed(item.getDisplayName()));
      }
      equipment.add(item.getName());
    }
    for (Slang term : slangRepo.findAll()) {
      equipment.add(term.getTerm());
    }
    return SearchWords.of(fixed, equipment);
  }
}
