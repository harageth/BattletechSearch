package com.battletech.search.web;

import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.antlr.QueryVocabulary.UnitWord;
import com.battletech.search.model.Tech;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.utils.EquipmentNames;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The words the search box offers in place of each other when you hover one: the other weight
 * classes, unit words, comparators, and the weapons in an equipment family.
 */
@RestController
public class VocabularyController {
  private final EquipmentRepository equipRepo;

  public VocabularyController(EquipmentRepository equipRepo) {
    this.equipRepo = equipRepo;
  }

  /**
   * @param families family term -> its weapons as typed, only ones some unit has and a query can type
   * @param equipment a weapon as typed -> the families it's in
   */
  public record Vocabulary(List<String> weightClasses, List<UnitWord> units,
      List<String> comparatorsBefore, List<String> comparatorsAfter, List<String> operators,
      Map<String, Tech> techs, List<String> fireControls, Map<String, List<String>> families,
      Map<String, List<String>> equipment) {
  }

  @GetMapping("/api/vocabulary")
  public ResponseEntity<Vocabulary> vocabulary() {
    // stored under older spellings too until the data is regenerated ("autocannon/2")
    Set<String> stored = equipRepo.findAllNames().stream().map(EquipmentNames::canonical)
        .collect(Collectors.toSet());
    Map<String, List<String>> families = new LinkedHashMap<>();
    Map<String, List<String>> equipment = new LinkedHashMap<>();
    EquipmentNames.families().forEach((term, members) -> {
      List<String> searchable = members.stream()
          .filter(member -> stored.contains(EquipmentNames.normalize(member)))
          .filter(QueryVocabulary::isTypeable)
          .toList();
      if (!searchable.isEmpty()) {
        families.put(term, searchable);
        searchable.forEach(member -> equipment.computeIfAbsent(member, k -> new ArrayList<>()).add(term));
      }
    });
    Vocabulary vocabulary = new Vocabulary(QueryVocabulary.weightClasses(), QueryVocabulary.units(),
        QueryVocabulary.comparatorsBefore(), QueryVocabulary.comparatorsAfter(),
        QueryVocabulary.operators(), QueryVocabulary.techs(), QueryVocabulary.fireControls(),
        families, equipment);
    // new imports show up within the hour
    return ResponseEntity.ok().cacheControl(CacheControl.maxAge(Duration.ofHours(1))).body(vocabulary);
  }
}
