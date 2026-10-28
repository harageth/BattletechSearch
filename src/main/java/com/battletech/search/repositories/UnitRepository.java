package com.battletech.search.repositories;

import com.battletech.search.entities.Unit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.repository.CrudRepository;

public interface UnitRepository extends CrudRepository<Unit, UUID> {
  Optional<Unit> findByMegamekUuid(UUID megamekUuid);

  // variants of the same unit
  List<Unit> findByMulId(Integer mulId);
}
