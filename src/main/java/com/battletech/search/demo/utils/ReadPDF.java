package com.battletech.search.demo.utils;

import com.battletech.search.demo.model.Location;
import com.battletech.search.demo.model.Mech;
import com.battletech.search.demo.model.Unit;
import java.io.File;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.pdfbox.text.PDFTextStripperByArea;

public class ReadPDF {

  public void readPDF() {
    try  {
      //PDDocument document = PDDocument.load(new File("/Users/adam9500/Downloads/TrebuchetTBT-5N.pdf"));
      PDDocument document = PDDocument.load(new File("/Users/adam9500/Downloads/BC210_RS3075Unabridged.pdf"));
      //document.getClass();

      if (!document.isEncrypted()) {

        PDFTextStripperByArea stripper = new PDFTextStripperByArea();
        stripper.setSortByPosition(true);

        PDFTextStripper tStripper = new PDFTextStripper();
        int documentPages = document.getNumberOfPages();
        for(int i = 0; i < documentPages; i++) {
          if(i > 6) {
            tStripper.setStartPage(i);
            tStripper.setEndPage(i);
            String pdfFileInText = tStripper.getText(document);
            //System.out.println("Text:" + st);

            // split by whitespace
            String lines[] = pdfFileInText.split("\\r?\\n");

            convertToUnit(lines);
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
    boolean readEquipment = true;
    for(int i = 0; i < pdfInput.length; i++) {
      if(i == 1) {
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

