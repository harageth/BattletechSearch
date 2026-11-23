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
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.locks.ReentrantLock;
import java.util.function.LongSupplier;
import lombok.Value;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * The words and phrases a search can contain, for Autocorrect and Autocomplete; read again once a minute.
 * Autocomplete asks on almost every pause in typing, so a reload is done by one request at a time while the
 * others keep the copy they have, and a reload that fails keeps that copy and is tried again a little later
 * (Sonnet's review of PR #31, 2026-11-22). Only the very first load makes requests wait, and fails them if it fails.
 */
@Component
public class SearchWordsLoader {
  private static final Logger LOG = LoggerFactory.getLogger(SearchWordsLoader.class);
  // new imports show up within a minute
  static final Duration WORDS_KEPT = Duration.ofMinutes(1);
  // after a reload fails, how long the old copy is kept before trying again
  static final Duration RETRY_AFTER = Duration.ofSeconds(10);
  // keywords with no list of their own in QueryVocabulary, offered with the rest of the grammar
  private static final List<String> MORE_WORDS = List.of("without", "except", "rating of", "any", "support", "combat");

  /** The words and when they were read, set together so no request sees one without the other. */
  @Value
  private static class Loaded {
    SearchWords words;
    long loadedAt;
  }

  private final EquipmentRepository equipRepo;
  private final SlangRepository slangRepo;
  private final LongSupplier nanoTime;
  private final AtomicReference<Loaded> loaded = new AtomicReference<>();
  private final ReentrantLock reloading = new ReentrantLock();
  // after a failed load: not before this (nanoTime); null when there's nothing to wait for. Never compared
  // with 0, since nanoTime may be negative
  private volatile Long retryAt;

  @Autowired
  public SearchWordsLoader(EquipmentRepository equipRepo, SlangRepository slangRepo) {
    this(equipRepo, slangRepo, System::nanoTime);
  }

  // a clock the tests can move
  SearchWordsLoader(EquipmentRepository equipRepo, SlangRepository slangRepo, LongSupplier nanoTime) {
    this.equipRepo = equipRepo;
    this.slangRepo = slangRepo;
    this.nanoTime = nanoTime;
  }

  public SearchWords words() {
    Loaded current = loaded.get();
    if (current == null) {
      return firstLoad();
    }
    long now = nanoTime.getAsLong();
    if (now - current.getLoadedAt() <= WORDS_KEPT.toNanos() || waitingToRetry(now) || !reloading.tryLock()) {
      // fresh, waiting to retry, or another request is reloading: the copy we have
      return current.getWords();
    }
    try {
      if (loaded.get() == current) {
        loaded.set(new Loaded(load(), nanoTime.getAsLong()));
        retryAt = null;
      }
    } catch (RuntimeException e) {
      failed();
      LOG.warn("Couldn't reload the search words; keeping the copy from before for {}", RETRY_AFTER, e);
    } finally {
      reloading.unlock();
    }
    return loaded.get().getWords();
  }

  // Nothing to fall back on yet: requests wait for the one load, and fail with it. After it fails, the requests
  // in the next RETRY_AFTER fail at once instead of each trying again (the database is likely down)
  private SearchWords firstLoad() {
    reloading.lock();
    try {
      Loaded current = loaded.get();
      if (current != null) {
        return current.getWords();
      }
      if (waitingToRetry(nanoTime.getAsLong())) {
        throw new IllegalStateException("The search words couldn't be read; trying again in " + RETRY_AFTER);
      }
      try {
        current = new Loaded(load(), nanoTime.getAsLong());
      } catch (RuntimeException e) {
        failed();
        throw e;
      }
      loaded.set(current);
      retryAt = null;
      return current.getWords();
    } finally {
      reloading.unlock();
    }
  }

  private boolean waitingToRetry(long now) {
    Long wait = retryAt;
    return wait != null && now - wait < 0;
  }

  // the wait counts from when the load failed, not when it started: a slow failure still waits
  private void failed() {
    retryAt = nanoTime.getAsLong() + RETRY_AFTER.toNanos();
  }

  // the grammar's words, and every equipment name and slang term the search looks up
  SearchWords load() {
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
