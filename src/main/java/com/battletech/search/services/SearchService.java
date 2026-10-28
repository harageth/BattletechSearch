package com.battletech.search.services;

import com.battletech.search.antlr.QueryParser;
import com.battletech.search.entities.Unit;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class SearchService {
  private final JdbcTemplate jdbcTemplate;
  private final EquipmentRepository equipRepo;
  private final EquipmentSlangRepository slangRepo;

  public SearchService(JdbcTemplate jdbcTemplate, EquipmentRepository equipRepo,
      EquipmentSlangRepository slangRepo) {
    this.jdbcTemplate = jdbcTemplate;
    this.equipRepo = equipRepo;
    this.slangRepo = slangRepo;
  }

  // A query should be of the format of
  // "Mechs with multiple Large Lasers" or a more complex query "Things with at least 3 medium lasers and SRM's"
  public List<Map<String, Object>> performQuery(String query) {
    Unit unit = QueryParser.parse(query, slangRepo, equipRepo);
    return jdbcTemplate.queryForList(unit.getQuery());
  }
}
