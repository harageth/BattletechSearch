package com.battletech.search;

import com.battletech.search.services.UnitService;
import com.battletech.search.utils.ReadMegaMek;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URISyntaxException;
import java.nio.file.Path;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;

/**
 * Units for search tests: imports the MegaMek files under src/test/resources/megamek (meks,
 * vehicles, and search/ for units picked for the search tests) when the test application starts,
 * which also loads the slang. Import it next to TestcontainersConfiguration; the different config
 * gives these tests their own database, so import tests still start empty.
 */
@TestConfiguration(proxyBeanMethods = false)
public class SearchFixtures {

  @Bean
  ApplicationListener<ApplicationReadyEvent> importSearchFixtures(UnitService unitService) {
    return event -> {
      try {
        for (String directory : new String[] {"meks", "search/meks"}) {
          unitService.persistUnits(fixtures(directory), ".mtf", ReadMegaMek::ReadMechMTF);
        }
        for (String directory : new String[] {"vehicles", "search/vehicles"}) {
          unitService.persistUnits(fixtures(directory), ".blk", ReadMegaMek::ReadVehicleBlk);
        }
      } catch (IOException e) {
        throw new UncheckedIOException(e);
      }
    };
  }

  public static String fixtures(String directory) {
    try {
      return Path.of(SearchFixtures.class.getResource("/megamek/" + directory).toURI()).toString();
    } catch (URISyntaxException e) {
      throw new IllegalStateException(e);
    }
  }
}
