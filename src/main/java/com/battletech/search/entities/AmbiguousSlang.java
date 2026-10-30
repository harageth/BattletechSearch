package com.battletech.search.entities;

import java.io.Serializable;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * A key MegaMek uses for more than one item, one row per candidate, kept for someone to decide: a
 * line in megamek/equipment-slang.tsv or POST /actuator/slang settles it on the next slang load.
 */
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@IdClass(AmbiguousSlang.Key.class)
public class AmbiguousSlang {
  @Id
  String lookup;
  // as MegaMek wrote it for this candidate
  String term;
  @Id
  String equipmentName;

  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public static class Key implements Serializable {
    String lookup;
    String equipmentName;
  }
}
