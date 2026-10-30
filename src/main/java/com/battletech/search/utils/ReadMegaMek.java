package com.battletech.search.utils;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.ArmorType;
import com.battletech.search.model.CockpitType;
import com.battletech.search.model.EngineType;
import com.battletech.search.model.FireControl;
import com.battletech.search.model.GyroType;
import com.battletech.search.model.LamType;
import com.battletech.search.model.Location;
import com.battletech.search.model.Locomotion;
import com.battletech.search.model.MotiveSystem;
import com.battletech.search.entities.Mech;
import com.battletech.search.model.Movement;
import com.battletech.search.model.StructureType;
import com.battletech.search.model.Tech;
import com.battletech.search.entities.Unit;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ReadMegaMek {

  public static Unit ReadVehicleBlk(File filePath) throws IOException {
    return ReadVehicleBlk(filePath, new ImportProblems().in(filePath));
  }

  /** Reads a .blk vehicle, reporting what it can't read to problems; null for unit types it skips. */
  public static Unit ReadVehicleBlk(File filePath, ImportProblems.InFile problems) throws IOException {
    BufferedReader reader = new BufferedReader(new FileReader(filePath));
    Vehicle vee;
    Map<String, List<String>> value = readBlkAllParameters(reader);

    String type = value.get("unittype").get(0);
    /*
    SupportTank
    SupportVTOL
    LargeSupportTank
     */
    if (type.equalsIgnoreCase("VTOL")) {
      vee = new Vtol();
    } else if (type.equalsIgnoreCase("Tank")) {
      Tank tank = new Tank();
      String motion = first(value, "motion_type");
      tank.setMotiveSystem(motion == null ? null : MotiveSystem.fromString(motion));
      if(tank.getMotiveSystem() == null) {
        problems.report(ImportProblems.Kind.UNKNOWN_MOTIVE_TYPE, String.valueOf(motion));
      }
      vee = tank;
    } else {
      problems.report(ImportProblems.Kind.UNSUPPORTED_UNIT_TYPE, type);
      return null;
    }
    // the type tells us whether it's IS, Clan or mixed tech, e.g. "Mixed (Clan Chassis) Experimental"
    String techBase = value.get("type").get(0);
    vee.setTech(Tech.fromTechBase(techBase));
    if(vee.getTech() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_TECH_BASE, techBase);
    }
    // equipment without an IS/Clan prefix is the chassis tech
    Tech chassisTech = Tech.chassisTech(techBase);
    vee.setName(value.get("name").get(0));
    vee.setMegamekUuid(parseUuid(first(value, "uuid"), problems));
    // the tag is literally <mul id:>
    vee.setMulId(parseMulId(first(value, "mul id:")));
    List<String> model = value.get("model");
    vee.setDesignation(model == null || model.isEmpty() ? "" : model.get(0));
    vee.setWeight(Integer.parseInt(value.get("tonnage").get(0).split("\\.")[0]));
    Movement move = new Movement();
    move.setWalk(Integer.parseInt(value.get("cruisemp").get(0)));
    vee.setMovement(move);
    int totalArmor = 0;
    for (String armorValue : value.get("armor")) {
      totalArmor = totalArmor + Integer.parseInt(armorValue);
    }
    readBlkComponents(vee, value, chassisTech, problems);
    VEHICLE_SECTIONS.forEach((tag, location) -> {
      if(value.get(tag) != null) {
        vee.setMechEquipment(convertToEquipment(value.get(tag), chassisTech, location, problems));
      }
    });
    // any other "... equipment" section is reported (wings, nose and aft are on skipped aircraft)
    value.forEach((tag, items) -> {
      if(tag.endsWith("equipment") && !VEHICLE_SECTIONS.containsKey(tag) && !items.isEmpty()) {
        problems.report(ImportProblems.Kind.UNREAD_SECTION, "<" + tag + "> " + items);
      }
    });

    if(value.get("transporters") != null && !value.get("transporters").get(0).isEmpty()){
      Equipment equip = new Equipment("infantry bay", chassisTech);
      equip.setDisplayName("Infantry Bay");
      equip.setTonnage(0.5);
      UnitEquipment infantryBay = new UnitEquipment();
      infantryBay.setEquipment(equip);
      infantryBay.setLocation(Location.BODY);
      infantryBay.setTonnage(Double.parseDouble(value.get("transporters").get(0).split(":")[1]));
      vee.setMechEquipment(Collections.singletonList(infantryBay));
    }

    return vee;
  }

  static List<UnitEquipment> convertToEquipment(List<String> equipment, Tech chassisTech, Location location,
      ImportProblems.InFile problems) {
    List<UnitEquipment> returnEquipment = new LinkedList<UnitEquipment>();
    List<FireControl> unattached = new LinkedList<>();
    for(String equip: equipment) {
      UnitEquipment value = new UnitEquipment();
      value.setEquipment(new Equipment());
      value.setLocation(location);
      // as written, for the display name (UnitService)
      value.getEquipment().setDisplayName(equip);
      equip = equip.toLowerCase();
      // "communications equipment:size:4.0": the size goes on this unit's item, not in the name
      Double size = sizeOf(equip);
      if(size != null) {
        equip = equip.substring(0, equip.indexOf(":size:"));
      }
      // there is a problem if something is both rear facing and omni equipped
      if(equip.endsWith(":omni")) {
        value.setOmniPod(true);
        equip = equip.split(":")[0].strip();
      }
      if(equip.contains("(r)")) {
        value.setRearFacing(true);
        equip = equip.split("\\(")[0].strip();
      }
      //sponson equipped
      if(equip.contains("(st)")) {
        equip = equip.split("\\(")[0].strip();
        // add a sponson equipment if not already equipped?
      }
      if(equip.contains("(i-os)") || equip.contains("(os)")) {

        equip = equip.split("\\(")[0].strip();
      }
      if(equip.startsWith("is")) {
        value.getEquipment().setTech(Tech.INNER_SPHERE);
        value.getEquipment().setName(equip.substring(2).strip());
      } else if(equip.startsWith("cl")) {
        value.getEquipment().setTech(Tech.CLAN);
        if(equip.startsWith("clan")) {
          value.getEquipment().setName(equip.substring(4).strip());
        }else {
          value.getEquipment().setName(equip.substring(2).strip());
        }
      } else {
        value.getEquipment().setTech(chassisTech);
        value.getEquipment().setName(equip);
      }
      setSize(value, value.getEquipment().getName(), size, problems);
      // Artemis / Apollo upgrade the launcher listed before them rather than being equipment
      FireControl fireControl = FireControl.fromEquipmentName(value.getEquipment().getName());
      if(fireControl != null) {
        String previous = returnEquipment.isEmpty() ? null : returnEquipment.get(returnEquipment.size() - 1).getEquipment().getName();
        if(!attachFireControl(fireControl, returnEquipment, previous)) {
          unattached.add(fireControl);
        }
        continue;
      }
      returnEquipment.add(value);
    }
    // the few listed before their launcher
    for(FireControl fireControl : unattached) {
      if(!attachFireControl(fireControl, returnEquipment, null)) {
        problems.report(ImportProblems.Kind.FIRE_CONTROL_WITHOUT_LAUNCHER, fireControl + " in " + location);
      }
    }

    return returnEquipment;
  }

  /** Every <tag> in a .blk file, keyed by lowercase tag name. Values keep their original case. */
  static Map<String, List<String>> readBlkAllParameters(BufferedReader reader) throws IOException {
    boolean loop = true;
    Map<String, List<String>> parameters = new HashMap();
    List<String> parameterList = new LinkedList();
    String paramName = "";
    while(loop) {
      String temp = reader.readLine();
      if(temp == null) {
        break;
      }
      if(!temp.isEmpty()) {
        if(temp.equalsIgnoreCase("</"+paramName+">")) {
          parameters.put(paramName, parameterList);
          parameterList = new LinkedList();
        } else if (temp.startsWith("<") && temp.indexOf("</") > 0) {
          // a whole tag on one line, e.g. "<Model></Model>" for an empty value
          int open = temp.indexOf('>');
          String value = temp.substring(open + 1, temp.indexOf("</")).trim();
          List<String> values = new LinkedList<>();
          if(!value.isEmpty()) {
            values.add(value);
          }
          parameters.put(temp.substring(1, open).toLowerCase(), values);
        } else if (temp.startsWith("<")) {
          paramName = temp.substring(1, temp.length()-1).toLowerCase();
        }else {
          if(!temp.startsWith("#")) {
            parameterList.add(temp);
          }
        }
      }
    }
    reader.close();
    return parameters;
  }

  /**
   * Reads a MegaMek .mtf file. Current files start with a "#" license block, then "key:value"
   * lines (chassis:, model:, techbase:, mass:, ...), the armor values, "Weapons:N" followed by N
   * "name, location" lines, then the critical slots per location.
   */
  public static Unit ReadMechMTF(File filePath) throws IOException {
    return ReadMechMTF(filePath, new ImportProblems().in(filePath));
  }

  /** Reads a .mtf mech, reporting what it can't read to problems. */
  public static Unit ReadMechMTF(File filePath, ImportProblems.InFile problems) throws IOException {
    List<String> lines;
    try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
      lines = reader.lines().filter(line -> !line.startsWith("#")).toList();
    }
    Map<String, String> fields = readMtfFields(lines);

    Mech mech = new Mech();
    String name = requiredField(fields, "chassis", filePath);
    String designation = fields.getOrDefault("model", "");
    mech.setName(name);
    mech.setMegamekUuid(parseUuid(fields.get("uuid"), problems));
    mech.setMulId(parseMulId(fields.get("mul id")));
    if(designation.isEmpty()) {
      mech.setDesignation(name + " prime");// or is it base?
    }else {
      mech.setDesignation(designation);
    }
    // e.g. "Biped", "Biped OmniMek", "Quad"
    String config = requiredField(fields, "config", filePath);
    mech.setLocomotion(Locomotion.fromString(config.split(" ")[0]));
    if(mech.getLocomotion() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_CONFIG, config);
    }
    String techBase = requiredField(fields, "techbase", filePath);
    mech.setTech(Tech.fromTechBase(techBase));
    if(mech.getTech() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_TECH_BASE, techBase);
    }
    mech.setEra(fields.get("era")); // now a year, e.g. 2755
    mech.setRulesLevel(Integer.parseInt(requiredField(fields, "rules level", filePath)));
    mech.setWeight(Integer.parseInt(requiredField(fields, "mass", filePath)));
    readMtfComponents(mech, fields, Tech.chassisTech(techBase), problems);
    mech.setMyomer(fields.get("myomer"));
    // tech has to be set first; heat sinks copy it
    String heatSinks = requiredField(fields, "heat sinks", filePath);
    mech.setHeatsinks(heatSinks);
    if(mech.getHeatsinks().getType() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_HEAT_SINK_TYPE, heatSinks);
    }
    Movement move = new Movement();
    move.setWalk(Integer.parseInt(requiredField(fields, "walk mp", filePath)));
    move.setJump(Integer.parseInt(requiredField(fields, "jump mp", filePath)));
    mech.setMovement(move);
    // armor isn't imported yet

    Tech chassisTech = Tech.chassisTech(techBase);
    List<UnitEquipment> equipment = readMtfWeapons(lines, filePath, chassisTech, problems);
    Map<String, List<String>> slots = readMtfSlots(lines);
    attachMtfFireControl(equipment, slots, problems);
    equipment.addAll(readMtfSlotEquipment(slots, chassisTech, problems));
    mech.setMechEquipment(equipment);
    return mech;
  }

  /**
   * Engine, armor and structure from MegaMek's codes, read the way its BLKTankFile / BLKVTOLFile do:
   * a missing <engine_type> is fusion, <armor_type> standard and <internal_type> standard. The engine
   * rating isn't in the file; it comes from cruise MP, tonnage and the suspension factor.
   */
  static void readBlkComponents(Vehicle vee, Map<String, List<String>> value, Tech chassisTech,
      ImportProblems.InFile problems) {
    String engineCode = first(value, "engine_type");
    vee.setEngineType(EngineType.fromBlkCode(engineCode == null ? 0 : Integer.parseInt(engineCode)));
    if(vee.getEngineType() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "engine_type " + engineCode);
    }
    // only there when the engine's tech differs from the chassis
    String clanEngine = first(value, "clan_engine");
    vee.setEngineTech(clanEngine == null ? chassisTech
        : Boolean.parseBoolean(clanEngine) ? Tech.CLAN : Tech.INNER_SPHERE);
    String motion = first(value, "motion_type");
    vee.setEngineRating(engineRating(vee.getEngineType(), vee.getMovement().getWalk(),
        Double.parseDouble(value.get("tonnage").get(0)), motion == null ? null : MotiveSystem.fromString(motion)));

    String armorCode = first(value, "armor_type");
    vee.setArmorType(ArmorType.fromCode(armorCode == null ? 0 : Integer.parseInt(armorCode)));
    if(vee.getArmorType() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "armor_type " + armorCode);
    }
    String armorTechLevel = first(value, "armor_tech_level");
    Tech armorTech = armorTechLevel == null ? null : techOfLevel(Integer.parseInt(armorTechLevel));
    vee.setArmorTech(armorTech != null ? armorTech : chassisTech);

    String structureCode = first(value, "internal_type");
    vee.setStructureType(StructureType.fromCode(structureCode == null ? 0 : Integer.parseInt(structureCode)));
    if(vee.getStructureType() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "internal_type " + structureCode);
    }
    vee.setStructureTech(chassisTech);
  }

  /** MegaMek's TechConstants level: Clan or IS, or null for unknown / both (-1, T_TW_ALL). */
  private static Tech techOfLevel(int level) {
    return switch (level) {
      case 2, 6, 8, 10, 12 -> Tech.CLAN;
      case 0, 1, 3, 5, 7, 9, 11 -> Tech.INNER_SPHERE;
      default -> null;
    };
  }

  /** MegaMek's vehicle engine rating: cruise MP x tonnage - suspension factor, at least 10, up to a multiple of 5. */
  static int engineRating(EngineType engine, int cruiseMp, double tonnage, MotiveSystem motive) {
    if(cruiseMp == 0) {
      return engine == EngineType.NONE ? 0 : 10;
    }
    int rating = Math.max(10, cruiseMp * (int) tonnage - suspensionFactor(motive, tonnage));
    return rating % 5 == 0 ? rating : rating + 5 - rating % 5;
  }

  /** MegaMek's Tank.getSuspensionFactor. */
  static int suspensionFactor(MotiveSystem motive, double weight) {
    if(motive == null) {
      return 0;
    }
    switch (motive) {
      case Hover:
        if(weight <= 10) return 40;
        if(weight <= 20) return 85;
        if(weight <= 30) return 130;
        if(weight <= 40) return 175;
        if(weight <= 50) return 235;
        return 235 + 45 * (int) Math.ceil((weight - 50) / 25f);
      case Hydrofoil:
        if(weight <= 10) return 60;
        if(weight <= 20) return 105;
        if(weight <= 30) return 150;
        if(weight <= 40) return 195;
        if(weight <= 50) return 255;
        if(weight <= 60) return 300;
        if(weight <= 70) return 345;
        if(weight <= 80) return 390;
        if(weight <= 90) return 435;
        return 480;
      case Naval:
      case Submarine:
        if(weight <= 300) return 30;
        int factor = (int) Math.ceil(weight / 10);
        return factor + factor % 5;
      case Wheeled:
        return weight <= 80 ? 20 : 40;
      case VTOL:
        if(weight <= 10) return 50;
        if(weight <= 20) return 95;
        if(weight <= 30) return 140;
        return 140 + 45 * (int) Math.ceil((weight - 30) / 20f);
      case WiGE:
        if(weight <= 15) return 45;
        if(weight <= 30) return 80;
        if(weight <= 45) return 115;
        if(weight <= 80) return 140;
        return 140 + 35 * (int) Math.ceil((weight - 80) / 30f);
      default:
        return 0;
    }
  }

  // "300 XL (Clan) Engine", "300 XL Engine(IS)", "405 Large XXL Engine"
  private static final Pattern MTF_ENGINE = Pattern.compile(
      "(\\d+)\\s+(?:large\\s+)?(.+?)\\s*(?:\\((clan|is)\\))?\\s*engine\\s*(?:\\((clan|is)\\))?", Pattern.CASE_INSENSITIVE);
  // "Ferro-Fibrous(Clan)", "Standard(Inner Sphere)", "Patchwork"
  private static final Pattern MTF_ARMOR = Pattern.compile("(.+?)\\s*(?:\\((.+)\\))?");
  // "IS Endo Steel", "Clan Standard", "Hybrid"
  private static final Pattern MTF_STRUCTURE = Pattern.compile("(?:(is|clan)\\s+)?(.+)", Pattern.CASE_INSENSITIVE);

  /**
   * Engine, armor, structure, gyro and cockpit, plus a LAM's type and a QuadVee's motive. Without a
   * tech in the text, a component has the chassis tech; without a gyro: or cockpit: line, the
   * standard one.
   */
  static void readMtfComponents(Mech mech, Map<String, String> fields, Tech chassisTech,
      ImportProblems.InFile problems) {
    String engine = fields.get("engine");
    Matcher engineMatch = engine == null ? null : MTF_ENGINE.matcher(engine.trim());
    if(engineMatch != null && engineMatch.matches() && EngineType.fromString(engineMatch.group(2)) != null) {
      mech.setEngineRating(Integer.parseInt(engineMatch.group(1)));
      mech.setEngineType(EngineType.fromString(engineMatch.group(2)));
      String tech = engineMatch.group(3) != null ? engineMatch.group(3) : engineMatch.group(4);
      mech.setEngineTech(tech != null ? Tech.fromTechBase(tech) : chassisTech);
    } else {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "engine " + engine);
    }

    String armor = fields.get("armor");
    Matcher armorMatch = armor == null ? null : MTF_ARMOR.matcher(armor.trim());
    if(armorMatch != null && armorMatch.matches() && ArmorType.fromString(armorMatch.group(1)) != null) {
      mech.setArmorType(ArmorType.fromString(armorMatch.group(1)));
      mech.setArmorTech(armorMatch.group(2) != null ? Tech.fromTechBase(armorMatch.group(2)) : chassisTech);
    } else {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "armor " + armor);
    }

    String structure = fields.get("structure");
    Matcher structureMatch = structure == null ? null : MTF_STRUCTURE.matcher(structure.trim());
    if(structureMatch != null && structureMatch.matches() && StructureType.fromString(structureMatch.group(2)) != null) {
      mech.setStructureType(StructureType.fromString(structureMatch.group(2)));
      mech.setStructureTech(structureMatch.group(1) != null ? Tech.fromTechBase(structureMatch.group(1)) : chassisTech);
    } else {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "structure " + structure);
    }

    String gyro = fields.getOrDefault("gyro", GyroType.STANDARD.getText());
    mech.setGyro(GyroType.fromString(gyro));
    if(mech.getGyro() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "gyro " + gyro);
    }
    String cockpit = fields.getOrDefault("cockpit", CockpitType.STANDARD.getText());
    mech.setCockpit(CockpitType.fromString(cockpit));
    if(mech.getCockpit() == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "cockpit " + cockpit);
    }

    if(mech.getLocomotion() == Locomotion.LAM) {
      String lam = fields.getOrDefault("lam", LamType.STANDARD.name());
      mech.setLamType(LamType.fromString(lam));
      if(mech.getLamType() == null) {
        problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "lam " + lam);
      }
    }
    if(mech.getLocomotion() == Locomotion.QUADVEE) {
      // "Track" or "Wheel"
      String motive = String.valueOf(fields.get("motive"));
      mech.setQuadVeeMotive(motive.equalsIgnoreCase("track") ? MotiveSystem.Tracked
          : motive.equalsIgnoreCase("wheel") ? MotiveSystem.Wheeled : null);
      if(mech.getQuadVeeMotive() == null) {
        problems.report(ImportProblems.Kind.UNKNOWN_COMPONENT, "quadvee motive " + motive);
      }
    }
  }

  /** The "key:value" lines before the weapons list, keyed by lowercase key. The first value wins. */
  static Map<String, String> readMtfFields(List<String> lines) {
    Map<String, String> fields = new HashMap<>();
    for(String line : lines) {
      if(line.toLowerCase().startsWith("weapons:")) {
        break;
      }
      int colon = line.indexOf(':');
      if(colon > 0) {
        fields.putIfAbsent(line.substring(0, colon).trim().toLowerCase(), line.substring(colon + 1).trim());
      }
    }
    return fields;
  }

  private static String requiredField(Map<String, String> fields, String key, File filePath) throws IOException {
    String value = fields.get(key);
    if(value == null || value.isEmpty()) {
      throw new IOException(filePath + " has no " + key + ": line");
    }
    return value;
  }

  /**
   * The lines after "Weapons:N", e.g. "Medium Laser, Left Arm" or "Rifle (Cannon, Heavy), Left Torso".
   * Weapon lines don't say IS or Clan; the critical slots do ("CLERMediumLaser"), so a weapon that
   * matches a prefixed slot in its location gets that tech, and anything else the chassis tech.
   */
  static List<UnitEquipment> readMtfWeapons(List<String> lines, File filePath, Tech chassisTech,
      ImportProblems.InFile problems) throws IOException {
    Map<String, List<String>> slots = readMtfSlots(lines);
    List<UnitEquipment> weapons = new LinkedList<>();
    for(int i = 0; i < lines.size(); i++) {
      if(lines.get(i).toLowerCase().startsWith("weapons:")) {
        int count = Integer.parseInt(lines.get(i).substring("weapons:".length()).trim());
        for(int j = 1; j <= count; j++) {
          String line = lines.get(i + j);
          // the name can contain ", " itself, so the location is after the last one
          int split = line.lastIndexOf(", ");
          if(split < 0) {
            throw new IOException(filePath + ": weapon line without a location: " + line);
          }
          String name = line.substring(0, split);
          String location = line.substring(split + 2);
          Tech tech = slotTech(slots.getOrDefault(location.toLowerCase(), List.of()), name);
          Equipment weapon = new Equipment(EquipmentNames.normalize(name), tech != null ? tech : chassisTech);
          weapon.setDisplayName(name);
          weapons.add(new UnitEquipment(weapon, location));
          reportUnknownLocation(location, name, problems);
        }
        return weapons;
      }
    }
    throw new IOException(filePath + " has no weapons: line");
  }

  /**
   * Critical slot names per location, in file order ("left arm" -> ["Shoulder", ..., "CLERMediumLaser"]).
   * The location sections come after the weapons list.
   */
  static Map<String, List<String>> readMtfSlots(List<String> lines) {
    Map<String, List<String>> slots = new LinkedHashMap<>();
    List<String> current = null;
    boolean afterWeapons = false;
    for(String line : lines) {
      String trimmed = line.trim();
      if(trimmed.toLowerCase().startsWith("weapons:")) {
        afterWeapons = true;
      } else if(!afterWeapons) {
        continue;
      } else if(trimmed.isEmpty()) {
        current = null;
      } else if(trimmed.endsWith(":")) {
        current = new LinkedList<>();
        slots.put(trimmed.substring(0, trimmed.length() - 1).toLowerCase(), current);
      } else if(current != null) {
        current.add(trimmed);
      }
    }
    return slots;
  }

  // How a slot is mounted, not what's in it; (T) is turret-mounted
  private static final Pattern SLOT_MOUNTING = Pattern.compile("\\s*\\((omnipod|r|t|armored)\\)", Pattern.CASE_INSENSITIVE);
  // a variable-size item's size, "Cargo:SIZE:1.0", "ISDroneCarrierControlSystem:OMNI:SIZE:6.0"
  private static final Pattern SIZE = Pattern.compile("(:omni)?:size:([0-9.]+)$", Pattern.CASE_INSENSITIVE);

  /** The ":SIZE:n" of a variable-size item, or null. */
  static Double sizeOf(String name) {
    Matcher size = SIZE.matcher(name);
    return size.find() ? Double.valueOf(size.group(2)) : null;
  }

  // Variable-size items whose size is tons. What the size measures depends on the item (MegaMek's
  // MiscType.sizeSuffix): jump MP for a jump booster, drones for a drone carrier, theaters for MASH,
  // meters for a ladder.
  /** The vehicle equipment sections read, in order, and where their items are. */
  private static final Map<String, Location> VEHICLE_SECTIONS = new LinkedHashMap<>();
  static {
    VEHICLE_SECTIONS.put("front equipment", Location.FRONT);
    VEHICLE_SECTIONS.put("right equipment", Location.RIGHT);
    VEHICLE_SECTIONS.put("left equipment", Location.LEFT);
    VEHICLE_SECTIONS.put("rear equipment", Location.REAR);
    VEHICLE_SECTIONS.put("body equipment", Location.BODY);
    // a single turret is the front turret; with two there's a rear turret too
    VEHICLE_SECTIONS.put("turret equipment", Location.FRONTTURRET);
    VEHICLE_SECTIONS.put("front turret equipment", Location.FRONTTURRET);
    VEHICLE_SECTIONS.put("rear turret equipment", Location.REARTURRET);
    // superheavy tanks have two sections a side
    VEHICLE_SECTIONS.put("front left equipment", Location.FRONT_LEFT);
    VEHICLE_SECTIONS.put("front right equipment", Location.FRONT_RIGHT);
    VEHICLE_SECTIONS.put("rear left equipment", Location.REAR_LEFT);
    VEHICLE_SECTIONS.put("rear right equipment", Location.REAR_RIGHT);
    // VTOL mast mounts
    VEHICLE_SECTIONS.put("rotor equipment", Location.ROTOR);
    // equipment that takes no slot, like CASE; on the body
    VEHICLE_SECTIONS.put("slotless_equipment", Location.BODY);
  }

  private static final Set<String> SIZED_IN_TONS =Set.of("cargo", "liquidstorage", "communicationsequipment");

  /** Stores a variable size where it belongs: tons in tonnage, a jump booster's MP in jumpBoost. */
  static void setSize(UnitEquipment item, String name, Double size, ImportProblems.InFile problems) {
    if(size == null) {
      return;
    }
    String comparable = comparable(name);
    if(SIZED_IN_TONS.contains(comparable)) {
      item.setTonnage(size);
    } else if(comparable.equals("mechanicaljumpbooster")) {
      item.setJumpBoost(size.intValue());
    } else {
      // drones, MASH theaters, ladder meters and support-vehicle infantry weapons aren't kept yet (bug 24)
      problems.report(ImportProblems.Kind.SIZE_NOT_KEPT, name + " size " + size);
    }
  }

  /**
   * A slot name split into its IS/Clan prefix (null if none), the rest, and the size of a
   * variable-size item (null if it isn't one).
   */
  record SlotName(Tech tech, String name, Double size) {
    static SlotName of(String slot) {
      // a slot holding two half tons of ammo lists both, "CLRotaryAC5 Ammo|CLRotaryAC5 Ammo (OMNIPOD)"
      String first = slot.split("\\|")[0];
      Double size = sizeOf(first);
      String cleaned = SIZE.matcher(SLOT_MOUNTING.matcher(first).replaceAll("")).replaceAll("").trim();
      // "Clan Gauss Ammo" and "ClanImprovedLRM20Ammo"
      if(cleaned.startsWith("Clan")) {
        return new SlotName(Tech.CLAN, cleaned.substring(4).strip(), size);
      } else if(cleaned.startsWith("CL")) {
        return new SlotName(Tech.CLAN, cleaned.substring(2), size);
      } else if(cleaned.startsWith("IS")) {
        return new SlotName(Tech.INNER_SPHERE, cleaned.substring(2), size);
      }
      return new SlotName(null, cleaned, size);
    }
  }

  /** The tech of a slot naming this weapon with an IS/Clan prefix, or null if there isn't one. */
  static Tech slotTech(List<String> slots, String weapon) {
    String wanted = comparable(weapon);
    for(String slot : slots) {
      SlotName name = SlotName.of(slot);
      if(name.tech() != null && comparable(name.name()).equals(wanted)) {
        return name.tech();
      }
    }
    return null;
  }

  /*
   * Equipment that only shows up in the critical slots, not the weapons list (by comparable name).
   * An allow-list because slots also repeat every weapon, often under a different name than the
   * weapons list uses ("LBXAC10" for "LB 10-X AC", "Autocannon/20" for "AC/20"), and there's no way
   * to tell those apart from equipment without MegaMek's equipment tables. C3 master computers are
   * left out because some mechs also list them as weapons.
   */
  private static final Pattern SLOT_EQUIPMENT = Pattern.compile("^(targetingcomputer|case|caseii"
      + "|(industrial)?triplestrengthmyomer|masc|supercharger|.*ecmsuite|.*activeprobe"
      + "|c3iunit|c3slaveunit|c3boostedsystemslaveunit|hatchet|sword|claw|mace|chainsaw|retractableblade"
      + "|aes|.*nullsignaturesystem|chameleonlightpolarizationshield|partialwing|umu|antipersonnelpod"
      + "|coolantpod|ppccapacitor|searchlight|environmentalsealing.*|lifthoistarrestinghoist"
      // physical and industrial
      + "|lance|talons|spikes|(small|medium|large)vibroblade|chainwhip|flail|ramplate|wreckingball"
      + "|rockcutter|dualsaw|miningdrill|(heavyduty)?piledriver|salvagearm|backhoe|combine|spotwelder"
      + "|mechsprayer|mediumbridgelayer|(small|medium|large)shield"
      // electronics and defensive systems
      + "|mekvoidsignaturesystem|radicalheatsinksystem|harjel.*|supercooledmyomer|novacews"
      + "|c3emergencymaster|c3sensors|collapsiblecommandmodule|droneoperatingsystem"
      + "|remotedronecommandconsole|remotesensordispenser|electronicwarfareequipment|mass"
      + "|vehicularminedispenser|blueshieldparticlefielddamper|laserinsulator|chaffpod"
      // not the RISC hyper laser or point defense system, which are weapons
      + "|riscviraljammer.*|risclaserpulsemodule|riscemergencycoolantsystem"
      + "|boobytrap|bombbay|mechanicaljumpbooster|communicationsequipment|groundmobilehpg"
      + "|paramedicequipment|reconcamera)$");

  /**
   * Artemis / Apollo slots upgrade a launcher instead of being equipment of their own. MegaMek puts
   * them right after their launcher's slots, so each one goes on that launcher, or else on the first
   * launcher in the same location it fits that doesn't have one yet.
   */
  static void attachMtfFireControl(List<UnitEquipment> weapons, Map<String, List<String>> slots,
      ImportProblems.InFile problems) {
    slots.forEach((location, names) -> {
      Location here = Location.fromString(location);
      List<UnitEquipment> launchers = weapons.stream().filter(weapon -> weapon.getLocation() == here).toList();
      String previous = null;
      FireControl lastFireControl = null;
      int run = 0;
      for(String slot : names) {
        String name = SlotName.of(slot).name();
        FireControl fireControl = FireControl.fromEquipmentName(name);
        if(fireControl == null) {
          previous = name;
          lastFireControl = null;
          continue;
        }
        // a multi-slot system (Artemis V) repeats once per slot; only its first slot counts
        run = fireControl == lastFireControl ? run + 1 : 0;
        lastFireControl = fireControl;
        if(run % fireControl.getSlots() == 0 && !attachFireControl(fireControl, launchers, previous)) {
          problems.report(ImportProblems.Kind.FIRE_CONTROL_WITHOUT_LAUNCHER, slot + " in " + location);
        }
      }
    });
  }

  /** Puts the fire control on the launcher named `previous`, or else the first one it fits. */
  private static boolean attachFireControl(FireControl fireControl, List<UnitEquipment> launchers, String previous) {
    UnitEquipment target = null;
    for(UnitEquipment launcher : launchers) {
      String name = launcher.getEquipment().getName();
      if(launcher.getFireControl() == null && fireControl.fits(name)) {
        if(previous != null && comparable(previous).equals(comparable(name))) {
          target = launcher;
          break;
        }
        if(target == null) {
          target = launcher;
        }
      }
    }
    if(target != null) {
      target.setFireControl(fireControl);
    }
    return target != null;
  }

  // Equipment counted by how many slots one takes (jump jets: one per jump MP)
  private static final Map<String, Integer> SLOTS_PER_ITEM = Map.of(
      "jumpjet", 1, "prototypejumpjet", 1, "improvedjumpjet", 2, "prototypeimprovedjumpjet", 2);

  /**
   * Ammo and equipment from the critical slots. Each ammo slot is one ton, so ammo is counted per
   * slot; jump jets by their slot size. Other equipment can span several slots and locations, so
   * each item is counted once per mech.
   */
  /** A location name the reader has no Location for; the item is saved without one. */
  private static void reportUnknownLocation(String location, String item, ImportProblems.InFile problems) {
    if(Location.fromString(location) == null) {
      problems.report(ImportProblems.Kind.UNKNOWN_LOCATION, item + " in " + location);
    }
  }

  static List<UnitEquipment> readMtfSlotEquipment(Map<String, List<String>> slots, Tech chassisTech,
      ImportProblems.InFile problems) {
    List<UnitEquipment> equipment = new LinkedList<>();
    Set<String> seen = new HashSet<>();
    // multi-slot jump jets can be split across locations, so count slots per mech
    Map<String, Integer> slotCounts = new LinkedHashMap<>();
    Map<String, SlotName> countedNames = new HashMap<>();
    Map<String, String> countedLocations = new HashMap<>();
    slots.forEach((location, names) -> {
      for(String slot : names) {
        SlotName name = SlotName.of(slot);
        Tech tech = name.tech() != null ? name.tech() : chassisTech;
        String comparable = comparable(name.name());
        if(SLOTS_PER_ITEM.containsKey(comparable)) {
          slotCounts.merge(comparable, 1, Integer::sum);
          countedNames.putIfAbsent(comparable, name);
          countedLocations.putIfAbsent(comparable, location);
        } else if(comparable.contains("ammo") || isNarcPods(comparable)
            // a variable-size item repeats its size in every slot; two of different sizes are two items
            || (SLOT_EQUIPMENT.matcher(comparable).matches() && seen.add(comparable + ":" + name.size()))) {
          UnitEquipment item = new UnitEquipment(slotEquipment(name, tech), location);
          setSize(item, name.name(), name.size(), problems);
          equipment.add(item);
          reportUnknownLocation(location, name.name(), problems);
        }
      }
    });
    slotCounts.forEach((comparable, count) -> {
      SlotName name = countedNames.get(comparable);
      Tech tech = name.tech() != null ? name.tech() : chassisTech;
      for(int i = 0; i < count / SLOTS_PER_ITEM.get(comparable); i++) {
        // recorded at the first location it's in
        equipment.add(new UnitEquipment(slotEquipment(name, tech), countedLocations.get(comparable)));
        reportUnknownLocation(countedLocations.get(comparable), name.name(), problems);
      }
    });
    return equipment;
  }

  // the slot's name normalized, and as written for the display name (UnitService)
  private static Equipment slotEquipment(SlotName name, Tech tech) {
    Equipment equipment = new Equipment(EquipmentNames.normalize(name.name()), tech);
    equipment.setDisplayName(name.name());
    return equipment;
  }

  // Narc launcher ammo: "Narc Pods", "iNarc Pods", "iNarc Explosive Pods"
  private static boolean isNarcPods(String comparable) {
    return comparable.contains("narc") && comparable.endsWith("pods");
  }

  // "Ultra AC/10" and "CLUltraAC10" both become "ultraac10"
  private static String comparable(String name) {
    return name.toLowerCase().replaceAll("[^a-z0-9]", "");
  }

  private static String first(Map<String, List<String>> values, String key) {
    List<String> list = values.get(key);
    return list == null || list.isEmpty() ? null : list.get(0);
  }

  static UUID parseUuid(String value, ImportProblems.InFile problems) {
    if(value == null || value.isBlank()) {
      return null;
    }
    try {
      return UUID.fromString(value.trim());
    } catch (IllegalArgumentException e) {
      problems.report(ImportProblems.Kind.INVALID_UUID, value);
      return null;
    }
  }

  // MegaMek writes -1 when a unit isn't in the Master Unit List
  static Integer parseMulId(String value) {
    if(value == null || value.isBlank()) {
      return null;
    }
    int mulId = Integer.parseInt(value.trim());
    return mulId > 0 ? mulId : null;
  }
}
