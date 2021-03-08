package com.battletech.search.demo.utils;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.model.Location;
import com.battletech.search.demo.entities.Mech;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.model.Movement;
import com.battletech.search.demo.model.Tech;
import java.io.File;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.pdfbox.text.PDFTextStripperByArea;

public class ReadPDF {

  public void readPDF() {
    try  {
      //PDDocument document = PDDocument.load(new File("/Users/adam9500/Downloads/TrebuchetTBT-5N.pdf"));
      PDDocument document = PDDocument.load(new File("/Users/adam9500/Downloads/Recognition_Guide_7.pdf"));
      //document.getClass();

      if (!document.isEncrypted()) {

        PDFTextStripperByArea stripper = new PDFTextStripperByArea();
        stripper.setSortByPosition(true);

        PDFTextStripper tStripper = new PDFTextStripper();
        int documentPages = document.getNumberOfPages();
        for(int i = 0; i < documentPages; i++) {
          if(i > 14) {
            tStripper.setStartPage(i);
            tStripper.setEndPage(i);
            String pdfFileInText = tStripper.getText(document);
            //System.out.println("Text:" + st);

            // split by whitespace
            String lines[] = pdfFileInText.split("\\r?\\n");

            try {
              convertToUnit(lines);
            }catch(Exception e) {
              System.out.println("Failed to convert into unit");
            }
          }
        }
        //for (String line : lines) {
        //  System.out.println(line);
        //}
      } else {
        System.out.println("The file is encrypted");
      }

    } catch(Exception e) {
      System.out.println(e);
    }

  }

  private void convertToUnit(String[] pdfInput) {
    Unit newUnit = new Mech();
    Movement move = new Movement();
    boolean readEquipment = true;
    for(int i = 0; i < pdfInput.length; i++) {
      if(pdfInput[i].contains("Type:")) {
        newUnit.setName(pdfInput[i].split(":")[1]);
      }else if(pdfInput[i].contains("Walking:")) {
        move.setWalk(Integer.parseInt(pdfInput[i].split(":")[1])); // actually need to parse this to also get potential walk
      }else if(pdfInput[i].contains("Running:")) {
        move.setRun(Integer.parseInt(pdfInput[i].split(":")[1]));
      }else if(pdfInput[i].contains("Jumping:")) {
        move.setJump(Integer.parseInt(pdfInput[i].split(":")[1]));
      }else if(pdfInput[i].contains("Tonnage:")) {
        newUnit.setWeight(Integer.parseInt(pdfInput[i].split(":")[1]));
      }else if(pdfInput[i].contains("TechBase:")) {
        newUnit.setTech(Tech.fromString(pdfInput[i].split(":")[1]));
      }else if(pdfInput[i].contains("Rules Level:")) {
        // not yet used
      }else if(pdfInput[i].contains("Role:")) {
        // not used yet
      }else if(pdfInput[i].contains("BV:")) {
        Integer.parseInt(pdfInput[i].split(":")[1]);
      }else if(pdfInput[i].contains("Qty Type Loc Ht Dmg Min Sht Med Lng")) {
        i++;
        String[] weapon = pdfInput[i].split(" ");
        int quantity = Integer.parseInt(weapon[0]);
        UnitEquipment unitEquip = new UnitEquipment();
        Equipment equip = new Equipment();
        equip.setName(weapon[1]);
        unitEquip.setEquipment(equip); // iterate through
        unitEquip.setLocation(Location.fromString(""));
        //equip.setHeat();
        //equip.setDamage();
        //equip.setMinRange();
        //equip.setShortRange();
        //equip.setMediumRange();
        //equip.setLongRange();
        // loop through
        pdfInput[i].contains("Ammo:");
      }else if(pdfInput[i].contains("ARMOR DIAGRAM")) {
        // continue parsing lines till you hit ( num ) there will be 9 lines of that.
        // Head
        // center torso
        // center torso (rear)
        // right torso ? I think this is correct
        // right torso (rear)?
        // left torso
        // left torso rear
        // both arms
        // both legs
      }else if(pdfInput[i].contains("Head")) {

      }else if(pdfInput[i].contains("Center Torso")) {

      }else if(pdfInput[i].contains("Right Torso")) {

      }else if(pdfInput[i].contains("Left Torso")) {

      }else if(pdfInput[i].contains("Right Arm")) {

      }else if(pdfInput[i].contains("Left Arm")) {

      }else if(pdfInput[i].contains("Right Leg")) {

      }else if(pdfInput[i].contains("Left Leg")) {

      }else if(pdfInput[i].contains("INTERNAL STRUCTURE DIAGRAM")) {
        // should be similar parsing as for armor. Note no head structure is listed since its always 3.
        // Center torso
        // both side torsos
        // both arms
        // both legs
      }else if(pdfInput[i].contains("Heat Sinks:")) {

      }


      ;
      ;
      ;
      ;
      ;// indicates the start of the equipment section
       // this should be done as part of the weapons section
      ;
      // for the following portion there might be a (CASE) to the right of the location for clan mechs
      ; // start of equipment in the head
      ;
      ;
      ;
      ;
      ;
      ;
      ;

      ;

      ;


      if(i == 0) {
        // dont do anything // althought we might pull that it is an omnimech
      }else if(i == 1) {
        newUnit.setName(pdfInput[i]);
      }else if (i == 2) {
        newUnit.setWeight(Integer.parseInt(pdfInput[i]));
      }else if (i == 3) {
        //newUnit.setTechLevel(pdfInput[i])
      }else if (i == 4) {
        //rule level
      }else if (i == 5) {
        newUnit.setEra(pdfInput[i]);
      }else if (i == 6) {
        newUnit.getMovement().setWalk(Integer.parseInt(pdfInput[i]));
      }else if (i == 7) {
        newUnit.getMovement().setRun(Integer.parseInt(pdfInput[i]));
      }else if (i == 8) {
        newUnit.getMovement().setJump(Integer.parseInt(pdfInput[i]));
      }else {
        if(pdfInput[i].contains("Cost")) {
          readEquipment = false;
        }
        if(readEquipment) {
          parseEquipment(pdfInput[i]);
        }else {
          //armor and then equipment locations
        }
      }
    }
    newUnit.setMovement(move);

    System.out.println("newUnit: "+newUnit);
  }



  public void parseEquipment(String input) {
    String[] equipmentParse = input.split(" ");
    int quantity;
    String name = "";
    Location location;
    String damage;
    int minimumRange;
    int shortRange;
    int mediumRange;
    int longRange;
    for(int i = 0; i < equipmentParse.length; i++) {
      if(i == 0) {
        quantity = Integer.parseInt(equipmentParse[i]);
      }else {//if() {
        name = equipmentParse[i];
      }
    }
  }
}

