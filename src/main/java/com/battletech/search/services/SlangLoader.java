package com.battletech.search.services;

import com.battletech.search.entities.AmbiguousSlang;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import com.battletech.search.repositories.AmbiguousSlangRepository;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.utils.SlangTerms;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Loads the slang tables from the name files (utils/SlangTerms) for the equipment that's stored.
 * Runs after each import, so new equipment gets its terms; terms added by hand (USER) are kept.
 */
@Slf4j
@Service
public class SlangLoader {
  private final SlangRepository slangRepo;
  private final AmbiguousSlangRepository ambiguousRepo;
  private final EquipmentRepository equipRepo;

  public SlangLoader(SlangRepository slangRepo, AmbiguousSlangRepository ambiguousRepo, EquipmentRepository equipRepo) {
    this.slangRepo = slangRepo;
    this.ambiguousRepo = ambiguousRepo;
    this.equipRepo = equipRepo;
  }

  /** How many terms were loaded, and how many keys are left for someone to decide. */
  public record Loaded(int terms, int ambiguous) {
  }

  @Transactional
  public Loaded load() {
    slangRepo.deleteByKindNot(SlangKind.USER);
    ambiguousRepo.deleteAllRows();
    Set<String> userLookups = slangRepo.findByKind(SlangKind.USER).stream().map(Slang::getLookup)
        .collect(Collectors.toSet());
    SlangTerms.Result result = SlangTerms.build(equipRepo.findAll(), userLookups);
    slangRepo.saveAll(result.terms());
    ambiguousRepo.saveAll(result.ambiguous());

    Map<String, List<String>> ambiguous = result.ambiguous().stream().collect(Collectors.groupingBy(
        AmbiguousSlang::getLookup, TreeMap::new, Collectors.mapping(AmbiguousSlang::getEquipmentName, Collectors.toList())));
    ambiguous.forEach((lookup, names) -> log.info("Ambiguous slang {}: {}", lookup, names));
    log.info("Loaded {} slang terms; {} ambiguous keys left in ambiguous_slang", result.terms().size(), ambiguous.size());
    return new Loaded(result.terms().size(), ambiguous.size());
  }
}
