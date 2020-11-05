package com.battletech.search.demo.entities;

import com.battletech.search.demo.model.Tech;
import java.util.UUID;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
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
