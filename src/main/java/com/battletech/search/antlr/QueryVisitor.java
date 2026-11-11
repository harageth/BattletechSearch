package com.battletech.search.antlr;

import com.battletech.search.entities.Equipment;
import com.battletech.search.model.ComponentFilter;
import com.battletech.search.model.EngineRatingFilter;
import com.battletech.search.model.EquipmentDecorator;
import com.battletech.search.model.FireControl;
import com.battletech.search.entities.Unit;
import com.battletech.search.model.Tech;
import com.battletech.search.model.UnitDecorator;
import com.battletech.search.model.UnitFilter;
import com.battletech.search.model.WeightClass;
import com.battletech.search.model.search.Comparison;
import com.battletech.search.model.search.FailedParseException;
import com.battletech.search.model.search.LogicalOperator;
import com.battletech.search.model.search.QuantityConverter;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.utils.ComponentNames;
import com.battletech.search.utils.EquipmentNames;
import com.battletech.search.utils.UnitBuilder;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import me.BattletechLexer;
import me.BattletechParser;
import me.BattletechParser.BareChunkContext;
import me.BattletechParser.ExceptUnitsContext;
import me.BattletechParser.NegationContext;
import me.BattletechParser.UnitWordsContext;
import me.BattletechParser.BareNameContext;
import me.BattletechParser.ChunkContext;
import me.BattletechParser.ChunksContext;
import me.BattletechParser.LeadContext;
import me.BattletechParser.MoreContext;
import me.BattletechParser.WithoutChunksContext;
import me.BattletechParser.ComparatorContext;
import me.BattletechParser.EquipmentChunkContext;
import me.BattletechParser.EquipmentNameContext;
import me.BattletechParser.LineContext;
import me.BattletechParser.LogicaloperatorContext;
import me.BattletechParser.OmniContext;
import me.BattletechParser.QueryContext;
import me.BattletechParser.RatingChunkContext;
import me.BattletechParser.UnitContext;
import me.BattletechParser.WeightClassContext;
import me.BattletechParser.WeightClassesContext;
import me.BattletechParser.WithoutChunkContext;
import me.BattletechVisitor;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.Vocabulary;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.RuleNode;
import org.antlr.v4.runtime.tree.TerminalNode;

public class QueryVisitor implements BattletechVisitor {
  Vocabulary vocab;
  EquipmentRepository equipRepo;

  public QueryVisitor(Vocabulary vocab, EquipmentRepository equipRepo) {
    this.vocab = vocab;
    this.equipRepo = equipRepo;
  }

  @Override
  public Object visitQuery(QueryContext ctx) {
    return visitLine(ctx.line());
  }

  /** "medium or heavy": each weight class named, in order. */
  @Override
  public List<WeightClass> visitWeightClasses(WeightClassesContext ctx) {
    return ctx.weightClass().stream().map(this::visitWeightClass).distinct().toList();
  }

  /**
   * Weight classes can be more than one word, e.g. "ultra light". A word that isn't one ("hevy",
   * "non-omnimech") fails the search instead of being left out, which would search every weight class.
   */
  @Override
  public WeightClass visitWeightClass(WeightClassContext ctx) {
    String typed = ctx.WORD().stream().map(TerminalNode::getText).collect(Collectors.joining(" "));
    WeightClass weightClass = WeightClass.fromString(typed);
    if (weightClass == null) {
      throw new FailedParseException("Unknown weight class: " + typed);
    }
    return weightClass;
  }

  /** The name as typed, words separated by spaces ("lrm 20"); normalized before the lookup. */
  @Override
  public Object visitEquipmentName(EquipmentNameContext ctx) {
    return ctx.children.stream().map(ParseTree::getText).collect(Collectors.joining(" "));
  }

  /** Like an equipment name, in a chunk with no number. */
  @Override
  public String visitBareName(BareNameContext ctx) {
    return ctx.children.stream().map(ParseTree::getText).collect(Collectors.joining(" "));
  }

  /** "omni" true, "non-omni" false. */
  @Override
  public Boolean visitOmni(OmniContext ctx) {
    return ctx.OMNI() != null;
  }

