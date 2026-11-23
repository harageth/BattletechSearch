package com.battletech.search.autocorrect;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.function.Supplier;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

/**
 * Reloading the search words once a minute: one reload at a time, the others keep their copy, and a failed
 * reload keeps it too (Sonnet's review of PR #31, 2026-11-22). No database: load() is replaced.
 */
class SearchWordsLoaderTest {
  private final AtomicLong now = new AtomicLong(1_000);
  private final AtomicInteger loads = new AtomicInteger();
  private final ExecutorService pool = Executors.newFixedThreadPool(8);

  @AfterEach
  void stopThreads() {
    pool.shutdownNow();
  }

  /** A loader whose load() counts and then does what's given. */
  private SearchWordsLoader loader(Supplier<SearchWords> load) {
    return new SearchWordsLoader(null, null, now::get) {
      @Override
      SearchWords load() {
        loads.incrementAndGet();
        return load.get();
      }
    };
  }

  private static SearchWords words(String word) {
    return SearchWords.of(List.of(word), List.of());
  }

  private void expire() {
    now.addAndGet(SearchWordsLoader.WORDS_KEPT.toNanos() + 1);
  }

  @Test
  void keepsTheWordsForAMinute() {
    SearchWordsLoader loader = loader(() -> words("heavy"));
    SearchWords first = loader.words();
    now.addAndGet(SearchWordsLoader.WORDS_KEPT.toNanos());
    assertThat(loader.words()).isSameAs(first);
    assertThat(loads).hasValue(1);
    now.incrementAndGet();
    assertThat(loader.words()).isNotSameAs(first);
    assertThat(loads).hasValue(2);
  }

  @Test
  void oneRequestReloadsWhileTheOthersKeepTheirCopy() throws Exception {
    CountDownLatch reloading = new CountDownLatch(1);
    CountDownLatch release = new CountDownLatch(1);
    SearchWords old = words("heavy");
    SearchWords fresh = words("light");
    SearchWordsLoader loader = loader(() -> {
      if (loads.get() == 1) {
        return old;
      }
      reloading.countDown();
      await(release);
      return fresh;
    });
    assertThat(loader.words()).isSameAs(old);
    expire();
    Future<SearchWords> reloader = pool.submit(loader::words);
    assertThat(reloading.await(5, TimeUnit.SECONDS)).isTrue();
    // while it reloads, everyone else gets the old copy right away
    List<Future<SearchWords>> others = new ArrayList<>();
    for (int i = 0; i < 6; i++) {
      others.add(pool.submit(loader::words));
    }
    for (Future<SearchWords> other : others) {
      assertThat(other.get(5, TimeUnit.SECONDS)).isSameAs(old);
    }
    release.countDown();
    assertThat(reloader.get(5, TimeUnit.SECONDS)).isSameAs(fresh);
    assertThat(loader.words()).isSameAs(fresh);
    assertThat(loads).hasValue(2);
  }

  @Test
  void aFailedReloadKeepsTheOldCopyAndTriesAgainLater() {
    SearchWords old = words("heavy");
    SearchWords fresh = words("light");
    AtomicInteger calls = new AtomicInteger();
    SearchWordsLoader loader = loader(() -> switch (calls.incrementAndGet()) {
      case 1 -> old;
      case 2 -> throw new IllegalStateException("database down");
      default -> fresh;
    });
    assertThat(loader.words()).isSameAs(old);
    expire();
    assertThat(loader.words()).isSameAs(old);
    assertThat(loads).hasValue(2);
    // not again until the retry wait is over
    now.addAndGet(SearchWordsLoader.RETRY_AFTER.toNanos() - 1);
    assertThat(loader.words()).isSameAs(old);
    assertThat(loads).hasValue(2);
    now.addAndGet(1);
    assertThat(loader.words()).isSameAs(fresh);
    assertThat(loads).hasValue(3);
  }

  @Test
  void theFirstLoadIsDoneOnceForEveryoneWaiting() throws Exception {
    CountDownLatch release = new CountDownLatch(1);
    SearchWords only = words("heavy");
    SearchWordsLoader loader = loader(() -> {
      await(release);
      return only;
    });
    List<Future<SearchWords>> requests = new ArrayList<>();
    for (int i = 0; i < 8; i++) {
      requests.add(pool.submit(loader::words));
    }
    Thread.sleep(100);
    release.countDown();
    for (Future<SearchWords> request : requests) {
      assertThat(request.get(5, TimeUnit.SECONDS)).isSameAs(only);
    }
    assertThat(loads).hasValue(1);
  }

  @Test
  void aFailedFirstLoadFailsTheRequestsUntilItsTimeToTryAgain() {
    // the database is likely down: requests in the next RETRY_AFTER fail at once instead of each trying (Codex
    // review of PR #31)
    AtomicInteger calls = new AtomicInteger();
    SearchWords words = words("heavy");
    SearchWordsLoader loader = loader(() -> {
      if (calls.incrementAndGet() == 1) {
        throw new IllegalStateException("database down");
      }
      return words;
    });
    assertThatThrownBy(loader::words).hasMessage("database down");
    assertThatThrownBy(loader::words).hasMessageContaining("trying again");
    assertThat(loads).hasValue(1);
    now.addAndGet(SearchWordsLoader.RETRY_AFTER.toNanos());
    assertThat(loader.words()).isSameAs(words);
    assertThat(loads).hasValue(2);
  }

  @Test
  void theWaitCountsFromWhenTheReloadFailed() {
    // a reload that takes longer than RETRY_AFTER to fail still waits RETRY_AFTER (Codex and Sonnet, PR #31)
    SearchWords old = words("heavy");
    AtomicInteger calls = new AtomicInteger();
    SearchWordsLoader loader = loader(() -> {
      if (calls.incrementAndGet() == 1) {
        return old;
      }
      now.addAndGet(SearchWordsLoader.RETRY_AFTER.toNanos() * 3);
      throw new IllegalStateException("timed out");
    });
    loader.words();
    expire();
    assertThat(loader.words()).isSameAs(old);
    assertThat(loader.words()).isSameAs(old);
    assertThat(loads).hasValue(2);
  }

  @Test
  void aClockBelowZeroStillReloads() {
    // System.nanoTime may be negative (Sonnet, PR #31)
    now.set(Long.MIN_VALUE / 2);
    SearchWordsLoader loader = loader(() -> words("heavy"));
    SearchWords first = loader.words();
    expire();
    assertThat(loader.words()).isNotSameAs(first);
    assertThat(loads).hasValue(2);
  }

  private static void await(CountDownLatch latch) {
    try {
      latch.await(5, TimeUnit.SECONDS);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
  }
}
