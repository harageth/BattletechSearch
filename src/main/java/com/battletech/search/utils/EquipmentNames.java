package com.battletech.search.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import com.battletech.search.model.Tech;
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
  // "Gauss Rifle Ammo [Clan]", "Ammo LRM-20 (Clan) Artemis-capable": a tech tag. The name drops it
  // (tech is stored separately) and techOf reads it.
  private static final Pattern TECH_SUFFIX = Pattern.compile("\\s*[\\[(](is|clan)[\\])]", Pattern.CASE_INSENSITIVE);

  /**
   * @param prefixTech lookup keys that only exist with a tech prefix ("isac20", "cllrm20") -> that
   *     tech; keys that are also a name on their own (e.g. "claw") aren't in it
   */
  private record AliasTable(Map<String, String> aliases, Map<String, Set<String>> equivalents,
      Map<String, Tech> prefixTech) {
  }

  private static final AliasTable GENERATED = loadAliases("/megamek/equipment-aliases.tsv");
  // letters and digits of an alias or display name -> normalized display name; the hand-written
  // shorthand ("ams", "jj") wins over the generated table
  private static final Map<String, String> ALIASES = new HashMap<>(GENERATED.aliases());
  static {
    ALIASES.putAll(loadAliases("/megamek/equipment-slang.tsv").aliases());
  }
  // normalized display name -> every normalized spelling equipment may be stored under. Data
  // imported before the alias table has "autocannon/2" next to "ac/2"; until it's regenerated a
  // search has to find both.
  private static final Map<String, Set<String>> EQUIVALENTS = GENERATED.equivalents();

  private EquipmentNames() {
  }

  public static String normalize(String name) {
    return TECH_SUFFIX.matcher(MOUNTING.matcher(name).replaceAll("")).replaceAll("").toLowerCase().replaceAll("\\s", "");
  }

  /**
   * The tech a name itself says, or null: a tag ("Gauss Rifle Ammo [Clan]") or a prefix that the
   * name needs ("ISAC20", "cllrm20", as typed in a search). A name that merely starts with those
   * letters ("Claw") says nothing.
   */
  public static Tech techOf(String name) {
    Matcher tag = TECH_SUFFIX.matcher(name);
    if (tag.find()) {
      return tag.group(1).equalsIgnoreCase("clan") ? Tech.CLAN : Tech.INNER_SPHERE;
    }
    return GENERATED.prefixTech().get(key(MOUNTING.matcher(name).replaceAll("")));
  }

  /** The normalized MegaMek display name for any of its names, or just the normalized name. */
  public static String canonical(String name) {
    // "Gauss Rifle Ammo [Clan]": cleaned the same way as the table's keys
    String unmounted = MOUNTING.matcher(TECH_SUFFIX.matcher(name).replaceAll("")).replaceAll("");
    String canonical = ALIASES.get(key(unmounted));
    if (canonical == null) {
      // "ISAC20" as MegaMek writes it, prefix still on
      canonical = ALIASES.get(key(stripTechPrefix(unmounted)));
    }
    return canonical != null ? canonical : normalize(name);
  }

  /** Whether the alias table knows this name (or it's a known display name). */
  public static boolean isKnown(String name) {
    String unmounted = MOUNTING.matcher(TECH_SUFFIX.matcher(name).replaceAll("")).replaceAll("");
    return ALIASES.containsKey(key(unmounted)) || ALIASES.containsKey(key(stripTechPrefix(unmounted)));
  }

  /**
   * Every normalized name equipment with this canonical name may be stored under: the canonical
   * name first, then older spellings ("ac/2" -> "autocannon/2", "ac2").
   */
  public static Set<String> equivalentNames(String canonical) {
    Set<String> names = new LinkedHashSet<>();
    names.add(canonical);
    names.addAll(EQUIVALENTS.getOrDefault(canonical, Set.of()));
    return names;
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

  private static AliasTable loadAliases(String resource) {
    // lookup key -> display names, and stored spelling -> display names
    Map<String, Set<String>> candidates = new HashMap<>();
    Map<String, Set<String>> spellings = new HashMap<>();
    // prefixed key -> techs of its prefix, and keys that also occur without a prefix
    Map<String, Set<Tech>> prefixedKeys = new HashMap<>();
    Set<String> plainKeys = new HashSet<>();
    try (InputStream in = EquipmentNames.class.getResourceAsStream(resource)) {
      if (in == null) {
        log.warn("No equipment alias table at {}", resource);
        return new AliasTable(Map.of(), Map.of(), Map.of());
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
          String stripped = stripTechPrefix(clean);
          // with and without the prefix: searches arrive lowercased ("isac20"), where the
          // case-sensitive prefix check can't strip it
          // (often the same key; the candidate set ignores the repeat)
          for (String key : List.of(key(stripped), key(clean))) {
            candidates.computeIfAbsent(key, k -> new HashSet<>()).add(display);
          }
          plainKeys.add(key(stripped));
          if (!stripped.equals(clean)) {
            prefixedKeys.computeIfAbsent(key(clean), k -> new HashSet<>())
                .add(clean.startsWith("IS") ? Tech.INNER_SPHERE : Tech.CLAN);
          }
          // how an importer without this table would have stored it, prefix stripped
          spellings.computeIfAbsent(normalize(stripped), k -> new HashSet<>()).add(display);
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
    Map<String, Set<String>> equivalents = new HashMap<>();
    spellings.forEach((spelling, displays) -> {
      if (displays.size() == 1) {
        equivalents.computeIfAbsent(displays.iterator().next(), k -> new LinkedHashSet<>()).add(spelling);
      }
    });
    Map<String, Tech> prefixTech = new HashMap<>();
    prefixedKeys.forEach((key, techs) -> {
      if (techs.size() == 1 && !plainKeys.contains(key)) {
        prefixTech.put(key, techs.iterator().next());
      }
    });
    log.debug("Loaded {} equipment aliases, skipped {} ambiguous ones", aliases.size(), ambiguous);
    return new AliasTable(aliases, equivalents, prefixTech);
  }
}
