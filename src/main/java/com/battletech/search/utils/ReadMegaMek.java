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
    vee.setName(value.get("name").get(0));
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
      List<UnitEquipment> frontEquip = convertToEquipment(value.get("front equipment"),
          Location.FRONT);
      vee.setMechEquipment(frontEquip);
    }
    if(value.get("right equipment") != null) {
      vee.setMechEquipment(convertToEquipment(
          value.get("right equipment"),
          Location.RIGHT));
    }
    if(value.get("left equipment") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("left equipment"), Location.LEFT));
    }
    if(value.get("rear equipment") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("rear equipment"), Location.REAR));
    }
    if(value.get("body") != null) {
      vee.setMechEquipment(convertToEquipment(value.get("body equipment"), Location.BODY));
    }
    if(value.get("rear turret equipment") != null) {
      if(value.get("front turret equipment") != null) {
        vee.setMechEquipment(
            convertToEquipment(value.get("front turret equipment"), Location.FRONTTURRET));
      }
      vee.setMechEquipment(
          convertToEquipment(value.get("rear turret equipment"), Location.REARTURRET));
    }else {
      if(value.get("turret equipment") != null) {
        vee.setMechEquipment(
            convertToEquipment(value.get("turret equipment"), Location.FRONTTURRET));
      }
    }

    if(value.get("transporters") != null && !value.get("transporters").get(0).isEmpty()){
      Equipment equip = new Equipment("infantry bay");
      equip.setTonnage(0.5);
      UnitEquipment infantryBay = new UnitEquipment();
      infantryBay.setEquipment(equip);
      infantryBay.setLocation(Location.BODY);
      infantryBay.setTonnage(Double.parseDouble(value.get("transporters").get(0).split(":")[1]));
      vee.setMechEquipment(Collections.singletonList(infantryBay));
    }


    String techType = value.get("type").get(0); // tells us whether its IS, Clan or Mixed Tech
    if(techType.contains("is")) {
      vee.setTech(Tech.INNER_SPHERE);
    }else if(techType.contains("cl")) {
      vee.setTech(Tech.CLAN);
    }else if(techType.contains("mixed tech")) {
      vee.setTech(Tech.MIXED_TECH);
    }
    //value.get("fueltype").get(0);
    /*
    String unitType = readBlkParameter("UnitType", reader).get(0);
    String name = readBlkParameter("Name", reader).get(0);
    String model = readBlkParameter("Model", reader).get(0);
    String tonnage = readBlkParameter("Tonnage", reader).get(0);
    String cruiseMp = readBlkParameter("cruiseMP", reader).get(0);
    List<String> armor = readBlkParameter("armor", reader);

    List<String> frontEquipment = readBlkParameter("Front Equipment", reader);
    List<String> rightEquipment = readBlkParameter("Right Equipment", reader);
    List<String> leftEquipment = readBlkParameter("Left Equipment", reader);
    List<String> rearEquipment = readBlkParameter("Rear Equipment", reader);
    List<String> bodyEquipment = readBlkParameter("Body Equipment", reader);
    List<String> rearTurretEquipment = readBlkParameter("Rear Turret Equipment", reader);
    List<String> frontTurretEquipment = readBlkParameter("Front Turret Equipment", reader);

    String type = readBlkParameter("type", reader).get(0);
  */

    return vee;
  }

  static List<String> readBlkParameter(String paramName, BufferedReader reader) throws IOException {
    boolean loop = true;
    List<String> returnList = new LinkedList();
    while(loop) {
      String temp = reader.readLine();
      if(!temp.isEmpty()) {
        if (temp.equalsIgnoreCase("<"+paramName+">")) {
          returnList.add(reader.readLine());
        } else if(temp.equalsIgnoreCase("</"+paramName+">")) {
          loop = false;
        }
      }
    }
    return returnList;
  }

  static List<UnitEquipment> convertToEquipment(List<String> equipment, Location location) {
    List<UnitEquipment> returnEquipment = new LinkedList<UnitEquipment>();
    for(String equip: equipment) {
      UnitEquipment value = new UnitEquipment();
      value.setEquipment(new Equipment());
      value.setLocation(location);
      equip.toLowerCase().replaceAll("\\s", "");
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
        value.getEquipment().setName(equip);
      }
      returnEquipment.add(value);
    }

    return returnEquipment;
  }

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
          String value = temp.substring(open + 1, temp.indexOf("</")).trim().toLowerCase();
          List<String> values = new LinkedList<>();
          if(!value.isEmpty()) {
            values.add(value);
          }
          parameters.put(temp.substring(1, open).toLowerCase(), values);
        } else if (temp.startsWith("<")) {
          paramName = temp.substring(1, temp.length()-1).toLowerCase();
        }else {
          if(!temp.startsWith("#")) {
            parameterList.add(temp.toLowerCase());
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
    if(designation.isEmpty()) {
      mech.setDesignation(name + " prime");// or is it base?
    }else {
      mech.setDesignation(designation);
    }
    // e.g. "Biped", "Biped OmniMek", "Quad"
    mech.setLocomotion(Locomotion.fromString(requiredField(fields, "config", filePath).split(" ")[0]));
    mech.setTech(Tech.fromString(requiredField(fields, "techbase", filePath))); // Mixed (IS Chassis) isn't mapped yet
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

    mech.setMechEquipment(readMtfWeapons(lines, filePath));
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

  /** The lines after "Weapons:N", e.g. "Medium Laser, Left Arm" or "Rifle (Cannon, Heavy), Left Torso". */
  static List<UnitEquipment> readMtfWeapons(List<String> lines, File filePath) throws IOException {
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
          String weapon = line.substring(0, split).toLowerCase().replaceAll("\s", "");
          // weapon lines don't say IS or Clan; persistUnits falls back to the unit's tech
          weapons.add(new UnitEquipment(new Equipment(weapon, null), line.substring(split + 2)));
        }
        return weapons;
      }
    }
    throw new IOException(filePath + " has no weapons: line");
  }
}
