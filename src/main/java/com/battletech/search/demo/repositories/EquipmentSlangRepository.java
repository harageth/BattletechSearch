package com.battletech.search.demo.repositories;

import com.battletech.search.demo.entities.EquipmentSlang;
import com.battletech.search.demo.model.Tech;
import java.util.List;
import org.springframework.data.repository.CrudRepository;

public interface EquipmentSlangRepository extends CrudRepository<EquipmentSlang, String> {
  public List<EquipmentSlang> findAllBySlang(String name);
  public List<EquipmentSlang> findAllBySlangAndEquipmentTech(String slang, Tech tech);
  //public List<EquipmentSlang> findAllBySlangOrEquipmentName(String name);
}
