package com.battletech.search.demo.repositories;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.model.Tech;
import java.util.List;
import java.util.UUID;
import org.springframework.data.repository.CrudRepository;

public interface EquipmentRepository extends CrudRepository<Equipment, UUID> {
  public List<Equipment> findByNameAndTech(String name, Tech tech);
}
