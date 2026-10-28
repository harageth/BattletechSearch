package com.battletech.search.services;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.TestcontainersConfiguration;
import com.battletech.search.entities.Unit;
import com.battletech.search.repositories.UnitRepository;
import com.battletech.search.services.UnitService.ImportResult;
import com.battletech.search.utils.ReadMegaMek;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;

/**
 * Imports the fixture files into the real schema. Rolled back after each test, so the baseline data
 * other tests pin is untouched.
 */
@SpringBootTest
@Import(TestcontainersConfiguration.class)
@Transactional
class UnitServiceImportTest {
  static final UUID ATLAS = UUID.fromString("019f583e-c18a-7a23-98e0-6a19d55887d4");

  @Autowired
  SearchService searchService;

  @Autowired
  UnitService unitService;

  @Autowired
  UnitRepository unitRepo;

  @Autowired
  JdbcTemplate jdbcTemplate;

  private static String fixtures(String directory) {
    try {
      return Path.of(UnitServiceImportTest.class.getResource("/megamek/" + directory).toURI()).toString();
    } catch (URISyntaxException e) {
      throw new IllegalStateException(e);
    }
  }

  private ImportResult importMechs() throws IOException {
    return unitService.persistUnits(fixtures("meks"), ".mtf", ReadMegaMek::ReadMechMTF);
  }

  @PersistenceContext
  EntityManager entityManager;

  // the test shares one transaction with the import, so write pending changes before counting with SQL
  private int count(String sql) {
    entityManager.flush();
    return jdbcTemplate.queryForObject(sql, Integer.class);
  }

  @Test
  void importsMechsWithTheirIds() throws IOException {
    assertThat(importMechs()).isEqualTo(new ImportResult(7, 0, 0, 0));

    Unit atlas = unitRepo.findByMegamekUuid(ATLAS).orElseThrow();
    assertThat(atlas.getName()).isEqualTo("Atlas");
    assertThat(atlas.getDesignation()).isEqualTo("AS7-D");
    assertThat(atlas.getMulId()).isEqualTo(140);
    // 7 weapons and 5 tons of ammo
    assertThat(atlas.getMechEquipment()).hasSize(12);
  }

  @Test
  void reimportingUpdatesInsteadOfDuplicating() throws IOException {
    importMechs();
    int units = count("SELECT count(*) FROM unit");
    int equipmentRows = count("SELECT count(*) FROM unit_equipment");
    UUID atlasId = unitRepo.findByMegamekUuid(ATLAS).orElseThrow().getId();

    assertThat(importMechs()).isEqualTo(new ImportResult(0, 7, 0, 0));

    assertThat(count("SELECT count(*) FROM unit")).isEqualTo(units);
    // the old equipment rows are replaced, not left behind
    assertThat(count("SELECT count(*) FROM unit_equipment")).isEqualTo(equipmentRows);
    assertThat(count("SELECT count(*) FROM unit_mech_equipment ume JOIN unit u ON u.id = ume.unit_id"
        + " WHERE u.megamek_uuid = '" + ATLAS + "'")).isEqualTo(12);
    // the stored unit keeps its database id
    assertThat(unitRepo.findByMegamekUuid(ATLAS).orElseThrow().getId()).isEqualTo(atlasId);
  }

  @Test
  void importsVehiclesAndSkipsSupportVehicles() throws IOException {
    ImportResult result = unitService.persistUnits(fixtures("vehicles"), ".blk", ReadMegaMek::ReadVehicleBlk);

    // Air Car is a SupportTank
    assertThat(result).isEqualTo(new ImportResult(6, 0, 1, 0));
    Unit bulldog = unitRepo.findByMegamekUuid(UUID.fromString("019f583e-e260-75d2-84ad-b6927336283b")).orElseThrow();
    assertThat(bulldog.getName()).isEqualTo("Bulldog Medium Tank");
    assertThat(bulldog.getMulId()).isEqualTo(439);
  }

  @Test
  void searchesImportedVehiclesByMotiveType() throws IOException {
    unitService.persistUnits(fixtures("vehicles"), ".blk", ReadMegaMek::ReadVehicleBlk);
    entityManager.flush();

    // Bulldog (tracked) and Condor (hover) each have two machine guns in front
    assertThat(searchService.performQuery("tracked with at least 2 machine gun"))
        .extracting(row -> row.get("name") + " " + row.get("designation"))
        .containsExactly("Bulldog Medium Tank (AC2)");
    assertThat(searchService.performQuery("hovercraft with at least 2 machine gun"))
        .extracting(row -> row.get("name") + " " + row.get("designation"))
        .containsExactly("Condor Heavy Hover Tank (Davion)");
    assertThat(searchService.performQuery("tanks with at least 2 machine gun"))
        .extracting(row -> row.get("name"))
        .contains("Bulldog Medium Tank", "Condor Heavy Hover Tank");
  }

