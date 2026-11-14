package com.battletech.search;

import com.battletech.search.services.UnitService;
import com.battletech.search.utils.ReadMegaMek;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Units for search tests: imports the MegaMek files under src/test/resources/megamek (meks,
 * vehicles, and search/ for units picked for the search tests) when the test application starts,
 * then puts their equipment in its groups, adds the shorthand and loads the slang again. Import it next to
 * TestcontainersConfiguration; the different config gives these tests their own database, so
 * import tests still start empty.
 */
@TestConfiguration(proxyBeanMethods = false)
public class SearchFixtures {

  @Bean
  ApplicationListener<ApplicationReadyEvent> importSearchFixtures(UnitService unitService, JdbcTemplate jdbcTemplate) {
    return event -> {
      try {
        for (String directory : new String[] {"meks", "search/meks"}) {
          unitService.persistUnits(fixtures(directory), ".mtf", ReadMegaMek::ReadMechMTF);
        }
        for (String directory : new String[] {"vehicles", "search/vehicles"}) {
          unitService.persistUnits(fixtures(directory), ".blk", ReadMegaMek::ReadVehicleBlk);
        }
        putEquipmentInGroups(jdbcTemplate);
        addShorthand(jdbcTemplate);
        unitService.loadSlang();
      } catch (IOException e) {
        throw new UncheckedIOException(e);
      }
    };
  }

  /**
   * Puts the stored equipment in the groups V3_17 would have (db/equipment-group-members.sql). A test
   * database has no equipment when the migrations run, so V3_17 put nothing in them. Load the slang
   * after it, so the groups get their terms.
   */
  public static void putEquipmentInGroups(JdbcTemplate jdbcTemplate) {
    runSql(jdbcTemplate, "/db/equipment-group-members.sql");
  }

  /**
   * Adds the hand-written shorthand ("jj", "medevac"): runs the V3_19 data migration, which tests skip
   * like every db/data migration. It only adds terms for stored equipment, so run it after the imports,
   * and load the slang after it, so MegaMek's names leave the shorthand's keys alone.
   */
  public static void addShorthand(JdbcTemplate jdbcTemplate) {
    runSql(jdbcTemplate, "/db/data/V3_19__shorthand_slang.sql");
  }

  private static void runSql(JdbcTemplate jdbcTemplate, String resource) {
    try (InputStream sql = SearchFixtures.class.getResourceAsStream(resource)) {
      jdbcTemplate.execute(new String(sql.readAllBytes(), StandardCharsets.UTF_8));
    } catch (IOException e) {
      throw new UncheckedIOException(e);
    }
  }

  public static String fixtures(String directory) {
    try {
      return Path.of(SearchFixtures.class.getResource("/megamek/" + directory).toURI()).toString();
    } catch (URISyntaxException e) {
      throw new IllegalStateException(e);
    }
  }
}
