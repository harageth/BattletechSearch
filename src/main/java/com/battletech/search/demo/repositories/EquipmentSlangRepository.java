package com.battletech.search.demo.repositories;

import com.battletech.search.demo.entities.EquipmentSlang;
import com.battletech.search.demo.model.Tech;
import java.util.List;
import org.springframework.data.repository.CrudRepository;

public interface EquipmentSlangRepository extends CrudRepository<EquipmentSlang, String> {
}
