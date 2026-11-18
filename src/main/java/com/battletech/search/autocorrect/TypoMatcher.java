package com.battletech.search.autocorrect;

import com.battletech.search.utils.EquipmentNames;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import lombok.Value;

/**
 * The known words a typed word may be a typo of (user, 2026-11-18). A typo is a swapped pair, a missing,
 * an extra or a wrong letter, each one edit (optimal string alignment distance), compared on the keys, so
 * case and punctuation don't count. How many edits a word may be off goes by its length, as Elasticsearch's
 * "fuzziness: AUTO": none for 1-2 letters, 1 for 3-5, 2 for 6 or more. A word that is two known words run
 * together ("heavymechs") is one edit off "heavy mechs". Equally close words: fixed words of the grammar
 * before equipment, then alphabetical. Ranking by how many units have an item, as spell-checkers rank by
 * frequency, is a future improvement (autocorrect skill).
 */
public final class TypoMatcher {
  /** A known word, or two run together, and how many edits the typed word is off it. */
  @Value
  public static class Candidate {
    String text;
    int distance;
    boolean fixed;
  }

  private static final Comparator<Candidate> CLOSEST = Comparator.comparingInt(Candidate::getDistance)
      .thenComparing(candidate -> !candidate.isFixed())
      .thenComparing(Candidate::getText);

  // the pieces of a run-together word are words of at least this many letters ("heavy" + "mechs")
  private static final int MIN_PIECE = 2;

  private TypoMatcher() {
  }

  /** How many edits a word of this many letters and digits may be off a known word. */
  static int allowedEdits(int length) {
    return length <= 2 ? 0 : length <= 5 ? 1 : 2;
  }

  /** The known words this one may be a typo of, closest first; none for a known word or a short one. */
  public static List<Candidate> candidates(String typed, SearchWords words) {
    String key = EquipmentNames.slangKey(typed);
    int allowed = allowedEdits(key.length());
    if (allowed == 0 || words.contains(key)) {
      return List.of();
    }
    List<Candidate> found = new ArrayList<>();
    for (SearchWords.Word word : words.all()) {
      if (Math.abs(word.getKey().length() - key.length()) <= allowed) {
        int distance = distance(key, word.getKey());
        if (distance <= allowed) {
          found.add(new Candidate(word.getText(), distance, word.isFixed()));
        }
      }
    }
    // "heavymechs": two known words with nothing between them
    for (int split = MIN_PIECE; split <= key.length() - MIN_PIECE; split++) {
      SearchWords.Word left = words.get(key.substring(0, split));
      SearchWords.Word right = words.get(key.substring(split));
      if (left != null && right != null) {
        found.add(new Candidate(left.getText() + " " + right.getText(), 1, left.isFixed() && right.isFixed()));
      }
    }
    found.sort(CLOSEST);
    return found;
  }

  /** Optimal string alignment distance: insertions, deletions, substitutions and adjacent swaps. */
  static int distance(String a, String b) {
    int[][] d = new int[a.length() + 1][b.length() + 1];
    for (int i = 0; i <= a.length(); i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= b.length(); j++) {
      d[0][j] = j;
    }
    for (int i = 1; i <= a.length(); i++) {
      for (int j = 1; j <= b.length(); j++) {
        int cost = a.charAt(i - 1) == b.charAt(j - 1) ? 0 : 1;
        d[i][j] = Math.min(Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1), d[i - 1][j - 1] + cost);
        if (i > 1 && j > 1 && a.charAt(i - 1) == b.charAt(j - 2) && a.charAt(i - 2) == b.charAt(j - 1)) {
          d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + 1);
        }
      }
    }
    return d[a.length()][b.length()];
  }
}
