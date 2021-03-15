package com.battletech.search.services;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Unit;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import com.battletech.search.repositories.MechEquipmentRepository;
import com.battletech.search.repositories.UnitRepository;
import com.battletech.search.utils.ReadMegaMek;
import com.battletech.search.utils.ReadPDF;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class UnitService {

  @Autowired
  UnitRepository unitRepo;

  @Autowired
  EquipmentRepository equipRepo;

  @Autowired
  MechEquipmentRepository mechEquipRepo;

  @Autowired
  EquipmentSlangRepository slangRepo;

  @Autowired
  private JdbcTemplate jdbcTemplate;

  public void persistVehicles() throws IOException {
    String basePath = "/Users/adam9500/workspace/megamek/megamek/data/mechfiles/vehicles";
    Files.walk(Paths.get(basePath))
        .filter(Files::isRegularFile)
        .forEach(name -> {
          Unit unit = null;
          try {
            unit = ReadMegaMek.ReadVehicleBlk(name.toFile());
            Equipment equipment;
            for(UnitEquipment equip : unit.getMechEquipment()) {
              if(equip.getEquipment().getTech() == null) {
                equip.getEquipment().setTech(unit.getTech());
              }
              equip.getEquipment().setName(equip.getEquipment().getName().toLowerCase().replaceAll(" ", ""));
              List<Equipment> exists = equipRepo.findByNameAndTech(equip.getEquipment().getName(),
                  equip.getEquipment().getTech());
              if(exists.isEmpty()) {
                //equipment = equipRepo.findByName(equip.getEquipment().getName()).get();
                equipment = equipRepo.save(equip.getEquipment());
              }else {
                equipment = exists.get(0);
              }
              equip.setEquipment(equipment);
            }
            mechEquipRepo.saveAll(unit.getMechEquipment());
            unitRepo.save(unit);
          } catch (Exception e) {
            System.out.println("Unable to persist: " + name.toString());
          }
        });
  }

  public void persistMechs() throws IOException {
    String basePath = "/Users/adam9500/workspace/megamek/megamek/data/mechfiles/mechs";

    Files.walk(Paths.get(basePath))
        .filter(Files::isRegularFile)
        .forEach(name -> {
          Unit unit = null;
          try {
            unit = ReadMegaMek.ReadMechMTF(name.toFile());
            Equipment equipment;
            for(UnitEquipment equip : unit.getMechEquipment()) {
              if(equip.getEquipment().getTech() == null) {
                equip.getEquipment().setTech(unit.getTech());
              }
              equip.getEquipment().setName(equip.getEquipment().getName().toLowerCase().replaceAll(" ", ""));
              List<Equipment> exists = equipRepo.findByNameAndTech(equip.getEquipment().getName(),
                  equip.getEquipment().getTech());
              if(exists.isEmpty()) {
                //equipment = equipRepo.findByName(equip.getEquipment().getName()).get();
                equipment = equipRepo.save(equip.getEquipment());
              }else {
                equipment = exists.get(0);
              }
              equip.setEquipment(equipment);
            }
            mechEquipRepo.saveAll(unit.getMechEquipment());
            unitRepo.save(unit);
          }catch(Exception e) {
            System.out.println("Unable to load mech: " + name.toString());
          }

        });

    //Unit mech = ReadMegaMek.ReadMTF();
    //equipRepo.saveAll(mech.getEquipment());

    //unitRepo.save(mech);

    //return mech;
    //return;
  }

  public void PDFTest() {
    ReadPDF pdf = new ReadPDF();
    pdf.readPDF();
  }

  public void findUnit() {
    
  }

}