package com.battletech.search.demo.antlr;

import com.battletech.search.demo.entities.Unit;
import me.BattletechListener;
import me.BattletechParser.ComparatorContext;
import me.BattletechParser.EquipmentChunkContext;
import me.BattletechParser.LineContext;
import me.BattletechParser.LogicaloperatorContext;
import me.BattletechParser.QueryContext;
import me.BattletechParser.UnitContext;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

public class TestListener implements BattletechListener {
  Unit unit;
  public TestListener(Unit unit) {
    this.unit = unit;
  }
  @Override
  public void enterQuery(QueryContext ctx) {

  }

  @Override
  public void exitQuery(QueryContext ctx) {

  }

  @Override
  public void enterEquipmentChunk(EquipmentChunkContext ctx) {

  }

  @Override
  public void exitEquipmentChunk(EquipmentChunkContext ctx) {

  }

  @Override
  public void enterLine(LineContext ctx) {

    for(ParseTree child: ctx.children) {

    }
  }

  @Override
  public void exitLine(LineContext ctx) {

  }

  @Override
  public void enterUnit(UnitContext ctx) {

  }

  @Override
  public void exitUnit(UnitContext ctx) {

  }

  @Override
  public void enterComparator(ComparatorContext ctx) {

  }

  @Override
  public void exitComparator(ComparatorContext ctx) {

  }

  @Override
  public void enterLogicaloperator(LogicaloperatorContext ctx) {

  }

  @Override
  public void exitLogicaloperator(LogicaloperatorContext ctx) {

  }

  @Override
  public void visitTerminal(TerminalNode terminalNode) {

  }

  @Override
  public void visitErrorNode(ErrorNode errorNode) {

  }

  @Override
  public void enterEveryRule(ParserRuleContext parserRuleContext) {

  }

  @Override
  public void exitEveryRule(ParserRuleContext parserRuleContext) {

  }
}
