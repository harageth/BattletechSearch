package com.battletech.search.demo.services;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.EquipmentSlang;
import com.battletech.search.demo.repositories.EquipmentRepository;
import com.battletech.search.demo.repositories.EquipmentSlangRepository;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

@Controller
public class EquipmentService {
  EquipmentSlangRepository slangRepo;
  EquipmentRepository equipRepo;

  @Autowired
  EquipmentService(EquipmentSlangRepository slangRepo, EquipmentRepository equipRepo) {
    this.slangRepo = slangRepo;
    this.equipRepo = equipRepo;
  }

  public void addSlangToEquipment(String equipmentPattern, List<String>slangTerms) {

    List<Equipment> equips = equipRepo.findByName(equipmentPattern);

    for(Equipment equip : equips) {
      for(String slang: slangTerms) {
        EquipmentSlang slangEquipment = new EquipmentSlang();
        slangEquipment.setEquipment(equip);
        slangEquipment.setSlang(slang);
        slangRepo.save(slangEquipment);
      }
    }
  }
}
