package com.battletech.search.services;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Unit;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.MechEquipmentRepository;
import com.battletech.search.repositories.UnitRepository;
import com.battletech.search.utils.ReadMegaMek;
import com.battletech.search.utils.ReadPDF;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Stream;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class UnitService {
  private final UnitRepository unitRepo;
  private final EquipmentRepository equipRepo;
  private final MechEquipmentRepository mechEquipRepo;
  private final String mechsPath;
  private final String vehiclesPath;
  private final String pdfPath;

  public UnitService(UnitRepository unitRepo, EquipmentRepository equipRepo,
      MechEquipmentRepository mechEquipRepo,
      @Value("${battletech.import.mechs-path}") String mechsPath,
      @Value("${battletech.import.vehicles-path}") String vehiclesPath,
      @Value("${battletech.import.pdf-path}") String pdfPath) {
    this.unitRepo = unitRepo;
    this.equipRepo = equipRepo;
    this.mechEquipRepo = mechEquipRepo;
    this.mechsPath = mechsPath;
    this.vehiclesPath = vehiclesPath;
    this.pdfPath = pdfPath;
  }

  public void persistVehicles() throws IOException {
    persistUnits(vehiclesPath, ReadMegaMek::ReadVehicleBlk);
  }

  public void persistMechs() throws IOException {
    persistUnits(mechsPath, ReadMegaMek::ReadMechMTF);
  }

  /**
   * Reads every file under the directory and saves the units, reusing equipment rows that
   * already exist. A file that fails to import is logged and skipped.
   */
  private void persistUnits(String directory, UnitReader reader) throws IOException {
    try (Stream<Path> files = Files.walk(Paths.get(directory))) {
      files.filter(Files::isRegularFile).forEach(file -> {
        try {
          Unit unit = reader.read(file.toFile());
          if (unit == null) {
            // the reader already logged why it skipped this file
            return;
          }
          for(UnitEquipment equip : unit.getMechEquipment()) {
            if(equip.getEquipment().getTech() == null) {
              equip.getEquipment().setTech(unit.getTech());
            }
            equip.getEquipment().setName(equip.getEquipment().getName().toLowerCase().replaceAll(" ", ""));
            List<Equipment> exists = equipRepo.findByNameAndTech(equip.getEquipment().getName(),
                equip.getEquipment().getTech());
            Equipment equipment = exists.isEmpty() ? equipRepo.save(equip.getEquipment()) : exists.get(0);
            equip.setEquipment(equipment);
          }
          mechEquipRepo.saveAll(unit.getMechEquipment());
          unitRepo.save(unit);
        } catch (Exception e) {
          log.warn("Unable to import {}", file, e);
        }
      });
    }
  }

  public void importRecognitionGuide() {
    ReadPDF pdf = new ReadPDF();
    pdf.readPDF(pdfPath);
  }

  // TODO: look up a single unit; not implemented yet
  public void findUnit() {

  }

  @FunctionalInterface
  private interface UnitReader {
    Unit read(File file) throws IOException;
  }
}
