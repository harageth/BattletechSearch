import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

/**
 * Builds src/main/resources/megamek/equipment-aliases.tsv from MegaMek's source: one line per
 * alternate name, "alias<TAB>display name". MegaMek's .mtf weapon lines use display names
 * ("AC/20") while .blk files and critical slots use internal / lookup names ("Autocannon/20",
 * "ISAC20"); the importer and search map aliases to the display name.
 *
 * Also builds equipment-family-slang.tsv, "term<TAB>display name" for each weapon in a family
 * ("lrms" -> every LRM), from the folder MegaMek keeps the weapon's source in. Search counts a
 * family's weapons together, and the search box offers them in place of each other.
 *
 * Usage (from the repo root, with a MegaMek checkout at the version mm-data is pinned to):
 *   java scripts/GenerateEquipmentAliases.java <megamek>/megamek/src/megamek/common v0.51.00.2
 */
public class GenerateEquipmentAliases {
  // name = "AC/20";  misc.name = "Jump Jet";  this.name = EquipmentTypeLookup.X;
  private static final Pattern NAME = Pattern.compile("^\\s*(?:\\w+\\.)?name\\s*=\\s*(.+?);");
  private static final Pattern INTERNAL = Pattern.compile("setInternalName\\((.+?)\\);");
  private static final Pattern LOOKUP = Pattern.compile("addLookupName\\((.+?)\\);");
  private static final Pattern LITERAL = Pattern.compile("^\"((?:[^\"\\\\]|\\\\.)*)\"$");
  private static final Pattern CONSTANT = Pattern.compile("public static final String (\\w+)\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
  // family term -> weapon sources in it, by path under weapons/. Only IS and Clan weapons (no base
  // classes), and no size-level terms: "medium lasers" would collide with the plural of "Medium Laser"
  private static final Map<String, Pattern> FAMILIES = new java.util.LinkedHashMap<>();
  static {
    FAMILIES.put("lasers", Pattern.compile("lasers/.*"));
    FAMILIES.put("lrms", Pattern.compile("lrms/(?!.*/torpedo/).*"));
    FAMILIES.put("srms", Pattern.compile("srms/(?!.*/torpedo/).*"));
    FAMILIES.put("streaks", Pattern.compile("(lrms|srms)/.*/streak/.*"));
    FAMILIES.put("torpedoes", Pattern.compile("(lrms|srms)/.*/torpedo/.*"));
    FAMILIES.put("mmls", Pattern.compile("missiles/.*/mml/.*"));
    FAMILIES.put("mrms", Pattern.compile("missiles/.*/mrm/.*"));
    // ATMs have no folder of their own; improved ATMs count too
    FAMILIES.put("atms", Pattern.compile("missiles/clan/CLI?ATM\\d+\\.java"));
    // not rifles or the nail / rivet gun, which MegaMek keeps with the autocannons
    FAMILIES.put("autocannons", Pattern.compile("autoCannons/(?!.*(Rifle|Nail)).*"));
    // not plasma weapons, which MegaMek keeps with the PPCs
    FAMILIES.put("ppcs", Pattern.compile("ppc/.*PPC.*"));
    FAMILIES.put("gauss rifles", Pattern.compile("gaussRifles/.*"));
    // not machine gun arrays, which only link machine guns
    FAMILIES.put("machine guns", Pattern.compile("mgs/(?!.*MGA\\.java).*"));
    FAMILIES.put("flamers", Pattern.compile("flamers/.*"));
  }
  private static final Pattern WEAPON_SOURCE = Pattern.compile(".*/(IS|CL)\\w+\\.java");

  public static void main(String[] args) throws IOException {
    Path common = Path.of(args[0]);
    String version = args.length > 1 ? args[1] : "unknown";
    Map<String, String> constants = constants(common.resolve("equipment/EquipmentTypeLookup.java"));

    List<Path> sources = new ArrayList<>();
    try (Stream<Path> weapons = Files.walk(common.resolve("weapons"))) {
      weapons.filter(file -> file.toString().endsWith(".java")).sorted().forEach(sources::add);
    }
    sources.add(common.resolve("equipment/MiscType.java"));
    sources.add(common.resolve("equipment/AmmoType.java"));

    // alias -> display names it was declared for
    Map<String, Set<String>> aliases = new java.util.TreeMap<>();
    // family term -> display names of its weapons, in FAMILIES order
    Map<String, Set<String>> families = new java.util.LinkedHashMap<>();
    FAMILIES.keySet().forEach(term -> families.put(term, new java.util.TreeSet<>()));
    for (Path source : sources) {
      List<String> terms = familiesOf(common.resolve("weapons").relativize(source));
      String display = null;
      for (String line : Files.readAllLines(source, StandardCharsets.UTF_8)) {
        Matcher name = NAME.matcher(line);
        if (name.find()) {
          display = resolve(name.group(1), constants, null);
          for (String term : terms) {
            if (display != null) {
              families.get(term).add(display);
            }
          }
          continue;
        }
        if (display == null) {
          continue;
        }
        for (Pattern pattern : List.of(INTERNAL, LOOKUP)) {
          Matcher alias = pattern.matcher(line);
          while (alias.find()) {
            String value = resolve(alias.group(1), constants, display);
            if (value != null && !value.equals(display)) {
              aliases.computeIfAbsent(value, key -> new LinkedHashSet<>()).add(display);
            }
          }
        }
      }
    }

    Path out = Path.of("src/main/resources/megamek/equipment-aliases.tsv");
    Files.createDirectories(out.getParent());
    int written = 0;
    try (PrintWriter writer = new PrintWriter(Files.newBufferedWriter(out, StandardCharsets.UTF_8))) {
      writer.println("# Equipment aliases from MegaMek " + version + " (https://github.com/MegaMek/megamek, GPL-3.0):");
      writer.println("# alternate name<TAB>display name. Generated by scripts/GenerateEquipmentAliases.java; don't edit by hand.");
      for (Map.Entry<String, Set<String>> entry : aliases.entrySet()) {
        for (String display : entry.getValue()) {
          writer.println(entry.getKey() + "\t" + display);
          written++;
        }
      }
    }
    System.out.println("Wrote " + written + " aliases for " + sources.size() + " source files to " + out);

    Path familyOut = out.resolveSibling("equipment-family-slang.tsv");
    written = 0;
    try (PrintWriter writer = new PrintWriter(Files.newBufferedWriter(familyOut, StandardCharsets.UTF_8))) {
      writer.println("# Weapon families from MegaMek " + version + " (https://github.com/MegaMek/megamek, GPL-3.0):");
      writer.println("# family term<TAB>display name of a weapon in it. Generated by scripts/GenerateEquipmentAliases.java; don't edit by hand.");
      for (Map.Entry<String, Set<String>> entry : families.entrySet()) {
        for (String display : entry.getValue()) {
          writer.println(entry.getKey() + "\t" + display);
          written++;
        }
      }
    }
    System.out.println("Wrote " + written + " family members of " + families.size() + " families to " + familyOut);
  }

  /** The family terms a weapon source file under weapons/ belongs to. */
  private static List<String> familiesOf(Path weaponSource) {
    String path = weaponSource.toString().replace('\\', '/');
    List<String> terms = new ArrayList<>();
    if (path.startsWith("..") || !WEAPON_SOURCE.matcher(path).matches()) {
      return terms;
    }
    FAMILIES.forEach((term, folders) -> {
      if (folders.matcher(path).matches()) {
        terms.add(term);
      }
    });
    return terms;
  }

  private static Map<String, String> constants(Path file) throws IOException {
    Map<String, String> constants = new HashMap<>();
    Matcher matcher = CONSTANT.matcher(Files.readString(file, StandardCharsets.UTF_8));
    while (matcher.find()) {
      constants.put(matcher.group(1), unescape(matcher.group(2)));
    }
    return constants;
  }

  /** A string literal, EquipmentTypeLookup constant or `name`; null for anything computed. */
  private static String resolve(String expression, Map<String, String> constants, String name) {
    String value = expression.trim();
    Matcher literal = LITERAL.matcher(value);
    if (literal.matches()) {
      return unescape(literal.group(1));
    }
    if (value.startsWith("EquipmentTypeLookup.")) {
      return constants.get(value.substring("EquipmentTypeLookup.".length()));
    }
    if (value.equals("name") || value.equals("this.name")) {
      return name;
    }
    return null;
  }

  private static String unescape(String value) {
    return value.replace("\\\"", "\"").replace("\\\\", "\\");
  }
}
