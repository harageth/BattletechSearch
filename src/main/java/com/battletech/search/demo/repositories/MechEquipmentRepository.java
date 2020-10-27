package com.battletech.search.demo.repositories;

import com.battletech.search.demo.entities.MechEquipment;
import java.util.UUID;
import org.springframework.data.repository.CrudRepository;

public interface MechEquipmentRepository extends CrudRepository<MechEquipment, UUID> {

}
