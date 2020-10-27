package com.battletech.search.demo.repositories;

import com.battletech.search.demo.entities.Unit;
import java.util.UUID;
import org.springframework.data.repository.CrudRepository;

public interface UnitRepository extends CrudRepository<Unit, UUID> {

}
