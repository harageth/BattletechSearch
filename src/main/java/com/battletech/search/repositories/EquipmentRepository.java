package com.battletech.search.repositories;

import com.battletech.search.entities.Equipment;
import com.battletech.search.model.Tech;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface EquipmentRepository extends CrudRepository<Equipment, UUID> {
  public List<Equipment> findByNameAndTech(String name, Tech tech);
  public List<Equipment> findByName(String name);

  public List<Equipment> findByNameIn(Collection<String> names);

  @Override
  public List<Equipment> findAll();

  // name is the normalized search name, lookup its slang key (EquipmentNames.slangKey): equipment
  // stored under that name, every row the slang term links, and, for a group's term, everything in
  // the group and the groups under it, as deep as they go
  @Query(value = """
      WITH RECURSIVE term AS (
          SELECT id, equipment_group_id FROM slang WHERE lookup = :lookup
      ), under (id) AS (
          SELECT equipment_group_id FROM term WHERE equipment_group_id IS NOT NULL
          UNION
          SELECT p.group_id FROM equipment_group_parent p JOIN under u ON p.parent_id = u.id
      )
      SELECT e.* FROM equipment e
      WHERE e.name = :name
         OR e.id IN (SELECT se.equipment_id FROM slang_equipment se JOIN term t ON t.id = se.slang_id)
         OR e.id IN (SELECT m.equipment_id FROM equipment_group_member m JOIN under u ON u.id = m.group_id)""",
      nativeQuery = true)
  public List<Equipment> findAllByNameOrSlang(String name, String lookup);
}
