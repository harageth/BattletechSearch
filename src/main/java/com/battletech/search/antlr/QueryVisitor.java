package com.battletech.search.antlr;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.model.EquipmentDecorator;
import com.battletech.search.model.FireControl;
import com.battletech.search.entities.Unit;
import com.battletech.search.model.Tech;
import com.battletech.search.model.WeightClass;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.model.search.LogicalOperator;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import com.battletech.search.utils.EquipmentNames;
import com.battletech.search.utils.UnitBuilder;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import me.BattletechParser.ComparatorContext;
import me.BattletechParser.EquipmentChunkContext;
import me.BattletechParser.EquipmentNameContext;
import me.BattletechParser.LineContext;
import me.BattletechParser.LogicaloperatorContext;
import me.BattletechParser.QueryContext;
import me.BattletechParser.UnitContext;
import me.BattletechVisitor;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.Vocabulary;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.RuleNode;
import org.antlr.v4.runtime.tree.TerminalNode;

public class QueryVisitor implements BattletechVisitor {
  Vocabulary vocab;
  EquipmentSlangRepository slangRepo;
  EquipmentRepository equipRepo;

  public QueryVisitor(Vocabulary vocab, EquipmentSlangRepository slangRepo, EquipmentRepository equipRepo) {
    this.vocab = vocab;
    this.slangRepo = slangRepo;
    this.equipRepo = equipRepo;
  }

  @Override
  public Object visitQuery(QueryContext ctx) {
    return visitLine(ctx.line());
  }

  @Override
  public Object visitEquipmentChunk(EquipmentChunkContext ctx) {
    return null;
  }

  /** The name as typed, words separated by spaces ("lrm 20"); normalized before the lookup. */
  @Override
  public Object visitEquipmentName(EquipmentNameContext ctx) {
    return ctx.children.stream().map(ParseTree::getText).collect(Collectors.joining(" "));
  }

  @Override
  public Object visitLine(LineContext ctx) {
    Unit unit = (Unit)visitUnit(ctx.unit());

    // need to iterate through each set of quantity/equipment
    List<EquipmentChunkContext> equipment = ctx.equipmentChunk();
    if(!ctx.WORD().isEmpty()) {
      // weight classes can be more than one word, e.g. "ultra light"
      String weightClass = ctx.WORD().stream().map(TerminalNode::getText).collect(Collectors.joining(" "));
      unit.setWeightClass(WeightClass.fromString(weightClass));
    }
    List<UnitEquipment> decorators = new LinkedList<UnitEquipment>();

    for(EquipmentChunkContext node : equipment) {
      String equip = ((String) visitEquipmentName(node.equipmentName())).toLowerCase();
      Object logicObject = visitLogicaloperator(node.logicaloperator());

      boolean first = true;
      EquipmentDecorator realDecorator = new EquipmentDecorator(null);
      if(logicObject != null) {
        realDecorator.setOperator((LogicalOperator) logicObject);
      }
      // tech is optional: "medium laser" counts IS and Clan ones together, "clan medium laser" only Clan
      EquipmentNames.TechWord techWord = EquipmentNames.splitTechWord(equip);
      Tech tech = techWord.tech();
      String named = techWord.rest();
      // "artemis lrm 20": look up the launcher, and only count ones with that fire control
      String lookup = EquipmentNames.normalize(named);
      FireControl.Filter fireControl = FireControl.fromSearch(lookup);
      if(fireControl != null) {
        lookup = fireControl.launcher();
      }
      if(tech == null) {
        // a MegaMek name with its tech built in: "cllrm20" is a Clan LRM 20
        tech = EquipmentNames.techOf(lookup);
      }
      // validate equipment type; "ac 20" and "autocannon 20" both find "ac/20", and a family term
      // ("lrms") finds every weapon in it, counted together
      List<Equipment> found = findEquipment(lookup);
      if(found.isEmpty() && lookup.endsWith("s")) {
        // a plural: "2 lrm 20s", "4 medium lasers"
        found = findEquipment(lookup.substring(0, lookup.length() - 1));
      }
      List<Equipment> matches = found;
      if(tech != null) {
        Tech wanted = tech;
        matches = found.stream().filter(match -> match.getTech() == wanted).toList();
      }
      // the equipment exists, just not in that tech ("clan plasma rifle"): no unit has it, which
      // isn't a parse error
      boolean noneInTech = matches.isEmpty() && !found.isEmpty();
      for(Equipment thing : noneInTech ? found.subList(0, 1) : matches) {
        if(first) {
          first = false;
        }else {
          EquipmentDecorator decorator = new EquipmentDecorator(realDecorator);
          realDecorator = decorator;
        }
        realDecorator.setEquipment(thing);
        realDecorator.setFireControls(fireControl == null ? null : fireControl.fireControls());
        String comparator = (String) this.visitComparator(node.comparator());
        if(comparator == null || comparator.isEmpty()) {
          realDecorator.buildComparison(node.QUANTITY().getText(), null);
        }else {
          realDecorator.buildComparison(node.QUANTITY().getText(), comparator);
        }
      }
      if(realDecorator.getEquipment() != null) {
        realDecorator.setMatchesNothing(noneInTech);
        decorators.add(realDecorator);
      }else {
        throw new FailedParseException("Unable to parse: " + equip);
      }
    }
    unit.setMechEquipment(decorators);

    return unit;
  }

  /** Equipment by a normalized search name: any of its names, slang, or every weapon of a family term. */
  private List<Equipment> findEquipment(String lookup) {
    Set<String> family = EquipmentNames.familyMembers(lookup);
    Set<String> names = new LinkedHashSet<>();
    for(String canonical : family.isEmpty() ? Set.of(EquipmentNames.canonical(lookup)) : family) {
      names.addAll(EquipmentNames.equivalentNames(canonical));
    }
    return equipRepo.findAllByNameInOrSlang(names, lookup);
  }

  @Override
  public Object visitUnit(UnitContext ctx) {
    if(ctx == null) {
      return UnitBuilder.buildUnit("genericunit");
    }
    List<ParseTree> children = ctx.children;
    Unit unit = null;
    //if nothing is provided we should assume everything
    if(children == null) {
      return UnitBuilder.buildUnit("genericunit");
    }
    for(ParseTree childToken : children) {
      Token temp = (Token)childToken.getPayload(); // should be a token
      unit = UnitBuilder.buildUnit(vocab.getSymbolicName(temp.getType()));
    } // shouldn't have multiple units provided in a parse
    return unit;
  }

  @Override
  public Object visitComparator(ComparatorContext ctx) {
    if(ctx == null) {
      return null;
    }
    List<ParseTree> value = ctx.children;
    String comparator = "";
    for(ParseTree val : value){
      Token temp = (Token)val.getPayload(); // should be a token
      comparator = vocab.getSymbolicName(temp.getType());
    }
    return comparator;
  }

  @Override
  public Object visitLogicaloperator(LogicaloperatorContext ctx) {
    if(ctx == null) {
      return null;
    }else if(ctx.AND() != null) {
      return LogicalOperator.AND;
    }else if(ctx.OR() != null) {
      return LogicalOperator.OR;
    }

    return null;
  }

  @Override
  public Object visit(ParseTree parseTree) {
    return null;
  }

  @Override
  public Object visitChildren(RuleNode ruleNode) {
    return null;
  }

  @Override
  public Object visitTerminal(TerminalNode terminalNode) {
    return null;
  }

  @Override
  public Object visitErrorNode(ErrorNode errorNode) {
    return null;
  }
}
