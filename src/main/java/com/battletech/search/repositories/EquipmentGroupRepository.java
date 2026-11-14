package com.battletech.search.repositories;

import com.battletech.search.entities.EquipmentGroup;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface EquipmentGroupRepository extends CrudRepository<EquipmentGroup, UUID> {
  // the whole tree, in the search guide's order
  @EntityGraph(attributePaths = {"parentIds", "memberIds"})
  @Query("from EquipmentGroup g order by g.position")
  List<EquipmentGroup> findTree();

  // the groups the other techs of an item are in itself (same name, another row)
  @Query(value = """
      SELECT DISTINCT g.name FROM equipment_group g
      JOIN equipment_group_member m ON m.group_id = g.id
      JOIN equipment e ON e.id = m.equipment_id
      WHERE e.name = :name AND e.id <> :equipmentId
      ORDER BY g.name""", nativeQuery = true)
  List<String> findGroupsOfOtherTechs(String name, UUID equipmentId);

  // puts an item in the groups its other techs are in; the item is flushed first, for the foreign key
  @Modifying(flushAutomatically = true)
  @Query(value = """
      INSERT INTO equipment_group_member (group_id, equipment_id)
      SELECT DISTINCT m.group_id, :equipmentId FROM equipment_group_member m
      JOIN equipment e ON e.id = m.equipment_id
      WHERE e.name = :name AND e.id <> :equipmentId
      ON CONFLICT DO NOTHING""", nativeQuery = true)
  int joinGroupsOfOtherTechs(String name, UUID equipmentId);
}
