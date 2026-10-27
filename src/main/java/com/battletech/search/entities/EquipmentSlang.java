package com.battletech.search.entities;

import java.util.UUID;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import lombok.Data;

@Entity
@Data
public class EquipmentSlang {
  @Id
  @GeneratedValue
  UUID id;
  @ManyToOne
  Equipment equipment;

  String slang;
}
