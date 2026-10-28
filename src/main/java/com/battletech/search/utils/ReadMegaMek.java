package com.battletech.search.utils;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Vehicle;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.Location;
import com.battletech.search.model.Locomotion;
import com.battletech.search.entities.Mech;
import com.battletech.search.model.Movement;
import com.battletech.search.model.Tech;
import com.battletech.search.entities.Unit;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ReadMegaMek {

  public static Unit ReadVehicleBlk(File filePath) throws IOException {
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
      vee = new Tank();
      // not sure exactly how I want to support locomotion type
      value.get("motion_type").get(0);
    } else {
      log.info("Skipping {}: unsupported unit type {}", filePath, type);
      return null;
    }
    // the type tells us whether it's IS, Clan or mixed tech, e.g. "Mixed (Clan Chassis) Experimental"
    String techBase = value.get("type").get(0);
    vee.setTech(Tech.fromTechBase(techBase));
    // equipment without an IS/Clan prefix is the chassis tech
    Tech chassisTech = Tech.chassisTech(techBase);
    vee.setName(value.get("name").get(0));
    vee.setMegamekUuid(parseUuid(first(value, "uuid")));
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
    if (value.get("armor_type") != null) {
      int armorType = Integer.parseInt(value.get("armor_type").get(0));
    } else {
      // in here we set the default of 0
    }
    if (value.get("internal_type") != null) {
      int internal_type = Integer.parseInt(value.get("internal_type").get(0));
    }else {
      // set default internal structure
    }
    if(value.get("front equipment") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("front equipment"), chassisTech, Location.FRONT));
    }
    if(value.get("right equipment") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("right equipment"), chassisTech, Location.RIGHT));
    }
    if(value.get("left equipment") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("left equipment"), chassisTech, Location.LEFT));
    }
    if(value.get("rear equipment") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("rear equipment"), chassisTech, Location.REAR));
    }
    if(value.get("body equipment") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("body equipment"), chassisTech, Location.BODY));
    }
    if(value.get("rear turret equipment") != null) {
      if(value.get("front turret equipment") != null) {
        vee.setMechEquipment(
            convertToEquipment(value.get("front turret equipment"), chassisTech, Location.FRONTTURRET));
      }
      vee.setMechEquipment(
          convertToEquipment(value.get("rear turret equipment"), chassisTech, Location.REARTURRET));
    }else {
      if(value.get("turret equipment") != null) {
        vee.setMechEquipment(
            convertToEquipment(value.get("turret equipment"), chassisTech, Location.FRONTTURRET));
      }
    }

    if(value.get("transporters") != null && !value.get("transporters").get(0).isEmpty()){
      Equipment equip = new Equipment("infantry bay", chassisTech);
      equip.setTonnage(0.5);
      UnitEquipment infantryBay = new UnitEquipment();
      infantryBay.setEquipment(equip);
      infantryBay.setLocation(Location.BODY);
      infantryBay.setTonnage(Double.parseDouble(value.get("transporters").get(0).split(":")[1]));
      vee.setMechEquipment(Collections.singletonList(infantryBay));
    }

    return vee;
  }

  static List<UnitEquipment> convertToEquipment(List<String> equipment, Tech chassisTech, Location location) {
    List<UnitEquipment> returnEquipment = new LinkedList<UnitEquipment>();
    for(String equip: equipment) {
      UnitEquipment value = new UnitEquipment();
      value.setEquipment(new Equipment());
      value.setLocation(location);
      equip = equip.toLowerCase();
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
      returnEquipment.add(value);
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
    List<String> lines;
    try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
      lines = reader.lines().filter(line -> !line.startsWith("#")).toList();
    }
    Map<String, String> fields = readMtfFields(lines);

    Mech mech = new Mech();
    String name = requiredField(fields, "chassis", filePath);
    String designation = fields.getOrDefault("model", "");
    mech.setName(name);
    mech.setMegamekUuid(parseUuid(fields.get("uuid")));
    mech.setMulId(parseMulId(fields.get("mul id")));
    if(designation.isEmpty()) {
      mech.setDesignation(name + " prime");// or is it base?
    }else {
      mech.setDesignation(designation);
    }
    // e.g. "Biped", "Biped OmniMek", "Quad"
    mech.setLocomotion(Locomotion.fromString(requiredField(fields, "config", filePath).split(" ")[0]));
    String techBase = requiredField(fields, "techbase", filePath);
    mech.setTech(Tech.fromTechBase(techBase));
    mech.setEra(fields.get("era")); // now a year, e.g. 2755
    mech.setRulesLevel(Integer.parseInt(requiredField(fields, "rules level", filePath)));
    mech.setWeight(Integer.parseInt(requiredField(fields, "mass", filePath)));
    mech.setEngine(fields.get("engine"));
    mech.setStructure(fields.get("structure"));
    mech.setMyomer(fields.get("myomer"));
    // tech has to be set first; heat sinks copy it
    mech.setHeatsinks(requiredField(fields, "heat sinks", filePath));
    Movement move = new Movement();
    move.setWalk(Integer.parseInt(requiredField(fields, "walk mp", filePath)));
    move.setJump(Integer.parseInt(requiredField(fields, "jump mp", filePath)));
    mech.setMovement(move);
    // armor isn't imported yet

    mech.setMechEquipment(readMtfWeapons(lines, filePath, Tech.chassisTech(techBase)));
    return mech;
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
  static List<UnitEquipment> readMtfWeapons(List<String> lines, File filePath, Tech chassisTech) throws IOException {
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
          String weapon = EquipmentNames.normalize(name);
          weapons.add(new UnitEquipment(new Equipment(weapon, tech != null ? tech : chassisTech), location));
        }
        return weapons;
      }
    }
    throw new IOException(filePath + " has no weapons: line");
  }

  /** Critical slot names per location ("left arm" -> ["Shoulder", ..., "CLERMediumLaser"]). */
  static Map<String, List<String>> readMtfSlots(List<String> lines) {
    Map<String, List<String>> slots = new HashMap<>();
    List<String> current = null;
    for(String line : lines) {
      String trimmed = line.trim();
      if(trimmed.isEmpty()) {
        current = null;
      } else if(trimmed.endsWith(":") && !trimmed.contains(" armor:")) {
        current = new LinkedList<>();
        slots.put(trimmed.substring(0, trimmed.length() - 1).toLowerCase(), current);
      } else if(current != null) {
        current.add(trimmed);
      }
    }
    return slots;
  }

  /** The tech of a slot naming this weapon with an IS/Clan prefix, or null if there isn't one. */
  static Tech slotTech(List<String> slots, String weapon) {
    String wanted = comparable(weapon);
    for(String slot : slots) {
      Tech tech = null;
      String rest = slot;
      if(slot.startsWith("Clan ")) {
        tech = Tech.CLAN;
        rest = slot.substring(5);
      } else if(slot.startsWith("CL")) {
        tech = Tech.CLAN;
        rest = slot.substring(2);
      } else if(slot.startsWith("IS")) {
        tech = Tech.INNER_SPHERE;
        rest = slot.substring(2);
      }
      if(tech != null && comparable(rest).equals(wanted)) {
        return tech;
      }
    }
    return null;
  }

  // "Ultra AC/10" and "CLUltraAC10" both become "ultraac10"
  private static String comparable(String name) {
    return name.toLowerCase().replaceAll("[^a-z0-9]", "");
  }

  private static String first(Map<String, List<String>> values, String key) {
    List<String> list = values.get(key);
    return list == null || list.isEmpty() ? null : list.get(0);
  }

  static UUID parseUuid(String value) {
    if(value == null || value.isBlank()) {
      return null;
    }
    try {
      return UUID.fromString(value.trim());
    } catch (IllegalArgumentException e) {
      log.warn("Ignoring invalid MegaMek uuid {}", value);
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
