package com.battletech.search.repositories;

import com.battletech.search.entities.Unit;
import java.util.UUID;
import org.springframework.data.repository.CrudRepository;

public interface UnitRepository extends CrudRepository<Unit, UUID> {

}
