package com.battletech.search.demo.entities;

import com.battletech.search.demo.model.Movement;
import com.battletech.search.demo.model.Searchable;
import com.battletech.search.demo.model.Tech;
import com.battletech.search.demo.model.WeightClass;
import java.util.List;
import java.util.UUID;
import javax.persistence.CollectionTable;
import javax.persistence.ElementCollection;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import lombok.Data;

@Entity
@Data
public class Unit implements Searchable {
    @Id
    @GeneratedValue
    UUID id;

    String name;

    String designation;

    @Enumerated(EnumType.STRING)
    Tech tech;

    int rulesLevel;

    @Embedded
    Movement movement;

    boolean omni;

    String era;

    int weight;
    @Enumerated(EnumType.STRING)
    public WeightClass weightClass;// should be an ENUM


    //@ElementCollection(fetch = FetchType.EAGER)
    //@CollectionTable(name="unit_equipment", joinColumns = @JoinColumn(name="mech_id"))
    @OneToMany
    List<UnitEquipment> mechEquipment;

    public void setMechEquipment(List<UnitEquipment> mechEquipment) {
      mechEquipment.forEach(equip -> {
        if(equip.getEquipment().getTech() == null) {
          equip.getEquipment().setTech(this.tech);
        }
      });
      if(this.mechEquipment == null) {
        this.mechEquipment = mechEquipment;
      }else {
        this.mechEquipment.addAll(mechEquipment);
      }
    }

    public void setWeight(int weight) {
      this.weight = weight;
      if(weight < 20) {
        weightClass = WeightClass.ULTRA_LIGHT;
      }else if(weight < 40) {
        weightClass = WeightClass.LIGHT;
      }else if(weight < 60) {
        weightClass = WeightClass.MEDIUM;
      }else if(weight < 80) {
        weightClass = WeightClass.HEAVY;
      }else if(weight <= 100) {
        weightClass = WeightClass.ASSAULT;
      }else {
        weightClass = WeightClass.ULTRA_HEAVY;
      }
    }

    public void setOmni(String value) {
      if(value.equalsIgnoreCase("Omnimech")) {
        this.omni = true;
      }else {
        this.omni = false;
      }
    }

    public String getQuery() {
        StringBuilder builder = new StringBuilder();
        for(UnitEquipment e : mechEquipment) {
          builder.append(e.getQuery());
        }

        builder.append(" mechs.era = ");
        builder.append(era);
        return builder.toString();
    }
}
