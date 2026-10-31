package com.battletech.search.utils;

import com.battletech.search.model.ArmorType;
import com.battletech.search.model.CockpitType;
import com.battletech.search.model.EngineType;
import com.battletech.search.model.GyroType;
import com.battletech.search.model.StructureType;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * The components a search can name ("xl engine", "endo steel", "small cockpit"), from the type
 * enums' texts. Each name stands for stored type names in one unit column. A component isn't
 * equipment: QueryVisitor looks a chunk's name up here before the equipment.
 */
public final class ComponentNames {

  /** A kind of component: its word, the unit column holding its type, and the column for its tech. */
  public enum Kind {
    ENGINE("engine", "engine_type", "engine_tech"),
    ARMOR("armor", "armor_type", "armor_tech"),
    STRUCTURE("structure", "structure_type", "structure_tech"),
    GYRO("gyro", "gyro", null),
    COCKPIT("cockpit", "cockpit", null);

    private final String word;
    private final String column;
    private final String techColumn;

    Kind(String word, String column, String techColumn) {
      this.word = word;
      this.column = column;
      this.techColumn = techColumn;
    }

    public String getWord() {
      return word;
    }

    public String getColumn() {
      return column;
    }

    /** Null when the kind has no tech (gyros, cockpits). */
    public String getTechColumn() {
      return techColumn;
    }
  }

  /**
   * A component as a search names it.
   *
   * @param name how it's typed, "xl engine"
   * @param types the enum names stored for it; a base type takes its prototype along ("endo steel"
   *     is ENDO_STEEL and ENDO_STEEL_PROTOTYPE)
   */
  public record Component(Kind kind, String name, List<String> types) {
  }

  // lookup key (EquipmentNames.slangKey) -> component
  private static final Map<String, Component> BY_KEY = new HashMap<>();
  // kind -> its components' typed names, in enum order, for the search box
  private static final Map<Kind, List<String>> NAMES = new LinkedHashMap<>();

  static {
    Map<Kind, Map<String, String>> texts = new LinkedHashMap<>();
    texts.put(Kind.ENGINE, texts(EngineType.values(), EngineType::getText));
    texts.put(Kind.ARMOR, texts(ArmorType.values(), ArmorType::getText));
    texts.put(Kind.STRUCTURE, texts(StructureType.values(), StructureType::getText));
    texts.put(Kind.GYRO, texts(GyroType.values(), GyroType::getText));
    texts.put(Kind.COCKPIT, texts(CockpitType.values(), CockpitType::getText));

    // a bare text ("endo steel", "stealth") only names armor or structure, and only when no other
    // kind's type has that text too: "standard", "industrial", "xl" always need the kind word
    Map<String, Long> bareCounts = texts.entrySet().stream()
        .flatMap(kind -> kind.getValue().values().stream().map(text -> bare(text, kind.getKey())))
        .collect(Collectors.groupingBy(EquipmentNames::slangKey, Collectors.counting()));

    texts.forEach((kind, byType) -> {
      List<String> names = new ArrayList<>();
      byType.forEach((type, text) -> {
        if (text.equalsIgnoreCase("none")) {
          return;
        }
        List<String> types = new ArrayList<>(List.of(type));
        if (byType.containsKey(type + "_PROTOTYPE")) {
          types.add(type + "_PROTOTYPE");
        }
        String name = text.toLowerCase().endsWith(kind.word) || kind == Kind.COCKPIT && text.endsWith("Console")
            ? text.toLowerCase() : text.toLowerCase() + " " + kind.word;
        Component component = new Component(kind, name, List.copyOf(types));
        names.add(name);
        add(name, component);
        String bare = bare(text, kind).toLowerCase();
        if ((kind == Kind.ARMOR || kind == Kind.STRUCTURE) && bareCounts.get(EquipmentNames.slangKey(bare)) == 1
            && !EquipmentNames.isKnown(bare)) {
          add(bare, component);
        }
      });
      NAMES.put(kind, List.copyOf(names));
    });
    // MegaMek's "Fusion" is the standard engine
    add("standard engine", BY_KEY.get(EquipmentNames.slangKey("fusion engine")));
  }

  private ComponentNames() {
  }

  private static <T extends Enum<T>> Map<String, String> texts(T[] values, Function<T, String> text) {
    return Arrays.stream(values).collect(Collectors.toMap(Enum::name, text, (a, b) -> a, LinkedHashMap::new));
  }

  // the text without its kind word: "XL Gyro" -> "XL"
  private static String bare(String text, Kind kind) {
    return text.replaceAll("(?i)\\s+" + kind.word + "$", "");
  }

  private static void add(String name, Component component) {
    BY_KEY.putIfAbsent(EquipmentNames.slangKey(name), component);
  }

  /** The component a chunk names ("xl engine", "Endo-Steel"), without any tech word; null if none. */
  public static Component find(String typed) {
    return BY_KEY.get(EquipmentNames.slangKey(typed));
  }

  /** Each kind's components as typed ("xl engine", "light engine", ...), for the search box. */
  public static Map<Kind, List<String>> names() {
    return NAMES;
  }

  /** Every lookup key a component answers to; none may also be equipment. */
  static Map<String, Component> keys() {
    return BY_KEY;
  }
}
