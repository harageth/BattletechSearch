package com.battletech.search.demo.utils;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.Tank;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.entities.Vehicle;
import com.battletech.search.demo.entities.Vtol;
import com.battletech.search.demo.model.Location;
import com.battletech.search.demo.model.Locomotion;
import com.battletech.search.demo.entities.Mech;
import com.battletech.search.demo.model.Movement;
import com.battletech.search.demo.model.Tech;
import com.battletech.search.demo.entities.Unit;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

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
      System.out.println("Don't support unit type: " + type);
      System.out.println("Unable to import: " + value.get("Name").get(0));
      return null;
    }
    vee.setName(value.get("name").get(0));
    vee.setDesignation(value.get("model").get(0));
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
          //loop = false;
          parameters.put(paramName, parameterList);
          parameterList = new LinkedList();
        } else if (temp.startsWith("<")) {
          paramName = temp.substring(1, temp.length()-1).toLowerCase();
          // returnList.add(reader.readLine());
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

  public static Unit ReadMechMTF(File filePath) throws IOException {

    Mech mech = new Mech();
    BufferedReader reader = new BufferedReader(new FileReader(filePath));
    String version = reader.readLine();
    String name = reader.readLine();
    String designation = reader.readLine();
    mech.setName(name);
    if(designation.isEmpty()) {
      mech.setDesignation(name + " prime");// or is it base?
    }else {
      mech.setDesignation(designation);
    }
    String[] config = readParameter("config:", reader).split(" ");

    mech.setLocomotion(Locomotion.fromString(config[0]));
    String techBase = readParameter("techbase:", reader);
    mech.setTech(Tech.fromString(techBase)); // (IS Chassis) or (Clan Chassis)

    String era = readParameter("era:", reader);
    mech.setEra(era);
    String rulesLevel = readParameter("rules level:", reader);
    mech.setRulesLevel(Integer.parseInt(rulesLevel));
    String mass = readParameter("mass:", reader);
    mech.setWeight(Integer.parseInt(mass));
    String engine = readParameter("engine:", reader);
    mech.setEngine(engine);
    String structure = readParameter("structure:", reader);
    mech.setStructure(structure);
    String myomer = readParameter("myomer:", reader);
    mech.setMyomer(myomer);
    //mech.setEjection(readParameter("ejection:", reader));


    String heatsinks = readParameter("heat sinks:", reader);
    mech.setHeatsinks(heatsinks);
    String walkMP = readParameter("walk mp:", reader);
    Movement move = new Movement();
    move.setWalk(Integer.parseInt(walkMP));
    String jumpMP = readParameter("jump mp:", reader);
    move.setJump(Integer.parseInt(jumpMP));
    mech.setMovement(move);

    // armor is supposed to be a piece of equipment
    String armorType = readParameter("armor:", reader);
    int totalArmor = getTotalArmor(reader);
    //gonna ignore armor for a moment
    //mech.setArmor(armorType, totalArmor);

    int numWeapons = Integer.parseInt(readParameter("weapons:", reader));
    mech.setMechEquipment(getWeapons(numWeapons, reader));

    // save off the mech

    /*
    name
    config: biped/quad
    techbase:
    era:
    source: IGNORE
    Rules level:

    Mass:
    engine:
    structure
    myomer
    ejection

    heat sinks
    walk mp
    jump mp

    armor:
    LA armor:15
    RA armor:20
    LT armor:23
    RT armor:23
    CT armor:31
    HD armor:9
    LL armor:28
    RL armor:28
    RTL armor:7
    RTR armor:7
    RTC armor:10

    weapons: #
    weapon, location
    .
    .
    .

    Left Arm:
    all slots

    Right arm:
    all slots

    Left Torso:
    all slots

    Right Torso:
    all slots

    center torso:
    all slots

    head:
    all slots

    Left leg:
    all slots

    right leg:
    all slots


    manufacturers
     */






    reader.close();

    return mech;
  }

  static String readParameter(String paramName, BufferedReader reader) throws IOException {
    while(true) {
      String parameter = reader.readLine();
      if(!parameter.isEmpty()) {
        if(parameter.toLowerCase().startsWith(paramName)) { // probably replace these with regex's
          return parameter.substring(paramName.length());
        }
      }
    }
  }

  static int getTotalArmor(BufferedReader reader) throws IOException {
    int totalArmor = 0;
    while(true) {
      String line = reader.readLine();
      if(!line.isEmpty()) {
        String[]items = line.split(":");
        totalArmor = totalArmor + Integer.parseInt(items[1]);
      }else {
        break;
      }
    }
    return totalArmor;
  }

  static List<UnitEquipment> getWeapons(int numWeapons, BufferedReader reader) throws IOException {
    List<UnitEquipment> list = new LinkedList();

    for(int i = 0; i < numWeapons; i++) {
      String[] equipment = reader.readLine().split(", ");
      try {
        String[] quantityTest = equipment[0].split(" ");
        StringBuilder equipmentName = new StringBuilder();
        int quantity = Integer.parseInt(quantityTest[0]);
        for(int j = 1; j < quantityTest.length; j++) {
          equipmentName.append(quantityTest[j]);
        }
        for(int j = 0; j < quantity; j++) {
          Tech tech = getTechType(equipmentName.toString().toLowerCase().replaceAll("\\s", ""));
          if(tech != null) {
            equipmentName.replace(0, 2, "");
          }
          list.add(new UnitEquipment(new Equipment(equipmentName.toString().toLowerCase().replaceAll("\\s", ""), tech), equipment[1]));
        }
      } catch(NumberFormatException e) {
        Tech tech = getTechType(equipment[0]);
        if(tech != null) {
          equipment[0] = equipment[0].substring(2);
        }
        list.add(new UnitEquipment(new Equipment(equipment[0].toLowerCase().replaceAll("\\s", ""), getTechType(equipment[0])), equipment[1]));
      }
    }
    return list;
  }

  public static Tech getTechType(String equipment) {
    if(equipment.startsWith("IS")) {
      return Tech.INNER_SPHERE;

    }else if(equipment.startsWith("CL")) {
      return Tech.CLAN;
    }

    return null;
  }
}
