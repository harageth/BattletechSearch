package com.battletech.search.repositories;

import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface SlangRepository extends CrudRepository<Slang, UUID> {
  Optional<Slang> findByLookup(String lookup);

  @EntityGraph(attributePaths = "equipment")
  List<Slang> findByKind(SlangKind kind);

  // the database removes their slang_equipment rows (ON DELETE CASCADE)
  @Modifying(flushAutomatically = true, clearAutomatically = true)
  @Query("delete from Slang s where s.kind <> :kind")
  int deleteByKindNot(SlangKind kind);
}
