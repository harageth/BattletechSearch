package com.battletech.search.demo.services;

import com.battletech.search.demo.antlr.TestVisitor;
import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.EquipmentSlang;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.model.search.QuerySegment;// I think this needs to go away
import com.battletech.search.demo.repositories.EquipmentRepository;
import com.battletech.search.demo.repositories.EquipmentSlangRepository;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Optional;
import me.BattletechLexer;
import me.BattletechParser;
import me.BattletechVisitor;
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

  public List<Map<String, Object>> performQuery(String query) throws IOException {
    List<QuerySegment> querySegments = getQuerySegments(query);
    /*
    ANTLRInputStream
    Lexer
    // get a CommonTokenStream
    Parser

    get a context from the parser and pass it into the visitor
     */
    InputStream stream = new ByteArrayInputStream(query.getBytes(StandardCharsets.UTF_8));
    BattletechLexer lexer = new BattletechLexer(CharStreams.fromStream(stream, StandardCharsets.UTF_8));
    BattletechParser parser = new BattletechParser(new CommonTokenStream(lexer));
    /*
    From here I need to pull data out of the parser somehow
     */
    BattletechVisitor visitor = new TestVisitor(lexer.getVocabulary(), slangRepo);
    Unit unit = (Unit)visitor.visitLine(parser.line());
    for(UnitEquipment equip : unit.getMechEquipment()) {
      List<Equipment> validatedEquip = equipRepo.findByNameAndTech(equip.getEquipment().getName(),
          equip.getEquipment().getTech());
      if (validatedEquip.size() > 1) {
        for(Equipment valid : validatedEquip) {

        }
        throw new RuntimeException("Ambiguous equipment");
      } else if (validatedEquip.size() == 0) {
        Optional<EquipmentSlang> value = slangRepo
            .findById(equip.getEquipment().getName());
        if (value.isEmpty()) {
          throw new RuntimeException("Ambiguous equipment");
        } else {
          validatedEquip.add(value.get().getEquipment());
        }
        equip.setEquipment(value.get().getEquipment());
      }else {
        equip.setEquipment(validatedEquip.get(0));
      }
    }
    /*
    Unit mech = new Mech();
    mech.setEra("Dark Age");
    Equipment equip = new Equipment();
    equip.setEquipment("PPC");
    Equipment decoratedEquipment = new EquipmentDecorator(equip,
        Comparison.EQUAL_OR_GREATER, 3);
    List<Equipment> equipment = new LinkedList<Equipment>();
    equipment.add(decoratedEquipment);
    mech.setEquipment(equipment);
    */
    String unitQuery = unit.getQuery();
    return jdbcTemplate.queryForList(unitQuery);
    //jdbcTemplate.execute(unitQuery);
    //jdbcTemplate.get
    //NamedParameterJdbcTemplate namedParameterTemplate = new NamedParameterJdbcTemplate(jdbcTemplate.getDataSource());

    //StringBuilder builder = new StringBuilder("SELECT id FROM unit JOIN unit_equipment JOIN equipment ON mechs.id = equipment.mech_id WHERE ");
    //builder.append(unitQuery);
    //String test = builder.toString();

    /*
    select name from unit WHERE unit.id IN
      (SELECT unit_id FROM equipment JOIN unit_equipment ON equipment.id = unit_equipment.equipment_id
        WHERE equipment = 'Large Laser' OR equipment = 'Medium Laser'
        GROUP BY unit_equipment.unit_id
        HAVING COUNT(*) > 2);


     */
    //pass to function that will decompose into a query and run against the List of Segments
    //return null;
  }



  // A query should be of the format of
  // "Mechs with mutliple Large Lasers" or a more complex query "Things with at least 3 medium lasers and SRM's"
  public List<QuerySegment> getQuerySegments(String query) {
    /*
    So we need to find part of the query that matches to the language mapping
    If we can find where the language mapping is then we can use that as a starting point
    to figure out where the rest of the query parameters are.
     */



    /*
    1. Find what we are looking for
    2. split on logical operators while maintaining understanding of them
    3. identify what equipment is being looked at or which Unit Parameter
    4. identify quantity searching for
    5. identify comparator being used (this is probably implied)
    */


    /*
    Antlr information:
    We need to
     */
    ANTLRInputStream inputStream = new ANTLRInputStream(
        "I would like to [b][i]emphasize[/i][/b] this and [u]underline [b]that[/b][/u] ." +
            "Let's not forget to quote: [quote author=]You're wrong![/quote]");
    /*MarkupLexer markupLexer = new MarkupLexer(inputStream);
    CommonTokenStream commonTokenStream = new CommonTokenStream(markupLexer);
    MarkupParser markupParser = new MarkupParser(commonTokenStream);
    MarkupParser.FileContext fileContext = markupParser.file();
    MarkupVisitor visitor = new MarkupVisitor();/*
    visitor.visit(fileContext);*/





    return null;
  }

}
