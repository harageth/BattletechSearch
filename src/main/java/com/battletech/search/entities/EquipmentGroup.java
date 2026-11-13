package com.battletech.search.entities;

import com.battletech.search.model.GroupSection;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * A group of the equipment tree ("standard lrms"), by id: the groups it sits under, and the
 * equipment rows in it itself. utils/EquipmentGroups puts them together into the tree.
 */
@Entity
@Data
@NoArgsConstructor
public class EquipmentGroup {
  @Id
  @GeneratedValue
  UUID id;
  // what a search types: "standard lrms"
  String name;
  // top groups only
  @Enumerated(EnumType.STRING)
  GroupSection section;
  // order on the search guide
  int position;

  @ElementCollection
  @CollectionTable(name = "equipment_group_parent", joinColumns = @JoinColumn(name = "group_id"))
  @Column(name = "parent_id")
  @EqualsAndHashCode.Exclude
  @ToString.Exclude
  Set<UUID> parentIds = new LinkedHashSet<>();

  @ElementCollection
  @CollectionTable(name = "equipment_group_member", joinColumns = @JoinColumn(name = "group_id"))
  @Column(name = "equipment_id")
  @EqualsAndHashCode.Exclude
  @ToString.Exclude
  Set<UUID> memberIds = new LinkedHashSet<>();
}
