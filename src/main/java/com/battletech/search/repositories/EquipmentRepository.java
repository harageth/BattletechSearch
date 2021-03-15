package com.battletech.search.repositories;

import com.battletech.search.entities.Equipment;
import com.battletech.search.model.Tech;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface EquipmentRepository extends CrudRepository<Equipment, UUID> {
  public List<Equipment> findByNameAndTech(String name, Tech tech);
  public List<Equipment> findByName(String name);

  @Query("from Equipment e where e.name = :name OR e.id IN (select es.equipment.id from EquipmentSlang es where es.slang = :name)")
  public List<Equipment> findAllBySlangOrEquipmentName(String name);

  //@Query("from Equipment e where e.name = :name AND e.tech = :tech OR e.id IN (select es.equipment.id from EquipmentSlang es where es.slang = :name)")
  //public List<Equipment> findAllBySlangOrEquipmentNameAndTech(String name, Tech tech);
}
