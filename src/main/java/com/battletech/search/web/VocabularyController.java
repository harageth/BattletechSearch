package com.battletech.search.web;

import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.antlr.QueryVocabulary.UnitWord;
import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import com.battletech.search.model.Tech;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.utils.EquipmentNames;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The words the search box offers in place of each other when you hover one: the other weight
 * classes, unit words, comparators, and the weapons in an equipment family.
 */
@RestController
public class VocabularyController {
  private static final Pattern NUMBER = Pattern.compile("\\d+");
  // "lrm 5" before "lrm 10": by the words, then the first number
  private static final Comparator<String> BY_NAME = Comparator.<String, String>comparing(name -> NUMBER.matcher(name).replaceAll(""))
      .thenComparingInt(VocabularyController::firstNumber);

  private final SlangRepository slangRepo;

  public VocabularyController(SlangRepository slangRepo) {
    this.slangRepo = slangRepo;
  }

  /**
   * @param families family term -> its weapons as typed, only ones some unit has and a query can type
   * @param equipment a weapon as typed -> the families it's in
   */
  public record Vocabulary(List<String> weightClasses, List<UnitWord> units,
      List<String> comparatorsBefore, List<String> comparatorsAfter, List<String> operators,
      List<String> withWords, Map<String, Tech> techs, List<String> fireControls, Map<String, List<String>> families,
      Map<String, List<String>> equipment) {
  }

  @GetMapping("/api/vocabulary")
  @Transactional(readOnly = true)
  public ResponseEntity<Vocabulary> vocabulary() {
    Map<String, List<String>> families = new LinkedHashMap<>();
    Map<String, List<String>> equipment = new LinkedHashMap<>();
    // family terms only link equipment some unit has
    List<Slang> terms = new ArrayList<>(slangRepo.findByKind(SlangKind.FAMILY));
    terms.sort(Comparator.comparing(Slang::getTerm));
    for (Slang family : terms) {
      // as a query can name them: "blazer" for the Binary Laser (Blazer) Cannon
      List<String> searchable = family.getEquipment().stream()
          .map(member -> EquipmentNames.typed(member.getDisplayName() != null ? member.getDisplayName() : member.getName()))
          .map(QueryVocabulary::typedName)
          .filter(Objects::nonNull)
          .distinct()
          .sorted(BY_NAME)
          .toList();
      if (!searchable.isEmpty()) {
        families.put(family.getTerm(), searchable);
        searchable.forEach(member -> equipment.computeIfAbsent(member, k -> new ArrayList<>()).add(family.getTerm()));
      }
    }
    Vocabulary vocabulary = new Vocabulary(QueryVocabulary.weightClasses(), QueryVocabulary.units(),
        QueryVocabulary.comparatorsBefore(), QueryVocabulary.comparatorsAfter(),
        QueryVocabulary.operators(), QueryVocabulary.withWords(), QueryVocabulary.techs(), QueryVocabulary.fireControls(),
        families, equipment);
    // new imports show up within the hour
    return ResponseEntity.ok().cacheControl(CacheControl.maxAge(Duration.ofHours(1))).body(vocabulary);
  }

  private static int firstNumber(String name) {
    Matcher number = NUMBER.matcher(name);
    return number.find() ? Integer.parseInt(number.group()) : 0;
  }
}
