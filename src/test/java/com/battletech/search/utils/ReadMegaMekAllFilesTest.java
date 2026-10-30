package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.entities.Unit;
import com.battletech.search.utils.ImportProblems.Kind;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.EnumMap;
import java.util.Map;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

/**
 * Parses every file in a MegaMek mm-data checkout. Only runs when MEGAMEK_MECHS_PATH /
 * MEGAMEK_VEHICLES_PATH are set, e.g. to check a new mm-data commit before re-importing.
 *
 * Besides files that fail, it checks the readers report no warnings (ImportProblems): none at the
 * pinned commit, so a new kind of misread shows up here instead of silently in the data. The printed
 * summary lists them, and the info kinds (known gaps).
 */
class ReadMegaMekAllFilesTest {

  interface Reader {
    Unit read(File file, ImportProblems.InFile problems) throws Exception;
  }

  /** Parses every file with the extension; returns the problems found. Prints a summary. */
  private static ImportProblems parseAll(String directory, String extension, Reader reader) throws IOException {
    ImportProblems problems = new ImportProblems();
    int[] parsed = {0, 0}; // files, skipped (reader returned null)
    try (Stream<Path> files = Files.walk(Path.of(directory))) {
      files.filter(file -> file.toString().endsWith(extension)).forEach(file -> {
        parsed[0]++;
        try {
          if (reader.read(file.toFile(), problems.in(file.toFile())) == null) {
            parsed[1]++;
          }
        } catch (Exception e) {
          problems.count(Kind.FAILED, file.toFile(), e.toString());
        }
      });
    }
    System.out.printf("%s: %d files, %d skipped. Problems: %s%n", directory, parsed[0], parsed[1], problems.summary());
    assertThat(parsed[0]).as("files found in " + directory).isPositive();
    return problems;
  }

  /** The counts of the warning kinds only; info kinds are known gaps or expected. */
  private static Map<Kind, Integer> warnings(ImportProblems problems) {
    Map<Kind, Integer> warnings = new EnumMap<>(Kind.class);
    problems.counts().forEach((kind, count) -> {
      if (kind.isWarning()) {
        warnings.put(kind, count);
      }
    });
    return warnings;
  }

  @Test
  @EnabledIfEnvironmentVariable(named = "MEGAMEK_MECHS_PATH", matches = ".+")
  void everyMechParses() throws IOException {
    ImportProblems problems = parseAll(System.getenv("MEGAMEK_MECHS_PATH"), ".mtf", ReadMegaMek::ReadMechMTF);
    assertThat(warnings(problems)).isEmpty();
  }

  @Test
  @EnabledIfEnvironmentVariable(named = "MEGAMEK_VEHICLES_PATH", matches = ".+")
  void everyVehicleParses() throws IOException {
    ImportProblems problems = parseAll(System.getenv("MEGAMEK_VEHICLES_PATH"), ".blk", ReadMegaMek::ReadVehicleBlk);
    assertThat(warnings(problems)).isEmpty();
  }
}
