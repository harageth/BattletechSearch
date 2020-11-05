package com.battletech.search.demo.antlr;

import com.battletech.search.demo.entities.Equipment;
import com.battletech.search.demo.entities.UnitEquipment;
import com.battletech.search.demo.model.EquipmentDecorator;
import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.model.WeightClass;
import com.battletech.search.demo.utils.UnitBuilder;
import java.util.LinkedList;
import java.util.List;
import me.BattletechParser.EquipmentChunkContext;
import me.BattletechParser.LineContext;
import me.BattletechParser.QueryContext;
import me.BattletechVisitor;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.RuleNode;
import org.antlr.v4.runtime.tree.TerminalNode;

public class TestVisitor implements BattletechVisitor {

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
    Unit unit = UnitBuilder.buildUnit(ctx.UNIT().getText());

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
      EquipmentDecorator decorator = new EquipmentDecorator(new UnitEquipment());

      decorator.setEquipment(new Equipment(equip));
      if(node.COMPARATOR() == null) {
       decorator.buildComparison(node.QUANTITY().getText(), null);
      }else {
        decorator.buildComparison(node.QUANTITY().getText(), node.COMPARATOR().getText());
      }
      decorators.add(decorator);
    }
    unit.setMechEquipment(decorators);
    // Create a UnitBuilder to build off of the unit type and build with the list of equipment.


    return unit;
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
