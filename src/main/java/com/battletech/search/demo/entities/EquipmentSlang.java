package com.battletech.search.demo.entities;

import java.util.UUID;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import lombok.Data;

@Entity
@Data
public class EquipmentSlang {

  @ManyToOne
  Equipment equipment;
  @Id
  String slang;
}