  @Override
  public Object visitLine(LineContext ctx) {
    UnitDecorator unit = (UnitDecorator) visitUnit(ctx.unitWords() != null ? ctx.unitWords().unit() : null);
    // the words around the weight class: "non-omni assault mechs", "assault omni mechs", "non-lam mechs"
    List<UnitDecorator> exclusions = new ArrayList<>();
    for(ParseTree child : ctx.unitWords() != null ? ctx.unitWords().children : ctx.children) {
      if(child instanceof OmniContext omni) {
        unit.setOmniFilter(visitOmni(omni));
      }else if(child instanceof WeightClassesContext weightClasses) {
        unit.setWeightClasses(visitWeightClasses(weightClasses));
      }else if(child instanceof TerminalNode word && word.getSymbol().getType() == BattletechParser.NONUNIT) {
        exclusions.add(nonUnit(word.getText()));
      }
    }
    // "mechs except lams and quads", "mechs that aren't omnis"
    if(ctx.exceptUnits() != null) {
      ctx.exceptUnits().unit().forEach(excepted -> exclusions.add((UnitDecorator) visitUnit(excepted)));
    }
    unit.setExclusions(exclusions);
    if(ctx.chunks() != null) {
      unit.setFilters(visitChunks(ctx.chunks()));
    }else if(ctx.withoutChunks() != null) {
      unit.setFilters(visitWithoutChunks(ctx.withoutChunks()));
    }
    return unit;
  }

  /** "non-lam" -> the unit "lam", to leave out. */
  private UnitDecorator nonUnit(String word) {
    String unitWord = word.substring(3).replaceFirst("^[-\\s]+", "");
    Token token = new BattletechLexer(CharStreams.fromString(unitWord)).nextToken();
    return (UnitDecorator) UnitBuilder.buildUnit(vocab.getSymbolicName(token.getType()));
  }

  @Override
  public Object visitUnitWords(UnitWordsContext ctx) {
    return null;
  }

  @Override
  public Object visitExceptUnits(ExceptUnitsContext ctx) {
    return null;
  }

  @Override
  public Object visitNegation(NegationContext ctx) {
    return null;
  }

  /** The chunks' filters in the order typed. */
  @Override
  public List<UnitFilter> visitChunks(ChunksContext ctx) {
    Chunks chunks = new Chunks();
    chunks.lead(ctx.lead());
    ctx.more().forEach(chunks::more);
    return chunks.filters;
  }

  /** "mechs without ppcs ...": a without-chunk in place of "with". */
  @Override
  public List<UnitFilter> visitWithoutChunks(WithoutChunksContext ctx) {
    Chunks chunks = new Chunks();
    chunks.add(visitWithoutChunk(ctx.withoutChunk()), true);
    ctx.more().forEach(chunks::more);
    return chunks.filters;
  }

  /**
   * Filters in the order typed. "without" carries over the chunks after it ("without ppcs or lasers":
   * neither) while they have no number or one that means one ("an xl engine"); a chunk with its own
   * count ("2 lrm 20"), an engine rating or "with" ends that.
   */
  private final class Chunks {
    final List<UnitFilter> filters = new ArrayList<>();
    boolean without;
    // the "and" / "or" before the next chunk
    LogicalOperator operator;

    void lead(LeadContext lead) {
      if(lead.STOPWORD() != null) {
        without = false;
      }
      if(lead.chunk() != null) {
        chunk(lead.chunk());
      }else {
        bare(visitBareChunk(lead.bareChunk()));
      }
    }

    void more(MoreContext more) {
      if(more.logicaloperator() != null) {
        operator = visitLogicaloperator(more.logicaloperator());
        lead(more.lead());
        return;
      }
      if(more.STOPWORD() != null) {
        without = false;
      }
      if(more.chunk() != null) {
        chunk(more.chunk());
      }else {
        bare(visitBareChunk(more.bareChunk()));
      }
    }

    private void chunk(ChunkContext chunk) {
      if(chunk.withoutChunk() != null) {
        add(visitWithoutChunk(chunk.withoutChunk()), true);
      }else if(chunk.ratingChunk() != null) {
        add(visitRatingChunk(chunk.ratingChunk()), false);
      }else {
        EquipmentChunkContext equipment = chunk.equipmentChunk();
        String comparator = (String) visitComparator(equipment.comparator());
        boolean one = isOne(equipment.QUANTITY().getText())
            && Comparison.fromToken(comparator) != Comparison.LESS_THAN
            && Comparison.fromToken(comparator) != Comparison.GREATER_THAN
            && Comparison.fromToken(comparator) != Comparison.EQUAL_OR_LESS;
        UnitFilter filter = visitEquipmentChunk(equipment);
        if(without && one) {
          carry(filter);
        }else {
          add(filter, false);
        }
      }
    }

    private void bare(UnitFilter filter) {
      if(without) {
        carry(filter);
      }else {
        add(filter, false);
      }
    }

