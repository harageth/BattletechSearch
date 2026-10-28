package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.entities.Unit;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

/**
 * Parses every file in a MegaMek mm-data checkout. Only runs when MEGAMEK_MECHS_PATH /
 * MEGAMEK_VEHICLES_PATH are set, e.g. to check a new mm-data commit before re-importing.
 */
class ReadMegaMekAllFilesTest {

  interface Reader {
    Unit read(File file) throws Exception;
  }

  /** Parses every file with the extension; returns the failures. Prints a summary line. */
  private static List<String> parseAll(String directory, String extension, Reader reader) throws IOException {
    List<String> failures = new ArrayList<>();
    int[] parsed = {0, 0}; // files, skipped (reader returned null)
    try (Stream<Path> files = Files.walk(Path.of(directory))) {
      files.filter(file -> file.toString().endsWith(extension)).forEach(file -> {
        parsed[0]++;
        try {
          if (reader.read(file.toFile()) == null) {
            parsed[1]++;
          }
        } catch (Exception e) {
          failures.add(file + ": " + e);
        }
      });
    }
    failures.forEach(System.out::println);
    System.out.printf("%s: %d files, %d skipped, %d failed%n", directory, parsed[0], parsed[1], failures.size());
    assertThat(parsed[0]).as("files found in " + directory).isPositive();
    return failures;
  }

  @Test
  @EnabledIfEnvironmentVariable(named = "MEGAMEK_MECHS_PATH", matches = ".+")
  void everyMechParses() throws IOException {
    assertThat(parseAll(System.getenv("MEGAMEK_MECHS_PATH"), ".mtf", ReadMegaMek::ReadMechMTF)).isEmpty();
  }

  @Test
  @EnabledIfEnvironmentVariable(named = "MEGAMEK_VEHICLES_PATH", matches = ".+")
  void everyVehicleParses() throws IOException {
    // unsupported unit types (support vehicles etc.) are skipped, not failures
    assertThat(parseAll(System.getenv("MEGAMEK_VEHICLES_PATH"), ".blk", ReadMegaMek::ReadVehicleBlk)).isEmpty();
  }
}
