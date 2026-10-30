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

  @Query("select distinct e.name from Equipment e")
  public List<String> findAllNames();

  // names are every stored spelling of the canonical name (EquipmentNames.equivalentNames), slang
  // the term as typed (normalized)
  @Query("from Equipment e where e.name in :names OR e.id IN (select es.equipment.id from EquipmentSlang es where es.slang = :slang)")
  public List<Equipment> findAllByNameInOrSlang(Collection<String> names, String slang);

  //@Query("from Equipment e where e.name = :name AND e.tech = :tech OR e.id IN (select es.equipment.id from EquipmentSlang es where es.slang = :name)")
  //public List<Equipment> findAllBySlangOrEquipmentNameAndTech(String name, Tech tech);
}
