package com.battletech.search.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import com.battletech.search.model.Tech;
import lombok.extern.slf4j.Slf4j;

/**
 * The one normal form for equipment names, shared by the importers, search queries and slang, so
 * "Medium Laser", "medium laser" and "MediumLaser" all match "mediumlaser".
 *
 * MegaMek also names the same equipment differently in different places: .mtf weapon lines use
 * display names ("AC/20"), .blk files and critical slots use internal names ("Autocannon/20",
 * "ISAC20"). {@link #canonical} maps those to the display name for the importer, using
 * megamek/equipment-aliases.tsv, generated from MegaMek's source by
 * scripts/GenerateEquipmentAliases.java. Search doesn't use it: the same files are loaded into the
 * slang tables after each import (SlangTerms, services/SlangLoader).
 */
@Slf4j
public final class EquipmentNames {
  public static final String ALIASES = "/megamek/equipment-aliases.tsv";
  public static final String FAMILIES = "/megamek/equipment-family-slang.tsv";
  public static final String SHORTHAND = "/megamek/equipment-slang.tsv";

  // how a weapon is mounted, not what it is: rear-facing, one-shot, improved one-shot, sponson turret.
  // Annotations that name a different item, like "(Vehicle)" or "(B-Pods)", are kept.
  private static final Pattern MOUNTING = Pattern.compile("\\s*\\((r|os|i-os|ios|st)\\)", Pattern.CASE_INSENSITIVE);
  // "Gauss Rifle Ammo [Clan]", "Ammo LRM-20 (Clan) Artemis-capable": a tech tag. The name drops it
  // (tech is stored separately).
  private static final Pattern TECH_SUFFIX = Pattern.compile("\\s*[\\[(](is|clan)[\\])]", Pattern.CASE_INSENSITIVE);
  // how a file marks a unit's item rather than the item: "Cargo:SIZE:1.0", "CLLRM20:OMNI"
  private static final Pattern ITEM_SUFFIX = Pattern.compile(":(omni|size).*$", Pattern.CASE_INSENSITIVE);

  /**
   * @param aliases lookup key -> normalized display name, for keys with only one (the hand-written
   *     shorthand wins over the generated table)
   * @param displays normalized display name -> the display name as MegaMek writes it, tags removed
   */
  private record AliasTable(Map<String, String> aliases, Map<String, String> displays) {
  }

  private static final AliasTable TABLE = loadAliases();

  private EquipmentNames() {
  }

  /**
   * A display name the way someone would type it: lowercase, single spaces, no mounting or tech tag
   * ("LRM 10 (OS)" -> "lrm 10"). {@link #normalize} of it is the canonical name.
   */
  public static String typed(String display) {
    return withoutTags(display).replaceAll("\\s+", " ").toLowerCase();
  }

  public static String normalize(String name) {
    return TECH_SUFFIX.matcher(MOUNTING.matcher(name).replaceAll("")).replaceAll("").toLowerCase().replaceAll("\\s", "");
  }

  /** The name without mounting notes and tech tags, case kept: "LRM 10 (OS)" -> "LRM 10". */
  public static String withoutTags(String name) {
    return MOUNTING.matcher(TECH_SUFFIX.matcher(name).replaceAll("")).replaceAll("").strip();
  }

  /** What slang is looked up by: the letters and digits, lowercase. "LB 10-X AC" -> "lb10xac". */
  public static String slangKey(String name) {
    return name.toLowerCase().replaceAll("[^a-z0-9]", "");
  }

  /** The normalized MegaMek display name for any of its names, or just the normalized name. */
  public static String canonical(String name) {
    // "Gauss Rifle Ammo [Clan]": cleaned the same way as the table's keys
    String unmounted = withoutTags(name);
    String canonical = TABLE.aliases().get(slangKey(unmounted));
    if (canonical == null) {
      // "ISAC20" as MegaMek writes it, prefix still on
      canonical = TABLE.aliases().get(slangKey(stripTechPrefix(unmounted)));
    }
    return canonical != null ? canonical : normalize(name);
  }

  /** Whether the alias table knows this name (or it's a known display name). */
  public static boolean isKnown(String name) {
    String unmounted = withoutTags(name);
    return TABLE.aliases().containsKey(slangKey(unmounted))
        || TABLE.aliases().containsKey(slangKey(stripTechPrefix(unmounted)));
  }

  /**
   * The name to show people for equipment a file wrote this way: MegaMek's display name
   * ("Autocannon/20" -> "AC/20"), or for names MegaMek doesn't list, the file's spelling without
   * prefix, tags and size.
   */
  public static String displayName(String written) {
    String item = ITEM_SUFFIX.matcher(written).replaceAll("");
    String display = TABLE.displays().get(canonical(item));
    if (display != null) {
      return display;
    }
    return stripTechPrefix(withoutTags(item)).replaceAll("\\s+", " ");
  }

