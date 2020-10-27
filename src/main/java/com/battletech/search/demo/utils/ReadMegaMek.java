package com.battletech.search.demo.utils;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.MechEquipment;
import com.battletech.search.demo.model.Locomotion;
import com.battletech.search.demo.entities.Mech;
import com.battletech.search.demo.model.Movement;
import com.battletech.search.demo.model.Tech;
import com.battletech.search.demo.entities.Unit;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

public class ReadMegaMek {

  public static Unit ReadMTF(File filePath) throws IOException {

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
    mech.setTech(Tech.fromString(techBase));

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

  static List<MechEquipment> getWeapons(int numWeapons, BufferedReader reader) throws IOException {
    List<MechEquipment> list = new LinkedList();

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
          list.add(new MechEquipment(new Equipment(equipmentName.toString()), equipment[1]));
        }
      } catch(NumberFormatException e) {
        list.add(new MechEquipment(new Equipment(equipment[0]), equipment[1]));
      }


    }

    return list;
  }

}
