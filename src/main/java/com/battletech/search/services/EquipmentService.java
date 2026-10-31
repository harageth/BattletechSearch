package com.battletech.search.services;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import com.battletech.search.model.Tech;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.utils.EquipmentNames;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EquipmentService {
  private final SlangRepository slangRepo;
  private final EquipmentRepository equipRepo;

  EquipmentService(SlangRepository slangRepo, EquipmentRepository equipRepo) {
    this.slangRepo = slangRepo;
    this.equipRepo = equipRepo;
  }

  /**
   * A row of the equipment page: one item, every tech it's stored in, and the words a search finds
   * it by. Slang is shorthand, user terms and families; other names are MegaMek's aliases.
   */
  public record EquipmentTerms(String name, List<String> techs, List<String> slang, List<String> otherNames) {
  }

  // slang before aliases, so a term that's both is shown as slang
  private static final List<SlangKind> KIND_ORDER = List.of(SlangKind.SHORTHAND, SlangKind.USER,
      SlangKind.FAMILY, SlangKind.FAMILY_SINGULAR, SlangKind.ALIAS);
  // in the order they're shown
  private static final Map<Tech, String> TECH_LABELS = new LinkedHashMap<>();
  static {
    TECH_LABELS.put(Tech.INNER_SPHERE, "IS");
    TECH_LABELS.put(Tech.CLAN, "Clan");
    TECH_LABELS.put(Tech.MIXED_TECH, "Mixed");
  }

  /**
   * Every stored item by display name (IS and Clan rows together), with its slang. A term is left
   * out when it's the item's own name or another term again, apart from case, spacing,
   * punctuation or a MegaMek tech prefix ("CLLRM20", "IS LRM 20" for LRM 20): a search treats
   * those the same.
   */
  @Transactional(readOnly = true)
  public List<EquipmentTerms> equipmentWithSlang() {
    Map<String, TermsBuilder> rows = new TreeMap<>(String.CASE_INSENSITIVE_ORDER);
    for (Equipment equipment : equipRepo.findAll()) {
      TermsBuilder row = rows.computeIfAbsent(shownName(equipment), TermsBuilder::new);
      if (equipment.getTech() != null) {
        row.techs.add(equipment.getTech());
      }
    }
    List<Slang> slang = new ArrayList<>(slangRepo.findAllWithEquipment());
    slang.sort(Comparator.comparing((Slang s) -> KIND_ORDER.indexOf(s.getKind()))
        .thenComparing(Slang::getTerm, String.CASE_INSENSITIVE_ORDER));
    for (Slang term : slang) {
      for (Equipment equipment : term.getEquipment()) {
        TermsBuilder row = rows.get(shownName(equipment));
        if (row != null) {
          row.add(term);
        }
      }
    }
    return rows.values().stream().map(TermsBuilder::build).toList();
  }

  /** The weapon family terms ("lasers", "lrms"), sorted. */
  @Transactional(readOnly = true)
  public List<String> familyTerms() {
    return slangRepo.findByKind(SlangKind.FAMILY).stream().map(Slang::getTerm).sorted().toList();
  }

  private static String shownName(Equipment equipment) {
    return equipment.getDisplayName() != null ? equipment.getDisplayName() : equipment.getName();
  }

  private static class TermsBuilder {
    final String name;
    final Set<Tech> techs = EnumSet.noneOf(Tech.class);
    // by slang key, so each spelling a search treats the same is shown once
    final Set<String> seen = new HashSet<>();
    final List<String> slang = new ArrayList<>();
    final List<String> otherNames = new ArrayList<>();

    TermsBuilder(String name) {
      this.name = name;
      seen.add(EquipmentNames.slangKey(EquipmentNames.stripTechPrefix(name)));
    }

    void add(Slang term) {
      String shown = EquipmentNames.stripTechPrefix(term.getTerm());
      if (seen.add(EquipmentNames.slangKey(shown))) {
        (term.getKind() == SlangKind.ALIAS ? otherNames : slang).add(shown);
      }
    }

    EquipmentTerms build() {
      List<String> labels = TECH_LABELS.entrySet().stream()
          .filter(label -> techs.contains(label.getKey())).map(Map.Entry::getValue).toList();
      return new EquipmentTerms(name, labels, slang, otherNames);
    }
  }

  /**
   * Adds slang terms (USER) for equipment named the way a search would name it. Each term stands for
   * every tech of it: slang doesn't carry a tech, a search filters by one ("clan big ppc" is the
   * slang "bigppc", Clan rows only). A term that already exists keeps what it stood for, gains this
   * equipment, and becomes USER, so the slang load after an import leaves it alone.
   *
   * @throws IllegalArgumentException if no stored equipment goes by that name
   */
  @Transactional
  public void addSlangToEquipment(String equipmentName, List<String> slangTerms) {
    String name = EquipmentNames.canonical(equipmentName);
    List<Equipment> equips = equipRepo.findAllByNameOrSlang(name, EquipmentNames.slangKey(equipmentName));
    if (equips.isEmpty()) {
      throw new IllegalArgumentException("No stored equipment is called " + equipmentName);
    }
    // every tech of what was named ("cllrm20" is the Clan LRM 20, but its slang is any LRM 20)
    List<Equipment> allTechs = equipRepo.findByNameIn(equips.stream().map(Equipment::getName).toList());

    for (String typed : slangTerms) {
      // stored without a tech word
      String term = EquipmentNames.splitTechWord(typed).rest();
      String lookup = EquipmentNames.slangKey(term);
      if (lookup.isEmpty()) {
        continue;
      }
      Slang slang = slangRepo.findByLookup(lookup).orElseGet(() -> new Slang(term, lookup, SlangKind.USER, Set.of()));
      slang.setKind(SlangKind.USER);
      slang.getEquipment().addAll(allTechs);
      slangRepo.save(slang);
    }
  }
}
