package com.battletech.search.services;

import com.battletech.search.antlr.ConcreteBattletechVisitor;
import com.battletech.search.entities.Unit;
import com.battletech.search.model.ParserHolder;
import com.battletech.search.model.dto.QueryDTO;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.LinkedList;
import java.util.Map;
import me.BattletechLexer;
import me.BattletechParser;
import org.antlr.v4.runtime.*;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;

@Controller
public class SearchService {
  @Autowired
  JdbcTemplate jdbcTemplate;

  @Autowired
  EquipmentRepository equipRepo;

  @Autowired
  EquipmentSlangRepository slangRepo;

  public QueryDTO performQuery(String query) throws IOException {

    InputStream stream = new ByteArrayInputStream(query.getBytes(StandardCharsets.UTF_8));
    BattletechLexer lexer = new BattletechLexer(CharStreams.fromStream(stream, StandardCharsets.UTF_8));
    BattletechParser parser = new BattletechParser(new CommonTokenStream(lexer));

    me.BattletechVisitor visitor = new ConcreteBattletechVisitor(lexer.getVocabulary(), slangRepo, equipRepo);
    ParserHolder holder = (ParserHolder)visitor.visitLine(parser.line());

    // no unit was supplied, and were unable to parse any equipment and anything else did not parse correctly.
    //if(holder.isDefaultUnit() && holder.getUnit().getMechEquipment().isEmpty() && !holder.getErrorMessages().isEmpty()) {
    //  return new LinkedList();
    //}

    String unitQuery = holder.getUnit().getQuery();
    QueryDTO queryDTO = new QueryDTO();
    queryDTO.setErrors(holder.getErrorMessages());
    queryDTO.setResultSet(jdbcTemplate.queryForList(unitQuery));

    return queryDTO;
  }

  /*
  public static String buildMULUnitURI(String unit, String designation) {
    StringBuilder builder = new StringBuilder();
  }
  */


}
