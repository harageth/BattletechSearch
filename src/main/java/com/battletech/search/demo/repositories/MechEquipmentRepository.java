package com.battletech.search.demo.repositories;

import com.battletech.search.demo.entities.UnitEquipment;
import java.util.UUID;
import org.springframework.data.repository.CrudRepository;

public interface MechEquipmentRepository extends CrudRepository<UnitEquipment, UUID> {

}