  private List<String> search(String query) throws IOException {
    return searchService.performQuery(query).stream()
        .map(row -> row.get("name") + " " + row.get("designation")).toList();
  }

  @Test
  void searchesByFireControl() throws IOException {
    importMechs();
    unitService.persistUnits(fixtures("vehicles"), ".blk", ReadMegaMek::ReadVehicleBlk);
    entityManager.flush();

    // the Champion's SRM 6 has Artemis IV; a plain "srm 6" search still counts it
    assertThat(search("mechs with exactly 1 artemis srm 6")).contains("Champion CHP-1N2");
    assertThat(search("mechs with exactly 1 artemis iv srm 6")).contains("Champion CHP-1N2");
    assertThat(search("mechs with exactly 1 artemis v srm 6")).doesNotContain("Champion CHP-1N2");
    assertThat(search("mechs with exactly 1 srm 6")).contains("Champion CHP-1N2");
    // the Atlas' SRM 6 has none
    assertThat(search("mechs with exactly 1 srm 6")).contains("Atlas AS7-D");
    assertThat(search("mechs with exactly 1 artemis srm 6")).doesNotContain("Atlas AS7-D");

    assertThat(search("mechs with 1 apollo mrm 40")).contains("Akuma AKU-2X");
    assertThat(search("tanks with 4 artemis lrm 20")).contains("DI Morgan Assault Tank (LRM)");
  }

  @Test
  void mechsAndVehiclesShareEquipmentNames() throws IOException {
    importMechs();
    unitService.persistUnits(fixtures("vehicles"), ".blk", ReadMegaMek::ReadVehicleBlk);
    entityManager.flush();

    // the Atlas lists "AC/20" (display name); the Bulldog "Autocannon/2" (internal name)
    assertThat(search("units with exactly 1 ac 20")).contains("Atlas AS7-D");
    assertThat(search("units with exactly 2 ac 2")).contains("Bulldog Medium Tank (AC2)");
    assertThat(search("units with exactly 2 autocannon 2")).contains("Bulldog Medium Tank (AC2)");
    // the Mad Cat's "Machine Gun" lines and the Bulldog's "Machine Gun" are the same equipment
    assertThat(search("units with exactly 2 machine gun")).contains("Mad Cat Prime", "Bulldog Medium Tank (AC2)");
    // imported units only use the display names (the baseline data still has the old ones)
    assertThat(count("SELECT count(*) FROM equipment e JOIN unit_equipment ue ON ue.equipment_id = e.id"
        + " JOIN unit_mech_equipment ume ON ume.mech_equipment_id = ue.id JOIN unit u ON u.id = ume.unit_id"
        + " WHERE u.megamek_uuid IS NOT NULL AND e.name IN ('autocannon/2', 'autocannon/20', 'mg')")).isZero();
  }

  @Test
  void techIsOptionalInSearches() throws IOException {
    importMechs();
    entityManager.flush();

    // the Black Knight BL-6-RR is mixed tech: four Clan ER medium lasers, two IS large lasers
    assertThat(search("mechs with exactly 4 er medium laser")).contains("Black Knight BL-6-RR");
    assertThat(search("mechs with exactly 4 clan er medium laser")).contains("Black Knight BL-6-RR");
    assertThat(search("mechs with at least 1 is er medium laser")).doesNotContain("Black Knight BL-6-RR");
    assertThat(search("mechs with exactly 2 inner sphere large laser")).contains("Black Knight BL-6-RR");
  }

  @Test
  void variantsCanShareAMulId() {
    // MUL ids aren't unique: variants of one unit share it
    jdbcTemplate.update("INSERT INTO unit (id, name, designation, mul_id, omni, rules_level, weight,"
        + " bonus_jump, jump, potential_run, potential_walk, run, walk, dtype)"
        + " VALUES (gen_random_uuid(), 'Flatbed Truck', '', 1134, false, 1, 10, 0, 0, 0, 0, 0, 0, 'Tank'),"
        + " (gen_random_uuid(), 'Flatbed Truck', '(AC)', 1134, false, 1, 10, 0, 0, 0, 0, 0, 0, 'Tank')");

    assertThat(unitRepo.findByMulId(1134)).extracting(Unit::getDesignation).containsExactlyInAnyOrder("", "(AC)");
  }
}
