package com.battletech.search.demo.entities;

import java.util.UUID;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import lombok.Data;

@Entity
@Data
public class Equipment {
  @Id
  @GeneratedValue
  UUID id;
  String name;
  int shortRange;
  int mediumRange;
  int longRange;
  int minRange;
  String damage;
  int heat;
  int tonnage;
  int critSlots;

  public Equipment(String name) {
    this.name = name;
  }

  public Equipment() {

  }
}
