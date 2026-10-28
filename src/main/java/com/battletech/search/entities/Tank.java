package com.battletech.search.entities;

import com.battletech.search.model.MotiveSystem;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Getter;
import lombok.Setter;

// every MegaMek "Tank": tracked, wheeled, hover and so on, including boats
@Entity
@Getter
@Setter
public class Tank extends Vehicle{
  // null for units imported before motive types were stored
  @Enumerated(EnumType.STRING)
  MotiveSystem motiveSystem;
}