    // a chunk in a "without" list: none of it either
    private void carry(UnitFilter filter) {
      negate(filter);
      UnitFilter previous = filters.isEmpty() ? null : filters.get(filters.size() - 1);
      if(previous != null && previous.isNegated()) {
        // "without ppcs or lasers" is neither
        operator = LogicalOperator.AND;
      }
      join(filter);
    }

    // "starts" says whether this chunk begins a "without" list
    void add(UnitFilter filter, boolean starts) {
      without = starts;
      join(filter);
    }

    private void join(UnitFilter filter) {
      if(!filters.isEmpty() && operator != null) {
        filters.get(filters.size() - 1).setOperator(operator);
      }
      operator = null;
      filters.add(filter);
    }
  }

  // "a", "an", "one", "1", "any"
  private static boolean isOne(String quantity) {
    return !quantity.equalsIgnoreCase("multiple") && QuantityConverter.toInt(quantity) == 1;
  }

  // none of it: equipment counts at least one and is negated
  private static void negate(UnitFilter filter) {
    if(filter instanceof ComponentFilter component) {
      component.setNegated(true);
    }else if(filter instanceof EquipmentDecorator equipment) {
      equipment.setNegated(true);
      for(UnitFilter link = equipment; link instanceof EquipmentDecorator decorator;
          link = (UnitFilter) decorator.getDecoratedEquipment()) {
        decorator.buildComparison("1", "ATLEAST");
      }
    }
  }

  @Override
  public UnitFilter visitLead(LeadContext ctx) {
    return null;
  }

  @Override
  public UnitFilter visitMore(MoreContext ctx) {
    return null;
  }

  /** No number: "endo steel" (has it), "lasers" (at least one). */
  @Override
  public UnitFilter visitBareChunk(BareChunkContext ctx) {
    String typed = visitBareName(ctx.bareName()).toLowerCase();
    ComponentFilter component = component(typed);
    if(component != null) {
      return component;
    }
    EquipmentDecorator equipment = equipment(typed);
    for(UnitFilter link = equipment; link instanceof EquipmentDecorator decorator;
        link = (UnitFilter) decorator.getDecoratedEquipment()) {
      decorator.buildComparison("1", "ATLEAST");
    }
    return equipment;
  }

  @Override
  public UnitFilter visitChunk(ChunkContext ctx) {
    if(ctx.withoutChunk() != null) {
      return visitWithoutChunk(ctx.withoutChunk());
    }else if(ctx.ratingChunk() != null) {
      return visitRatingChunk(ctx.ratingChunk());
    }
    return visitEquipmentChunk(ctx.equipmentChunk());
  }

  /** "2 ppc", "at least 1 lrm 20", "an xl engine": a component, else equipment. */
  @Override
  public UnitFilter visitEquipmentChunk(EquipmentChunkContext ctx) {
    String typed = ((String) visitEquipmentName(ctx.equipmentName())).toLowerCase();
    String quantity = ctx.QUANTITY().getText();
    String comparator = (String) visitComparator(ctx.comparator());
    ComponentFilter component = component(typed);
    if(component != null) {
      // a unit has one engine, one armor type...: "a", "an", "one", "1", "any", "at least 1"
      Comparison comparison = Comparison.fromToken(comparator);
      if(quantity.equalsIgnoreCase("multiple") || QuantityConverter.toInt(quantity) != 1
          || (comparison != Comparison.EQUAL && comparison != Comparison.EQUAL_OR_GREATER)) {
        throw new FailedParseException("A unit has one " + component.getComponent().kind().getWord() + ": " + typed);
      }
      return component;
    }
    EquipmentDecorator equipment = equipment(typed);
    for(UnitFilter link = equipment; link instanceof EquipmentDecorator decorator;
        link = (UnitFilter) decorator.getDecoratedEquipment()) {
      decorator.buildComparison(quantity, comparator);
    }
    return equipment;
  }

  /** "without an xl engine", "without ppcs": units with none of it. */
  @Override
  public UnitFilter visitWithoutChunk(WithoutChunkContext ctx) {
    String typed = ((String) visitEquipmentName(ctx.equipmentName())).toLowerCase();
    TerminalNode quantity = ctx.QUANTITY();
    if(quantity != null && (quantity.getText().equalsIgnoreCase("multiple") || QuantityConverter.toInt(quantity.getText()) != 1)) {
      throw new FailedParseException("'without' means none at all: use 'with fewer than " + quantity.getText()
          + " " + typed + "'");
    }
    ComponentFilter component = component(typed);
    if(component != null) {
      component.setNegated(true);
      return component;
    }
    EquipmentDecorator equipment = equipment(typed);
    equipment.setNegated(true);
    for(UnitFilter link = equipment; link instanceof EquipmentDecorator decorator;
        link = (UnitFilter) decorator.getDecoratedEquipment()) {
      decorator.buildComparison("1", "ATLEAST");
    }
    return equipment;
  }

