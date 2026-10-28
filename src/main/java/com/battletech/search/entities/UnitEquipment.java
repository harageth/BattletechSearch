package com.battletech.search.entities;

import com.battletech.search.model.FireControl;
import com.battletech.search.model.Location;
import com.battletech.search.model.Searchable;
import java.util.UUID;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
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

  // Artemis / Apollo on a missile launcher; null for everything else
  @Enumerated(EnumType.STRING)
  FireControl fireControl;
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
