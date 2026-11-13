package com.battletech.search.utils;

import com.battletech.search.entities.AmbiguousSlang;
import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import com.battletech.search.model.Tech;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Builds the slang terms for the equipment that's stored: MegaMek's names
 * (megamek/equipment-aliases.tsv), the equipment groups (the equipment_group tables, see
 * EquipmentGroups) and the hand-written shorthand (megamek/equipment-slang.tsv). Terms only stand
 * for equipment some unit has, which is why they're built after an import.
 */
public final class SlangTerms {

  /**
   * @param terms one per lookup key, each linked to the equipment rows it stands for
   * @param ambiguous keys MegaMek uses for more than one item, one row per candidate
   */
  public record Result(List<Slang> terms, List<AmbiguousSlang> ambiguous) {
  }

  private SlangTerms() {
  }

  /**
   * @param stored every equipment row
   * @param userLookups keys of terms added by hand (POST /actuator/slang): kept as they are, so
   *     nothing here replaces them, and a key in them isn't ambiguous any more
   */
  public static Result build(List<Equipment> stored, Set<String> userLookups, EquipmentGroups groups) {
    return build(stored, userLookups, EquipmentNames.readTsv(EquipmentNames.ALIASES),
        groups, EquipmentNames.readTsv(EquipmentNames.SHORTHAND));
  }

  static Result build(List<Equipment> stored, Set<String> userLookups, List<String[]> aliases,
      EquipmentGroups groups, List<String[]> shorthand) {
    Map<String, List<Equipment>> byName = stored.stream()
        .collect(Collectors.groupingBy(Equipment::getName, LinkedHashMap::new, Collectors.toList()));
    Map<String, Slang> terms = new LinkedHashMap<>();
    // keys someone decided: they're never ambiguous, and only a group replaces them (slang added by hand
    // not even that)
    Set<String> decided = new HashSet<>(userLookups);

    // several lines for one term link every item they name ("machine gun ammo": full and half tons)
    Map<String, String> shorthandTerms = new LinkedHashMap<>();
    Map<String, List<Equipment>> shorthandRows = new LinkedHashMap<>();
    for (String[] row : shorthand) {
      String key = EquipmentNames.slangKey(row[0]);
      if (!userLookups.contains(key)) {
        shorthandTerms.putIfAbsent(key, row[0]);
        shorthandRows.computeIfAbsent(key, k -> new ArrayList<>())
            .addAll(byName.getOrDefault(EquipmentNames.normalize(row[1]), List.of()));
      }
    }
    shorthandTerms.forEach((key, term) -> {
      decided.add(key);
      add(terms, term, key, SlangKind.SHORTHAND, shorthandRows.get(key));
    });

    List<AmbiguousSlang> ambiguous = addAliases(terms, decided, byName, aliases);

    // a group term names the group, and a search finds what's in it through the tree
    Set<UUID> storedIds = stored.stream().map(Equipment::getId).collect(Collectors.toSet());
    Set<String> ambiguousKeys = ambiguous.stream().map(AmbiguousSlang::getLookup).collect(Collectors.toSet());
    Set<String> storedKeys = byName.keySet().stream().map(EquipmentNames::slangKey).collect(Collectors.toSet());
    for (EquipmentGroups.Group group : groups.groups()) {
      String family = group.term();
      // one with nothing stored under it leaves the key be
      if (groups.everythingIn(family).stream().noneMatch(storedIds::contains)) {
        continue;
      }
      String key = EquipmentNames.slangKey(family);
      // a group wins over a MegaMek name or shorthand spelled the same ("ams" is every anti-missile
      // system, user 2026-11-01), not over slang added by hand
      if (!userLookups.contains(key)) {
        terms.remove(key);
        terms.put(key, new Slang(family, key, SlangKind.FAMILY, group.id()));
      }
      // "1 atm", "2 laser": the singular is the group too, unless something already has that name
      // ("ppc" stays the PPC); "artillery" has none, and "ams" isn't "am"
      if (!family.endsWith("s") || family.length() < 4) {
        continue;
      }
      String singular = family.substring(0, family.length() - (family.endsWith("oes") ? 2 : 1));
      String singularKey = EquipmentNames.slangKey(singular);
      if (!terms.containsKey(singularKey) && !decided.contains(singularKey) && !ambiguousKeys.contains(singularKey)
          && !storedKeys.contains(singularKey)) {
        terms.put(singularKey, new Slang(singular, singularKey, SlangKind.FAMILY_SINGULAR, group.id()));
      }
    }
    return new Result(new ArrayList<>(terms.values()), ambiguous);
  }

  /** Adds a term per MegaMek name of stored equipment; returns the keys that name several items. */
  private static List<AmbiguousSlang> addAliases(Map<String, Slang> terms, Set<String> decided,
      Map<String, List<Equipment>> byName, List<String[]> aliases) {
    // key -> canonical names it stands for, and the spelling for each
    Map<String, Map<String, String>> candidates = new LinkedHashMap<>();
    // prefixed key -> techs of its prefix, and keys that also occur without a prefix
    Map<String, Set<Tech>> prefixTechs = new HashMap<>();
    Set<String> plainKeys = new HashSet<>();
    for (String[] row : aliases) {
      for (EquipmentNames.AliasKey alias : EquipmentNames.aliasKeys(row[0], row[1])) {
        candidates.computeIfAbsent(alias.key(), k -> new LinkedHashMap<>()).putIfAbsent(alias.display(), alias.term());
        if (alias.prefixTech() == null) {
          plainKeys.add(alias.key());
        } else {
          prefixTechs.computeIfAbsent(alias.key(), k -> new HashSet<>()).add(alias.prefixTech());
        }
      }
    }
    List<AmbiguousSlang> ambiguous = new ArrayList<>();
    candidates.forEach((key, names) -> {
      if (decided.contains(key)) {
        return;
      }
      if (names.size() > 1) {
        names.forEach((name, term) -> ambiguous.add(new AmbiguousSlang(key, term, name)));
        return;
      }
      Map.Entry<String, String> only = names.entrySet().iterator().next();
      // "cllrm20" is only ever the Clan one; "claw" is a name of its own, not a Clan "aw"
      Set<Tech> techs = prefixTechs.getOrDefault(key, Set.of());
      Tech tech = techs.size() == 1 && !plainKeys.contains(key) ? techs.iterator().next() : null;
      List<Equipment> rows = byName.getOrDefault(only.getKey(), List.of()).stream()
          .filter(row -> tech == null || row.getTech() == tech).toList();
      add(terms, only.getValue(), key, SlangKind.ALIAS, rows);
    });
    return ambiguous;
  }

  private static void add(Map<String, Slang> terms, String term, String key, SlangKind kind, List<Equipment> rows) {
    if (!key.isEmpty() && !rows.isEmpty()) {
      terms.putIfAbsent(key, new Slang(term, key, kind, new LinkedHashSet<>(rows)));
    }
  }
}
