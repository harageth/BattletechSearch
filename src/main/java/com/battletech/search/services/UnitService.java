package com.battletech.search.services;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Unit;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.MechEquipmentRepository;
import com.battletech.search.repositories.UnitRepository;
import com.battletech.search.utils.EquipmentNames;
import com.battletech.search.utils.ImportProblems;
import com.battletech.search.utils.ReadMegaMek;
import com.battletech.search.utils.ReadPDF;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
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
  private final SlangLoader slangLoader;
  private final TransactionTemplate transaction;
  private final String mechsPath;
  private final String vehiclesPath;
  private final String pdfPath;

  public UnitService(UnitRepository unitRepo, EquipmentRepository equipRepo,
      MechEquipmentRepository mechEquipRepo, SlangLoader slangLoader, PlatformTransactionManager transactionManager,
      @Value("${battletech.import.mechs-path}") String mechsPath,
      @Value("${battletech.import.vehicles-path}") String vehiclesPath,
      @Value("${battletech.import.pdf-path}") String pdfPath) {
    this.unitRepo = unitRepo;
    this.equipRepo = equipRepo;
    this.mechEquipRepo = mechEquipRepo;
    this.slangLoader = slangLoader;
    this.transaction = new TransactionTemplate(transactionManager);
    this.mechsPath = mechsPath;
    this.vehiclesPath = vehiclesPath;
    this.pdfPath = pdfPath;
  }

  /**
   * How an import went; a re-import of unchanged files only updates. slangTerms is how many slang
   * terms the slang load after it made. problems counts what the readers couldn't read or had to
   * drop, per kind (the log has each one, with its file), and the ambiguous slang keys.
   */
  public record ImportResult(int added, int updated, int skipped, int failed, int slangTerms,
      Map<ImportProblems.Kind, Integer> problems) {
    public ImportResult(int added, int updated, int skipped, int failed) {
      this(added, updated, skipped, failed, 0, Map.of());
    }
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
   * added. A file that fails to import is logged and skipped; so is a unit without a MUL id, which
   * counts as failed.
   */
  public ImportResult persistUnits(String directory, String extension, UnitReader reader) throws IOException {
    if (directory == null || directory.isBlank()) {
      throw new IllegalStateException("No import directory configured; set MEGAMEK_MECHS_PATH / MEGAMEK_VEHICLES_PATH");
    }
    int[] counts = new int[4]; // added, updated, skipped, failed
    ImportProblems problems = new ImportProblems();
    // reported once each; most are expected (Artemis-capable ammo, infantry bays)
    Set<String> unknownNames = new HashSet<>();
    try (Stream<Path> files = Files.walk(Paths.get(directory))) {
      files.filter(file -> file.toString().endsWith(extension)).forEach(file -> {
        ImportProblems.InFile fileProblems = problems.in(file.toFile());
        try {
          Unit unit = reader.read(file.toFile(), fileProblems);
          if (unit == null) {
            // the reader already reported why it skipped this file
            counts[2]++;
            return;
          }
          if (unit.getMulId() == null) {
            // only units in the Master Unit List, the official list
            counts[3]++;
            fileProblems.report(ImportProblems.Kind.NO_MUL_ID, unit.getName() + " " + unit.getDesignation());
            return;
          }
          for (UnitEquipment equip : unit.getMechEquipment()) {
            String name = equip.getEquipment().getName();
            if (!EquipmentNames.isKnown(name) && unknownNames.add(EquipmentNames.normalize(name))) {
              fileProblems.report(ImportProblems.Kind.UNKNOWN_EQUIPMENT_NAME, name);
            }
          }
          boolean updated = transaction.execute(status -> save(unit));
          counts[updated ? 1 : 0]++;
        } catch (Exception e) {
          counts[3]++;
          // the stack trace finds the parser bug; most show up as NPEs
          log.warn("Unable to import {}", file, e);
          problems.count(ImportProblems.Kind.FAILED, file.toFile(), e.toString());
        }
      });
    }
    log.info("Imported {}: {} added, {} updated, {} skipped, {} failed. Problems: {}", directory, counts[0],
        counts[1], counts[2], counts[3], problems.summary());
    // slang links the stored equipment, so it's loaded once the units are in
    SlangLoader.Loaded slang = slangLoader.load();
    Map<ImportProblems.Kind, Integer> problemCounts = problems.counts();
    if (slang.ambiguous() > 0) {
      problemCounts.put(ImportProblems.Kind.AMBIGUOUS_SLANG, slang.ambiguous());
    }
    return new ImportResult(counts[0], counts[1], counts[2], counts[3], slang.terms(), problemCounts);
  }

  /** Loads the slang again on its own, e.g. after a line was added to megamek/equipment-slang.tsv. */
  public SlangLoader.Loaded loadSlang() {
    return slangLoader.load();
  }

  /** Saves the unit, replacing the stored one with the same MegaMek uuid. Returns whether it replaced one. */
  private boolean save(Unit unit) {
    for(UnitEquipment equip : unit.getMechEquipment()) {
      if(equip.getEquipment().getTech() == null) {
        equip.getEquipment().setTech(unit.getTech());
      }
      // one name per equipment, whichever MegaMek name the file used ("Autocannon/20" -> "ac/20"),
      // and MegaMek's display name for showing ("AC/20")
      String written = equip.getEquipment().getDisplayName() != null
          ? equip.getEquipment().getDisplayName() : equip.getEquipment().getName();
      equip.getEquipment().setName(EquipmentNames.canonical(equip.getEquipment().getName()));
      equip.getEquipment().setDisplayName(EquipmentNames.displayName(written));
      List<Equipment> exists = equipRepo.findByNameAndTech(equip.getEquipment().getName(),
          equip.getEquipment().getTech());
      Equipment equipment = exists.isEmpty() ? equipRepo.save(equip.getEquipment()) : exists.get(0);
      if (equipment.getDisplayName() == null) {
        // stored before display names were
        equipment.setDisplayName(equip.getEquipment().getDisplayName());
        equipment = equipRepo.save(equipment);
      }
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
  public interface UnitReader {
    Unit read(File file, ImportProblems.InFile problems) throws IOException;
  }
}
