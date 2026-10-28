package com.battletech.search.services;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Unit;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.MechEquipmentRepository;
import com.battletech.search.repositories.UnitRepository;
import com.battletech.search.utils.EquipmentNames;
import com.battletech.search.utils.ReadMegaMek;
import com.battletech.search.utils.ReadPDF;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

@Slf4j
@Service
public class UnitService {
  private final UnitRepository unitRepo;
  private final EquipmentRepository equipRepo;
  private final MechEquipmentRepository mechEquipRepo;
  private final TransactionTemplate transaction;
  private final String mechsPath;
  private final String vehiclesPath;
  private final String pdfPath;

  public UnitService(UnitRepository unitRepo, EquipmentRepository equipRepo,
      MechEquipmentRepository mechEquipRepo, PlatformTransactionManager transactionManager,
      @Value("${battletech.import.mechs-path}") String mechsPath,
      @Value("${battletech.import.vehicles-path}") String vehiclesPath,
      @Value("${battletech.import.pdf-path}") String pdfPath) {
    this.unitRepo = unitRepo;
    this.equipRepo = equipRepo;
    this.mechEquipRepo = mechEquipRepo;
    this.transaction = new TransactionTemplate(transactionManager);
    this.mechsPath = mechsPath;
    this.vehiclesPath = vehiclesPath;
    this.pdfPath = pdfPath;
  }

  /** How an import went; a re-import of unchanged files only updates. */
  public record ImportResult(int added, int updated, int skipped, int failed) {
  }

  public ImportResult persistVehicles() throws IOException {
    return persistUnits(vehiclesPath, ".blk", ReadMegaMek::ReadVehicleBlk);
  }

  public ImportResult persistMechs() throws IOException {
    return persistUnits(mechsPath, ".mtf", ReadMegaMek::ReadMechMTF);
  }

  /**
   * Reads every file with the extension under the directory and saves its unit, each in its own
   * transaction. A unit whose MegaMek uuid is already stored is updated in place; anything else is
   * added. A file that fails to import is logged and skipped.
   */
  ImportResult persistUnits(String directory, String extension, UnitReader reader) throws IOException {
    if (directory == null || directory.isBlank()) {
      throw new IllegalStateException("No import directory configured; set MEGAMEK_MECHS_PATH / MEGAMEK_VEHICLES_PATH");
    }
    int[] counts = new int[4]; // added, updated, skipped, failed
    try (Stream<Path> files = Files.walk(Paths.get(directory))) {
      files.filter(file -> file.toString().endsWith(extension)).forEach(file -> {
        try {
          Unit unit = reader.read(file.toFile());
          if (unit == null) {
            // the reader already logged why it skipped this file
            counts[2]++;
            return;
          }
          boolean updated = transaction.execute(status -> save(unit));
          counts[updated ? 1 : 0]++;
        } catch (Exception e) {
          counts[3]++;
          log.warn("Unable to import {}", file, e);
        }
      });
    }
    ImportResult result = new ImportResult(counts[0], counts[1], counts[2], counts[3]);
    log.info("Imported {}: {}", directory, result);
    return result;
  }

  /** Saves the unit, replacing the stored one with the same MegaMek uuid. Returns whether it replaced one. */
  private boolean save(Unit unit) {
    for(UnitEquipment equip : unit.getMechEquipment()) {
      if(equip.getEquipment().getTech() == null) {
        equip.getEquipment().setTech(unit.getTech());
      }
      // one name per equipment, whichever MegaMek name the file used ("Autocannon/20" -> "ac/20")
      equip.getEquipment().setName(EquipmentNames.canonical(equip.getEquipment().getName()));
      List<Equipment> exists = equipRepo.findByNameAndTech(equip.getEquipment().getName(),
          equip.getEquipment().getTech());
      Equipment equipment = exists.isEmpty() ? equipRepo.save(equip.getEquipment()) : exists.get(0);
      equip.setEquipment(equipment);
    }

    Optional<Unit> existing = unit.getMegamekUuid() == null
        ? Optional.empty() : unitRepo.findByMegamekUuid(unit.getMegamekUuid());
    // keep the stored id, swap in the new equipment and drop the old equipment rows
    List<UnitEquipment> oldEquipment = existing.map(old -> new ArrayList<>(old.getMechEquipment())).orElse(new ArrayList<>());
    existing.ifPresent(old -> unit.setId(old.getId()));

    mechEquipRepo.saveAll(unit.getMechEquipment());
    unitRepo.save(unit);
    mechEquipRepo.deleteAll(oldEquipment);
    return existing.isPresent();
  }

  public void importRecognitionGuide() {
    ReadPDF pdf = new ReadPDF();
    pdf.readPDF(pdfPath);
  }

  // TODO: look up a single unit; not implemented yet
  public void findUnit() {

  }

  @FunctionalInterface
  interface UnitReader {
    Unit read(File file) throws IOException;
  }
}
