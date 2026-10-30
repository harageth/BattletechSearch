package com.battletech.search.utils;

import java.io.File;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;

/**
 * What an import couldn't read, or read but had to drop. Each problem is logged as it's found, with
 * the file, and counted per kind for the summary at the end of the import. Kinds that need fixing
 * log as warnings; known gaps and expected names log as info.
 */
@Slf4j
public class ImportProblems {
  private static final int EXAMPLES = 5;

  public enum Kind {
    // the reader drops or blanks something
    UNKNOWN_LOCATION(true, "item in a location the importer doesn't know; saved without a location"),
    UNKNOWN_CONFIG(true, "mech config the importer doesn't know; saved without a locomotion"),
    UNKNOWN_TECH_BASE(true, "tech base the importer doesn't know"),
    UNKNOWN_HEAT_SINK_TYPE(true, "heat sink type the importer doesn't know"),
    UNKNOWN_MOTIVE_TYPE(true, "vehicle motion_type the importer doesn't know"),
    UNKNOWN_COMPONENT(true, "engine, armor, structure, gyro, cockpit, LAM or QuadVee value the importer doesn't know; saved without it"),
    UNREAD_SECTION(true, "equipment section the importer doesn't read; its items are dropped"),
    FIRE_CONTROL_WITHOUT_LAUNCHER(true, "Artemis / Apollo with no launcher to go on; dropped"),
    INVALID_UUID(true, "MegaMek uuid that isn't a uuid; saved without one"),
    // the unit isn't saved
    FAILED(true, "file that couldn't be read; not saved"),
    NO_MUL_ID(false, "unit without a MUL id; not saved (only Master Unit List units are imported)"),
    UNSUPPORTED_UNIT_TYPE(false, "unit type the importer skips"),
    // known gaps and expected names
    SIZE_NOT_KEPT(false, "size of a variable-size item that isn't stored yet (drones, MASH theaters, ...)"),
    UNKNOWN_EQUIPMENT_NAME(false, "equipment name missing from the MegaMek alias table; stored as written"),
    AMBIGUOUS_SLANG(false, "name MegaMek uses for more than one item; no slang term, listed in ambiguous_slang to decide by hand");

    private final boolean warning;
    private final String description;

    Kind(boolean warning, String description) {
      this.warning = warning;
      this.description = description;
    }

    public boolean isWarning() {
      return warning;
    }

    public String getDescription() {
      return description;
    }
  }

  private final Map<Kind, List<String>> found = new EnumMap<>(Kind.class);

  /** The problems of one file. */
  public InFile in(File file) {
    return new InFile(file);
  }

  public synchronized void report(Kind kind, File file, String detail) {
    if (kind.warning) {
      log.warn("{}: {}: {}", file, kind.description, detail);
    } else {
      log.info("{}: {}: {}", file, kind.description, detail);
    }
    count(kind, file, detail);
  }

  /** Counts a problem the caller has already logged its own way (a stack trace). */
  public synchronized void count(Kind kind, File file, String detail) {
    found.computeIfAbsent(kind, k -> new ArrayList<>()).add(file.getName() + ": " + detail);
  }

  /** How many of each kind were found. */
  public synchronized Map<Kind, Integer> counts() {
    Map<Kind, Integer> counts = new EnumMap<>(Kind.class);
    found.forEach((kind, list) -> counts.put(kind, list.size()));
    return counts;
  }

  /** Everything found of one kind, as "file: detail". */
  public synchronized List<String> of(Kind kind) {
    return List.copyOf(found.getOrDefault(kind, List.of()));
  }

  /** One line per kind found: its count, what it means and a few examples. */
  public synchronized String summary() {
    if (found.isEmpty()) {
      return "no problems";
    }
    return found.entrySet().stream()
        .map(entry -> String.format("%s %d (%s), e.g. %s", entry.getKey(), entry.getValue().size(),
            entry.getKey().description,
            String.join("; ", entry.getValue().subList(0, Math.min(EXAMPLES, entry.getValue().size())))))
        .collect(Collectors.joining("\n  ", "\n  ", ""));
  }

  /** Reports problems for one file. */
  public class InFile {
    private final File file;

    private InFile(File file) {
      this.file = file;
    }

    public void report(Kind kind, String detail) {
      ImportProblems.this.report(kind, file, detail);
    }

    public ImportProblems all() {
      return ImportProblems.this;
    }
  }
}
