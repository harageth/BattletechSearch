package com.battletech.search.services;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.EquipmentSlang;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import com.battletech.search.utils.EquipmentNames;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class EquipmentService {
  private final EquipmentSlangRepository slangRepo;
  private final EquipmentRepository equipRepo;

  EquipmentService(EquipmentSlangRepository slangRepo, EquipmentRepository equipRepo) {
    this.slangRepo = slangRepo;
    this.equipRepo = equipRepo;
  }

  public void addSlangToEquipment(String equipmentPattern, List<String>slangTerms) {

    // the equipment by its canonical name; slang terms as typed, normalized like search words
    List<Equipment> equips = equipRepo.findByName(EquipmentNames.canonical(equipmentPattern));

    for(Equipment equip : equips) {
      for(String slang: slangTerms) {
        EquipmentSlang slangEquipment = new EquipmentSlang();
        slangEquipment.setEquipment(equip);
        slangEquipment.setSlang(EquipmentNames.normalize(slang));
        slangRepo.save(slangEquipment);
      }
    }
  }
}
