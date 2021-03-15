package com.battletech.search.entities;

import com.battletech.search.model.Heatsinks;
import com.battletech.search.model.Heatsinks.HeatsinkType;
import com.battletech.search.model.Locomotion;
import com.battletech.search.model.Movement;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import lombok.Data;

@Entity
@Data
public class Mech extends Unit {
  @Enumerated(EnumType.STRING)
  Locomotion locomotion;
  String engine;
  String structure;
  String myomer;
  String ejection;

  @Embedded
  Heatsinks heatsinks;

  public Mech() {
    this.setMovement(new Movement());
  }

  public void setHeatsinks(String heatsinkInput) {
    Heatsinks heatsinks = new Heatsinks();
    heatsinks.setTechType(this.tech);
    String[] split = heatsinkInput.split(" ");
    heatsinks.setHeatsinkQuantity(Integer.parseInt(split[0]));
    heatsinks.setType(HeatsinkType.fromString(split[1]));
    this.heatsinks = heatsinks;
  }

  /*public void setArmor(String armorType, int totalArmor) {
    MechEquipment mechEquipment = new MechEquipment();
    mechEquipment.setEquipment(new Equipment(armorType));
    //we need a utility function to convert totalArmor to tonnage
    mechEquipment.setTonnage(totalArmor);
  }*/
}
