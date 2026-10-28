package com.battletech.search.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import lombok.extern.slf4j.Slf4j;

/**
 * The one normal form for equipment names, shared by the importers, search queries and slang, so
 * "Medium Laser", "medium laser" and "MediumLaser" all match "mediumlaser".
 *
 * MegaMek also names the same equipment differently in different places: .mtf weapon lines use
 * display names ("AC/20"), .blk files and critical slots use internal names ("Autocannon/20",
 * "ISAC20"). {@link #canonical} maps those to the display name using
 * megamek/equipment-aliases.tsv, generated from MegaMek's source by
 * scripts/GenerateEquipmentAliases.java. These mappings are meant to move into the slang data
 * (equipment_slang) later.
 */
@Slf4j
public final class EquipmentNames {
  // how a weapon is mounted, not what it is: rear-facing, one-shot, improved one-shot, sponson turret.
  // Annotations that name a different item, like "(Vehicle)" or "(B-Pods)", are kept.
  private static final Pattern MOUNTING = Pattern.compile("\\s*\\((r|os|i-os|ios|st)\\)", Pattern.CASE_INSENSITIVE);
  // "Gauss Rifle Ammo [Clan]": the tech is stored separately
  private static final Pattern TECH_SUFFIX = Pattern.compile("\\s*[\\[(](is|clan)[\\])]$", Pattern.CASE_INSENSITIVE);

  // letters and digits of an alias or display name -> normalized display name
  private static final Map<String, String> ALIASES = loadAliases("/megamek/equipment-aliases.tsv");

  private EquipmentNames() {
  }

  public static String normalize(String name) {
    return MOUNTING.matcher(name).replaceAll("").toLowerCase().replaceAll("\\s", "");
  }

  /** The normalized MegaMek display name for any of its names, or just the normalized name. */
  public static String canonical(String name) {
    String unmounted = MOUNTING.matcher(name).replaceAll("");
    String canonical = ALIASES.get(key(unmounted));
    if (canonical == null) {
      // "ISAC20" as MegaMek writes it, prefix still on
      canonical = ALIASES.get(key(stripTechPrefix(unmounted)));
    }
    return canonical != null ? canonical : normalize(name);
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

  private static String key(String name) {
    return name.toLowerCase().replaceAll("[^a-z0-9]", "");
  }

  private static Map<String, String> loadAliases(String resource) {
    Map<String, Set<String>> candidates = new HashMap<>();
    try (InputStream in = EquipmentNames.class.getResourceAsStream(resource)) {
      if (in == null) {
        log.warn("No equipment alias table at {}", resource);
        return Map.of();
      }
      BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
      String line;
      while ((line = reader.readLine()) != null) {
        if (line.startsWith("#") || line.isBlank()) {
          continue;
        }
        String[] columns = line.split("\t");
        String display = normalize(TECH_SUFFIX.matcher(columns[1]).replaceAll(""));
        // the display name is a key too, so "lb 10-x ac" finds "LB 10-X AC"
        for (String alias : new String[] {columns[0], columns[1]}) {
          String clean = MOUNTING.matcher(TECH_SUFFIX.matcher(alias).replaceAll("")).replaceAll("");
          candidates.computeIfAbsent(key(stripTechPrefix(clean)), k -> new HashSet<>()).add(display);
        }
      }
    } catch (IOException e) {
      throw new UncheckedIOException(e);
    }
    Map<String, String> aliases = new HashMap<>();
    int ambiguous = 0;
    for (Map.Entry<String, Set<String>> entry : candidates.entrySet()) {
      if (entry.getValue().size() == 1) {
        aliases.put(entry.getKey(), entry.getValue().iterator().next());
      } else {
        // the same name for different equipment; leave it alone rather than guess
        ambiguous++;
      }
    }
    log.debug("Loaded {} equipment aliases, skipped {} ambiguous ones", aliases.size(), ambiguous);
    return aliases;
  }
}
