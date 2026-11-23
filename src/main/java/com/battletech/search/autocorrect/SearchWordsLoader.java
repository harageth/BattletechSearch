package com.battletech.search.autocorrect;

import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import com.battletech.search.model.search.QuantityConverter;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.utils.EquipmentNames;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Component;

/** The words and phrases a search can contain, for Autocorrect and Autocomplete; read again once a minute. */
@Component
public class SearchWordsLoader {
  // new imports show up within a minute
  private static final Duration WORDS_KEPT = Duration.ofMinutes(1);
  // keywords with no list of their own in QueryVocabulary, offered with the rest of the grammar
  private static final List<String> MORE_WORDS = List.of("without", "except", "rating of", "any", "support", "combat");

  private final EquipmentRepository equipRepo;
  private final SlangRepository slangRepo;
  private volatile SearchWords words;
  private volatile long wordsLoadedAt;

  public SearchWordsLoader(EquipmentRepository equipRepo, SlangRepository slangRepo) {
    this.equipRepo = equipRepo;
    this.slangRepo = slangRepo;
  }

  public SearchWords words() {
    if (words == null || System.nanoTime() - wordsLoadedAt > WORDS_KEPT.toNanos()) {
      words = load();
      wordsLoadedAt = System.nanoTime();
    }
    return words;
  }

  // the grammar's words, and every equipment name and slang term the search looks up
  private SearchWords load() {
    List<String> grammar = new ArrayList<>();
    grammar.addAll(QueryVocabulary.weightClasses());
    // the plural is what a search says; the singular is one of its other spellings
    List<String> spellings = new ArrayList<>();
    QueryVocabulary.units().forEach(unit -> {
      grammar.add(unit.plural());
      spellings.add(unit.singular());
    });
    grammar.addAll(QueryVocabulary.comparatorsBefore());
    grammar.addAll(QueryVocabulary.comparatorsAfter());
    grammar.addAll(QueryVocabulary.operators());
    grammar.addAll(QueryVocabulary.withWords());
    grammar.addAll(QueryVocabulary.techs().keySet());
    grammar.addAll(QueryVocabulary.unitTechs().keySet());
    grammar.addAll(QueryVocabulary.fireControls());
    grammar.addAll(QueryVocabulary.turretMounts());
    grammar.addAll(QueryVocabulary.omniWords());
    List<String> components = new ArrayList<>();
    QueryVocabulary.components().values().forEach(components::addAll);
    grammar.addAll(MORE_WORDS);
    spellings.addAll(QueryVocabulary.keywords());
    spellings.addAll(QuantityConverter.numberWords());

    List<String> fixed = new ArrayList<>(grammar);
    fixed.addAll(components);
    fixed.addAll(spellings);
    List<String> equipment = new ArrayList<>();
    // a whole name is shown as typed ("medium laser"), not as stored ("mediumlaser"), so the display name first
    List<String> completions = new ArrayList<>(components);
    for (Equipment item : equipRepo.findAll()) {
      if (item.getDisplayName() != null) {
        String typed = EquipmentNames.typed(item.getDisplayName());
        equipment.add(typed);
        completions.add(QueryVocabulary.typeableSpelling(typed));
      }
      equipment.add(item.getName());
    }
    List<String> groups = new ArrayList<>();
    for (Slang term : slangRepo.findAll()) {
      equipment.add(term.getTerm());
      // MegaMek's other names ("CLLRM20") can be typed, but would crowd out the names people use
      if (term.getKind() == SlangKind.FAMILY) {
        groups.add(term.getTerm());
      } else if (SlangKind.HAND_WRITTEN.contains(term.getKind())) {
        completions.add(term.getTerm());
      }
    }
    return SearchWords.of(fixed, equipment, SearchWords.phrases(grammar, groups, completions, spellings));
  }
}
