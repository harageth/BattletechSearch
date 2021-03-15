package com.battletech.search.repositories;

import com.battletech.search.entities.UnitEquipment;
import java.util.UUID;
import org.springframework.data.repository.CrudRepository;

public interface MechEquipmentRepository extends CrudRepository<UnitEquipment, UUID> {

}
