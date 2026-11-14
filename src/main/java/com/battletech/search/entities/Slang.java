package com.battletech.search.entities;

import com.battletech.search.model.SlangKind;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;
import jakarta.persistence.Column;
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
 * ("lrm20" is the IS and Clan LRM 20), or the equipment group it names ("lrms").
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
  // a group term (FAMILY, FAMILY_SINGULAR) names its group and has no equipment rows of its own: a
  // search finds what's in the group and the groups under it (EquipmentRepository.findAllByNameOrSlang)
  @Column(name = "equipment_group_id")
  UUID equipmentGroupId;

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

  /** A term for an equipment group. */
  public Slang(String term, String lookup, SlangKind kind, UUID equipmentGroupId) {
    this.term = term;
    this.lookup = lookup;
    this.kind = kind;
    this.equipmentGroupId = equipmentGroupId;
  }
}
