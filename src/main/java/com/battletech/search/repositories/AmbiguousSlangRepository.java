package com.battletech.search.repositories;

import com.battletech.search.entities.AmbiguousSlang;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface AmbiguousSlangRepository extends CrudRepository<AmbiguousSlang, AmbiguousSlang.Key> {
  @Modifying(flushAutomatically = true, clearAutomatically = true)
  @Query("delete from AmbiguousSlang")
  int deleteAllRows();
}
