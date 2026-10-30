package com.battletech.search.services;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.utils.EquipmentNames;
import java.util.List;
import java.util.Set;
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
