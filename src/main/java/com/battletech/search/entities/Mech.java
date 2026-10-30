package com.battletech.search.entities;

import com.battletech.search.model.CockpitType;
import com.battletech.search.model.GyroType;
import com.battletech.search.model.Heatsinks;
import com.battletech.search.model.Heatsinks.HeatsinkType;
import com.battletech.search.model.LamType;
import com.battletech.search.model.Locomotion;
import com.battletech.search.model.MotiveSystem;
import com.battletech.search.model.Movement;
import com.battletech.search.model.Tech;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Data;

@Entity
@Data
public class Mech extends Unit {
  @Enumerated(EnumType.STRING)
  Locomotion locomotion;
  @Enumerated(EnumType.STRING)
  GyroType gyro;
  @Enumerated(EnumType.STRING)
  CockpitType cockpit;
  // LAMs only
  @Enumerated(EnumType.STRING)
  LamType lamType;
  // QuadVees only: Tracked or Wheeled in vehicle mode
  @Enumerated(EnumType.STRING)
  MotiveSystem quadVeeMotive;
  String myomer;
  String ejection;

  @Embedded
  Heatsinks heatsinks;

  public Mech() {
    this.setMovement(new Movement());
  }

  // e.g. "20 Single", "20 IS Double", "17 Clan Double", "10 Laser"
  public void setHeatsinks(String heatsinkInput) {
    Heatsinks heatsinks = new Heatsinks();
    String[] split = heatsinkInput.trim().split(" ");
    heatsinks.setHeatsinkQuantity(Integer.parseInt(split[0]));
    heatsinks.setType(HeatsinkType.fromString(split[split.length - 1]));
    // the IS/Clan word, when there is one, beats the mech's tech (mixed tech mechs)
    Tech techType = split.length > 2 ? Tech.fromTechBase(split[1]) : null;
    heatsinks.setTechType(techType != null ? techType : this.tech);
    this.heatsinks = heatsinks;
  }

  /*public void setArmor(String armorType, int totalArmor) {
    MechEquipment mechEquipment = new MechEquipment();
    mechEquipment.setEquipment(new Equipment(armorType));
    //we need a utility function to convert totalArmor to tonnage
    mechEquipment.setTonnage(totalArmor);
  }*/
}
