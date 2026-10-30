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
  // stored under that name, and every row the slang term stands for
  @Query("from Equipment e where e.name = :name OR e IN (select se from Slang s join s.equipment se where s.lookup = :lookup)")
  public List<Equipment> findAllByNameOrSlang(String name, String lookup);
}
