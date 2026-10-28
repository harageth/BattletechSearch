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
    assertThat(importMechs()).isEqualTo(new ImportResult(5, 0, 0, 0));

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

    assertThat(importMechs()).isEqualTo(new ImportResult(0, 5, 0, 0));

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
    assertThat(result).isEqualTo(new ImportResult(5, 0, 1, 0));
    Unit bulldog = unitRepo.findByMegamekUuid(UUID.fromString("019f583e-e260-75d2-84ad-b6927336283b")).orElseThrow();
    assertThat(bulldog.getName()).isEqualTo("Bulldog Medium Tank");
    assertThat(bulldog.getMulId()).isEqualTo(439);
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