  // a leading tech word as people type it (lowercase, spaced); longest first
  private static final Map<String, Tech> TECH_WORDS = new LinkedHashMap<>();
  static {
    TECH_WORDS.put("inner sphere ", Tech.INNER_SPHERE);
    TECH_WORDS.put("clan ", Tech.CLAN);
    TECH_WORDS.put("is ", Tech.INNER_SPHERE);
  }

  /** The tech words a search can start an equipment name with, as typed ("inner sphere"), and their tech. */
  public static Map<String, Tech> techWords() {
    Map<String, Tech> words = new LinkedHashMap<>();
    TECH_WORDS.forEach((word, tech) -> words.put(word.strip(), tech));
    return words;
  }

  /** Typed text split into its leading tech word (null tech if none) and the rest. */
  public record TechWord(Tech tech, String rest) {
  }

  /**
   * "clan er medium laser" -> CLAN, "er medium laser". Search uses it to filter by tech, and slang
   * registration to store terms without it, since slang applies to every tech.
   */
  public static TechWord splitTechWord(String typed) {
    String lower = typed.strip().toLowerCase();
    for (Map.Entry<String, Tech> word : TECH_WORDS.entrySet()) {
      if (lower.startsWith(word.getKey()) && lower.length() > word.getKey().length()) {
        return new TechWord(word.getValue(), lower.substring(word.getKey().length()));
      }
    }
    return new TechWord(null, lower);
  }

  /** The name without a leading "IS" / "CL" / "Clan" tech prefix, as MegaMek writes them ("ISAC20", "Clan Gauss Ammo"). */
  public static String stripTechPrefix(String name) {
    if (name.startsWith("Clan")) {
      return name.substring(4).strip();
    } else if (name.startsWith("CL") || name.startsWith("IS")) {
      return name.substring(2).strip();
    }
    return name;
  }

  /**
   * One way to look up a line of the alias file: the key, the normalized display name it stands
   * for, the spelling it came from, and the tech its MegaMek prefix says (null without one).
   */
  public record AliasKey(String key, String display, String term, Tech prefixTech) {
  }

  /**
   * The lookup keys of an alias line (alias, display name): both names, each with and without a
   * tech prefix. Searches arrive lowercased ("isac20"), where the case-sensitive prefix check can't
   * strip it, so the prefixed key is kept too. The display name comes first.
   */
  public static List<AliasKey> aliasKeys(String alias, String display) {
    String canonical = normalize(display);
    List<AliasKey> keys = new ArrayList<>();
    // the display name is a key too, so "lb 10-x ac" finds "LB 10-X AC"
    for (String name : new String[] {display, alias}) {
      String clean = withoutTags(name);
      String stripped = stripTechPrefix(clean);
      keys.add(new AliasKey(slangKey(stripped), canonical, stripped, null));
      if (!stripped.equals(clean)) {
        keys.add(new AliasKey(slangKey(clean), canonical, clean, clean.startsWith("IS") ? Tech.INNER_SPHERE : Tech.CLAN));
      }
    }
    return keys;
  }

  /** The rows of a tab-separated resource, without comments and blank lines; empty if it's missing. */
  public static List<String[]> readTsv(String resource) {
    List<String[]> rows = new ArrayList<>();
    try (InputStream in = EquipmentNames.class.getResourceAsStream(resource)) {
      if (in == null) {
        log.warn("No equipment names at {}", resource);
        return rows;
      }
      BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
      String line;
      while ((line = reader.readLine()) != null) {
        if (!line.startsWith("#") && !line.isBlank()) {
          rows.add(line.split("\t"));
        }
      }
    } catch (IOException e) {
      throw new UncheckedIOException(e);
    }
    return rows;
  }

  private static AliasTable loadAliases() {
    // lookup key -> display names
    Map<String, Set<String>> candidates = new HashMap<>();
    Map<String, String> displays = new HashMap<>();
    for (String[] row : readTsv(ALIASES)) {
      displays.putIfAbsent(normalize(row[1]), withoutTags(row[1]));
      for (AliasKey key : aliasKeys(row[0], row[1])) {
        candidates.computeIfAbsent(key.key(), k -> new HashSet<>()).add(key.display());
      }
    }
    Map<String, String> aliases = new HashMap<>();
    candidates.forEach((key, names) -> {
      // the same name for different equipment; the slang load keeps those for someone to decide
      if (names.size() == 1) {
        aliases.put(key, names.iterator().next());
      }
    });
    // a term on several lines: a unit file's item is named after the first
    Set<String> shorthandKeys = new HashSet<>();
    for (String[] row : readTsv(SHORTHAND)) {
      if (shorthandKeys.add(slangKey(row[0]))) {
        aliases.put(slangKey(row[0]), normalize(row[1]));
      }
    }
    log.debug("Loaded {} equipment aliases", aliases.size());
    return new AliasTable(aliases, displays);
  }
}
