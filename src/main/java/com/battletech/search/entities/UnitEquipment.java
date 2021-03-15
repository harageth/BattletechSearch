package com.battletech.search.entities;

import com.battletech.search.model.Location;
import com.battletech.search.model.Searchable;
import java.util.UUID;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import lombok.Data;

@Data
@Entity
public class UnitEquipment implements Searchable {
  @Id
  @GeneratedValue
  UUID id;

  @Enumerated(EnumType.STRING)
  Location location;
  double tonnage; // might only be relevant for armor

  @ManyToOne
  Equipment equipment;

  boolean omniPod;
  boolean rearFacing;
  boolean turretEquipped;
  //boolean sponsonEquipped; // might be able to be handled by the turretEquipped

  public UnitEquipment() { }

  public UnitEquipment(Equipment equipment, String location) {
    this.equipment = equipment;
    this.location = Location.fromString(location);
  }


  @Override
  public String getQuery() {
    StringBuilder builder = new StringBuilder();
    builder.append(" location = ");
    builder.append(location);

    return builder.toString();
  }
}
