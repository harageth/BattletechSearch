package com.battletech.search.utils;

import com.battletech.search.model.Tech;
import java.util.Arrays;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * The bays on a vehicle's {@code <transporters>} lines, each stored as an item with its tons (user, 2026-11-15:
 * "We just need the value in tons. People can figure out what it can do after that"). A line is
 * {@code type:size[:doors:bay number:platoon type:facing:flags][:omni]}; the size is tons, or a count of seats,
 * platoons, squads or vehicles, turned into tons with MegaMek's weights (its BLKFile.addTransports and bay classes).
 */
public enum TransportBay {
  // battle armor rides in infantry compartments too, so all three are one item (user, 2026-11-15)
  TROOP_SPACE("troopspace", "Infantry Compartment", 1),
  INFANTRY_BAY("infantrybay", "Infantry Compartment", 0),
  BATTLE_ARMOR_BAY("battlearmorbay", "Infantry Compartment", 0),
  CARGO_BAY("cargobay", "Cargo Bay", 1),
  LIQUID_CARGO_BAY("liquidcargobay", "Liquid Cargo Bay", 1),
  INSULATED_CARGO_BAY("insulatedcargobay", "Insulated Cargo Bay", 1),
  REFRIGERATED_CARGO_BAY("refrigeratedcargobay", "Refrigerated Cargo Bay", 1),
  LIVESTOCK_CARGO_BAY("livestockcargobay", "Livestock Cargo Bay", 1),
  CREW_QUARTERS("crewquarters", "Crew Quarters", 1),
  STEERAGE_QUARTERS("steeragequarters", "Steerage Quarters", 1),
  SECOND_CLASS_QUARTERS("2ndclassquarters", "Second Class Quarters", 1),
  FIRST_CLASS_QUARTERS("1stclassquarters", "First Class Quarters", 1),
  // tons per seat
  STANDARD_SEATS("standardseats", "Standard Seating", 0.075),
  PILLION_SEATS("pillionseats", "Pillion Seating", 0.025),
  EJECTION_SEATS("ejectionseats", "Ejection Seating", 0.1),
  // tons per vehicle
  LIGHT_VEHICLE_BAY("lightvehiclebay", "Light Vehicle Bay", 50);

  private static final Map<String, TransportBay> BY_TYPE = Arrays.stream(values())
      .collect(Collectors.toMap(bay -> bay.type, Function.identity()));
  // MegaMek's PlatoonType weights, tons per platoon
  private static final Map<String, Integer> PLATOON_TONS = Map.of("foot", 5, "jump", 6, "motorized", 7, "mechanized", 8);
  private static final int COMSTAR_FLAG = 1;
  private static final int CLAN_FLAG = 2;

  private final String type;
  private final String displayName;
  private final double tonsPerUnit;

  TransportBay(String type, String displayName, double tonsPerUnit) {
    this.type = type;
    this.displayName = displayName;
    this.tonsPerUnit = tonsPerUnit;
  }

  /** The bay a line names, or null for a type that isn't one (battle armor handles, or one we don't know). */
  public static TransportBay of(String line) {
    return BY_TYPE.get(type(line));
  }

  /** The line's type, lowercased: "cargobay", "battlearmorhandles - troopers". */
  public static String type(String line) {
    return line.trim().split(":", 2)[0].trim().toLowerCase(Locale.ROOT);
  }

  /** Whether a line is the battle armor handles every combat vehicle has; MegaMek doesn't load them as a bay. */
  public static boolean isHandles(String line) {
    return type(line).startsWith("battlearmorhandles");
  }

  /** Whether the bay is pod-mounted on an OmniVehicle. */
  public static boolean isOmniPod(String line) {
    return line.trim().toLowerCase(Locale.ROOT).endsWith(":omni");
  }

  /** Whether a stored name is a bay's, which the reader makes and MegaMek's alias table doesn't list. */
  public static boolean isBayName(String name) {
    String normalized = EquipmentNames.normalize(name);
    return Arrays.stream(values()).anyMatch(bay -> EquipmentNames.normalize(bay.displayName).equals(normalized));
  }

  public String getDisplayName() {
    return displayName;
  }

  /** The bay's tons from its line; the chassis tech decides a battle armor bay's when the line has no flags. */
  public double tons(String line, Tech chassisTech) {
    String[] fields = line.trim().replaceFirst("(?i):omni$", "").split(":", -1);
    double size = Double.parseDouble(fields[1]);
    double tons = switch (this) {
      case INFANTRY_BAY -> size * platoonTons(fields);
      // MegaMek's BattleArmorBay weight: 2 tons per trooper's worth, by tech
      case BATTLE_ARMOR_BAY -> {
        int flags = fields.length > 6 && !fields[6].isEmpty() ? Integer.parseInt(fields[6])
            : (chassisTech == Tech.CLAN ? CLAN_FLAG : 0);
        yield size * 2 * ((flags & CLAN_FLAG) != 0 ? 5 : (flags & COMSTAR_FLAG) != 0 ? 6 : 4);
      }
      default -> size * tonsPerUnit;
    };
    // 6 seats x 0.075 is 0.44999999999999996
    return Math.round(tons * 1000) / 1000.0;
  }

  // the platoon type is in its own field, or (older lines) the last one; foot when there's none
  private static int platoonTons(String[] fields) {
    for (int i = 2; i < fields.length; i++) {
      Integer tons = PLATOON_TONS.get(fields[i].toLowerCase(Locale.ROOT));
      if (tons != null) {
        return tons;
      }
    }
    return PLATOON_TONS.get("foot");
  }
}