  /** "an engine rating of at least 300", "engine rating 300 or more". */
  @Override
  public UnitFilter visitRatingChunk(RatingChunkContext ctx) {
    if(!ctx.WORD().getText().equalsIgnoreCase("engine")) {
      throw new FailedParseException("Can only search engine rating: " + ctx.WORD().getText() + " " + ctx.RATING().getText());
    }
    // the rating is the last number; one before "engine" is just "an"
    List<TerminalNode> numbers = ctx.QUANTITY();
    String rating = numbers.get(numbers.size() - 1).getText();
    return new EngineRatingFilter(
        Comparison.fromToken((String) visitComparator(ctx.comparator())), QuantityConverter.toInt(rating));
  }

  /** The component a chunk names ("xl engine", "clan endo steel", "xl engines"), or null. */
  private static ComponentFilter component(String typed) {
    EquipmentNames.TechWord techWord = EquipmentNames.splitTechWord(typed);
    String named = techWord.rest();
    ComponentNames.Component found = ComponentNames.find(named);
    if(found == null && named.endsWith("s")) {
      found = ComponentNames.find(named.substring(0, named.length() - 1));
    }
    if(found == null) {
      return null;
    }
    if(techWord.tech() != null && found.kind().getTechColumn() == null) {
      throw new FailedParseException("A " + found.kind().getWord() + " has no tech: " + typed);
    }
    return new ComponentFilter(found, techWord.tech());
  }

  /**
   * The equipment a chunk names, one decorator per matching row (IS and Clan), chained; comparisons
   * are set by the caller.
   */
  private EquipmentDecorator equipment(String equip) {
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
    // validate equipment type by its name or slang: "ac 20" and "autocannon 20" both find "ac/20",
    // a family term ("lrms", or "atm" in the singular) every weapon in it, counted together, and a
    // MegaMek name with its tech built in ("cllrm20") only that tech
    List<Equipment> found = findEquipment(lookup);
    if(found.isEmpty() && lookup.endsWith("s")) {
      // a plural: "2 lrm 20s", "4 medium lasers"
      lookup = lookup.substring(0, lookup.length() - 1);
      found = findEquipment(lookup);
    }
    List<Equipment> matches = found;
    if(tech != null) {
      Tech wanted = tech;
      matches = found.stream().filter(match -> match.getTech() == wanted).toList();
    }
    // the equipment exists, just not in that tech ("clan plasma rifle"): no unit has it, which
    // isn't a parse error
    boolean noneInTech = matches.isEmpty() && !found.isEmpty();
    EquipmentDecorator realDecorator = null;
    for(Equipment thing : noneInTech ? found.subList(0, 1) : matches) {
      realDecorator = new EquipmentDecorator(realDecorator);
      realDecorator.setEquipment(thing);
      realDecorator.setFireControls(fireControl == null ? null : fireControl.fireControls());
    }
    if(realDecorator == null) {
      throw new FailedParseException("Unable to parse: " + equip);
    }
    realDecorator.setMatchesNothing(noneInTech);
    return realDecorator;
  }

  /**
   * Equipment by a normalized search name: stored under that name, or what its slang term (a MegaMek
   * name, a family, shorthand) stands for.
   */
  private List<Equipment> findEquipment(String lookup) {
    return equipRepo.findAllByNameOrSlang(lookup, EquipmentNames.slangKey(lookup));
  }

  @Override
  public Object visitUnit(UnitContext ctx) {
    if(ctx == null) {
      return UnitBuilder.buildUnit("genericunit");
    }
    //if nothing is provided we should assume everything
    if(ctx.children == null) {
      return UnitBuilder.buildUnit("genericunit");
    }
    // "tracked vehicles": the motive type says it all, the vehicle word after it adds nothing
    return UnitBuilder.buildUnit(vocab.getSymbolicName(ctx.getStart().getType()));
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
  public LogicalOperator visitLogicaloperator(LogicaloperatorContext ctx) {
    if(ctx == null) {
      return null;
    }else if(ctx.AND() != null || ctx.BUT() != null) {
      // "with 2 ppc but no lasers"
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
