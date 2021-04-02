package com.battletech.search.antlr;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.model.EquipmentDecorator;
import com.battletech.search.entities.Unit;
import com.battletech.search.model.WeightClass;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.model.search.LogicalOperator;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import com.battletech.search.utils.UnitBuilder;
import java.util.LinkedList;
import java.util.List;
import me.BattletechParser.ComparatorContext;
import me.BattletechParser.EquipmentChunkContext;
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

public class TestVisitor implements BattletechVisitor {
  Vocabulary vocab;
  EquipmentSlangRepository slangRepo;
  EquipmentRepository equipRepo;

  public TestVisitor(Vocabulary vocab, EquipmentSlangRepository slangRepo, EquipmentRepository equipRepo) {
    this.vocab = vocab;
    this.slangRepo = slangRepo;
    this.equipRepo = equipRepo;
  }

  @Override
  public Object visitQuery(QueryContext ctx) {
    return null;
  }

  @Override
  public Object visitEquipmentChunk(EquipmentChunkContext ctx) {
    return null;
  }

  @Override
  public Object visitLine(LineContext ctx) {
    Unit unit = (Unit)visitUnit(ctx.unit());

    //ctx.unit()
    //String unitType = vocab.getSymbolicName(ctx.unit().get().getType());
    //Unit unit = UnitBuilder.buildUnit(ctx.unit().getText());
    // need to iterate through each set of quantity/equipment
    List<EquipmentChunkContext> equipment = ctx.equipmentChunk();
    if(ctx.WORD() != null && ctx.WORD().getSymbol() != null && !ctx.WORD().getText().contains("missing")) {
      String weightClass = ctx.WORD().getText();
      unit.setWeightClass(WeightClass.fromString(weightClass));
    }
    List<UnitEquipment> decorators = new LinkedList<UnitEquipment>();

    for(EquipmentChunkContext node : equipment) {
      String equip = "";
      for(TerminalNode equipNode: node.WORD()) {
        if(equip.isEmpty()) {
          equip = equipNode.getText();
        }else {
          equip = equip + " " + equipNode.getText();
        }
      }
      Object logicObject = visitLogicaloperator(node.logicaloperator());


      equip = equip.toLowerCase();
      boolean first = true;
      EquipmentDecorator realDecorator = new EquipmentDecorator(null);
      if(logicObject != null) {
        realDecorator.setOperator((LogicalOperator) logicObject);
      }
      // validate equipment type
      for(Equipment thing : equipRepo.findAllBySlangOrEquipmentName(equip)) {
        if(first) {
          first = false;
        }else {
          EquipmentDecorator decorator = new EquipmentDecorator(realDecorator);
          realDecorator = decorator;
        }
        realDecorator.setEquipment(thing);
        String comparator =(String) this.visitComparator(node.comparator());
        if(comparator == null || comparator.isEmpty()) {
          //realDecorator.buildComparison(node.QUANTITY().getText(), null);
          // need to fix buildComparison before this will properly work
          // node.QUANTITY().getSymbol().getType()
          realDecorator.buildComparison(node.QUANTITY().getText(), null);
        }else {
          //realDecorator.buildComparison(node.QUANTITY().getText(),
          //    node.COMPARATOR().getSymbol().getText());
          // node.QUANTITY().getSymbol().getType()
          realDecorator.buildComparison(node.QUANTITY().getText(),
              comparator);
        }

      }
      if(realDecorator.getEquipment() != null) {
        decorators.add(realDecorator);
      }else {
        throw new FailedParseException("Unable to parse: " + equip);
      }
    }
    unit.setMechEquipment(decorators);

    return unit;
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
