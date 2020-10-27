package com.battletech.search.demo.entities;

import com.battletech.search.demo.model.Location;
import com.battletech.search.demo.model.Searchable;
import java.util.Arrays;
import java.util.HashMap;
import java.util.UUID;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import lombok.Data;

@Entity
@Data
public class MechEquipment implements Searchable {
  @Id
  @GeneratedValue
  UUID id;

  @Enumerated(EnumType.STRING)
  Location location;
  int tonnage; // might only be relevant for armor

  @ManyToOne
  Equipment equipment;
  // probably an equipment ENUM
  // not sure what else needs to be here...
  public MechEquipment() { }

  public MechEquipment(Equipment equipment, String location) {
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
