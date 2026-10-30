package com.battletech.search.entities;

import com.battletech.search.model.SlangKind;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * A word or spelling for equipment, and the equipment rows it stands for: one term, many rows
 * ("lrms" is every LRM, IS and Clan).
 */
@Entity
@Data
@NoArgsConstructor
public class Slang {
  @Id
  @GeneratedValue
  UUID id;
  // as written: "gauss rifles", "LB 10-X AC"
  String term;
  // what a search matches: EquipmentNames.slangKey of the term
  String lookup;
  @Enumerated(EnumType.STRING)
  SlangKind kind;

  @ManyToMany
  @JoinTable(name = "slang_equipment", joinColumns = @JoinColumn(name = "slang_id"),
      inverseJoinColumns = @JoinColumn(name = "equipment_id"))
  @EqualsAndHashCode.Exclude
  @ToString.Exclude
  Set<Equipment> equipment = new LinkedHashSet<>();

  public Slang(String term, String lookup, SlangKind kind, Set<Equipment> equipment) {
    this.term = term;
    this.lookup = lookup;
    this.kind = kind;
    this.equipment = new LinkedHashSet<>(equipment);
  }
}
