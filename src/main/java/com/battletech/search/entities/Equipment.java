package com.battletech.search.entities;

import com.battletech.search.model.Tech;
import java.util.UUID;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.Data;

@Entity
@Data
public class Equipment {
  @Id
  @GeneratedValue
  UUID id;
  String name;
  @Enumerated(EnumType.STRING)
  Tech tech;
  int shortRange;
  int mediumRange;
  int longRange;
  int minRange;
  String damage;
  int heat;
  double tonnage;
  int critSlots;


  public Equipment(String name, Tech tech) {
    this.name = name;
    this.tech = tech;
  }

  public Equipment(String name) {
    this.name = name;
  }

  public Equipment() {

  }
}
