package com.battletech.search.repositories;

import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import java.util.Collection;
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

  List<Slang> findByKindIn(Collection<SlangKind> kinds);

  @EntityGraph(attributePaths = "equipment")
  @Query("from Slang")
  List<Slang> findAllWithEquipment();

  // the database removes their slang_equipment rows (ON DELETE CASCADE)
  @Modifying(flushAutomatically = true, clearAutomatically = true)
  @Query("delete from Slang s where s.kind not in :kinds")
  int deleteByKindNotIn(Collection<SlangKind> kinds);

  // the hand-written terms (SlangKind.HAND_WRITTEN) the other techs of an item have (same name, another row)
  @Query(value = """
      SELECT DISTINCT s.term FROM slang s
      JOIN slang_equipment se ON se.slang_id = s.id
      JOIN equipment e ON e.id = se.equipment_id
      WHERE s.kind IN ('SHORTHAND', 'USER') AND e.name = :name AND e.id <> :equipmentId
      ORDER BY s.term""", nativeQuery = true)
  List<String> findHandWrittenTermsOfOtherTechs(String name, UUID equipmentId);

  // links an item to the hand-written terms its other techs have; the item is flushed first, for the foreign key
  @Modifying(flushAutomatically = true)
  @Query(value = """
      INSERT INTO slang_equipment (slang_id, equipment_id)
      SELECT DISTINCT s.id, :equipmentId FROM slang s
      JOIN slang_equipment se ON se.slang_id = s.id
      JOIN equipment e ON e.id = se.equipment_id
      WHERE s.kind IN ('SHORTHAND', 'USER') AND e.name = :name AND e.id <> :equipmentId
      ON CONFLICT DO NOTHING""", nativeQuery = true)
  int joinHandWrittenTermsOfOtherTechs(String name, UUID equipmentId);
}
