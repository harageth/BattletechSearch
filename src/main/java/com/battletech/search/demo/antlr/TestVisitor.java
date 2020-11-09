package com.battletech.search.demo.antlr;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.EquipmentSlang;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.model.EquipmentDecorator;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.model.WeightClass;
import com.battletech.search.demo.repositories.EquipmentSlangRepository;
import com.battletech.search.demo.utils.UnitBuilder;
import java.util.LinkedList;
import java.util.List;
import me.BattletechLexer;
import me.BattletechParser.EquipmentChunkContext;
import me.BattletechParser.LineContext;
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

  public TestVisitor(Vocabulary vocab, EquipmentSlangRepository slangRepo) {
    this.vocab = vocab;
    this.slangRepo = slangRepo;
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
    List<ParseTree> val = ctx.unit().children;
    Unit unit = null;
    for(ParseTree thing : val) {
      Token temp = (Token)thing.getPayload(); // should be a token
      unit = UnitBuilder.buildUnit(vocab.getSymbolicName(temp.getType()));
      //thing.getSourceInterval()
    }
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
      // validate equipment type
      String equip = "";
      for(TerminalNode equipNode: node.WORD()) {
        if(equip.isEmpty()) {
          equip = equipNode.getText();
        }else {
          equip = equip + " " + equipNode.getText();
        }
      }
      equip = equip.toLowerCase();
      boolean first = true;
      EquipmentDecorator realDecorator = new EquipmentDecorator(null);
      for(EquipmentSlang slang : slangRepo.findAllBySlang(equip)){
        if(first) {
          first = false;
        }else {
          EquipmentDecorator decorator = new EquipmentDecorator(realDecorator);
          realDecorator = decorator;
        }
        realDecorator.setEquipment(slang.getEquipment());
        //decorator.setEquipment(slang.getEquipment());
        if(node.COMPARATOR() == null) {
          realDecorator.buildComparison(node.QUANTITY().getText(), null);
          //decorator.buildComparison(vocab.getSymbolicName(node.QUANTITY().getSymbol().getType()), null);
        }else {
          realDecorator.buildComparison(node.QUANTITY().getText(),
              node.COMPARATOR().getSymbol().getText());
          //decorator.buildComparison(vocab.getSymbolicName(node.QUANTITY().getSymbol().getType()),
          //    vocab.getSymbolicName(node.COMPARATOR().getSymbol().getType()));
        }

      }
      decorators.add(realDecorator);
    }
    unit.setMechEquipment(decorators);
    // Create a UnitBuilder to build off of the unit type and build with the list of equipment.


    return unit;
  }

  @Override
  public Object visitUnit(UnitContext ctx) {
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
