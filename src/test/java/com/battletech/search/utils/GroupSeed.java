package com.battletech.search.utils;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.EquipmentGroup;
import com.battletech.search.model.GroupSection;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * The equipment group tree as the migrations write it, for tests without a database: its groups,
 * parents and (group, equipment name) members, read from the migration files. V3_17 writes the tree;
 * V3_20 adds the ammo groups and moves ammo out of "ammo" itself into them.
 */
public final class GroupSeed {
  static final String MIGRATION = "/db/migration/V3_17__equipment_group_rows.sql";
  static final String AMMO_MIGRATION = "/db/migration/V3_20__ammo_groups.sql";
  static final String TEST_MEMBERS = "/db/equipment-group-members.sql";

  private static final Pattern GROUP = Pattern.compile("\\(gen_random_uuid\\(\\), '((?:[^']|'')*)', (?:NULL|'(\\w+)'), (\\d+)\\)");
  private static final Pattern PAIR = Pattern.compile("^\\s+\\('((?:[^']|'')*)', '((?:[^']|'')*)'\\)", Pattern.MULTILINE);
  // V3_20 makes room for its groups: "SET position = position + 22 WHERE position > 58"
  private static final Pattern SHIFT = Pattern.compile("SET position = position \\+ (\\d+) WHERE position > (\\d+)");

  /** A row of the seed: a group and one of its parents, or a group and an equipment name in it. */
  record Pair(String group, String other) {
  }

  private GroupSeed() {
  }

  /** The group names, in the guide's order, and the section of each top group. */
  static Map<String, GroupSection> groups() {
    Map<String, GroupSection> sections = new HashMap<>();
    TreeMap<Integer, String> byPosition = new TreeMap<>();
    Matcher shift = SHIFT.matcher(read(AMMO_MIGRATION));
    shift.find();
    int by = Integer.parseInt(shift.group(1));
    int after = Integer.parseInt(shift.group(2));
    for (String migration : List.of(MIGRATION, AMMO_MIGRATION)) {
      Matcher matcher = GROUP.matcher(read(migration));
      while (matcher.find()) {
        String name = unquote(matcher.group(1));
        int position = Integer.parseInt(matcher.group(3));
        byPosition.put(migration.equals(MIGRATION) && position > after ? position + by : position, name);
        sections.put(name, matcher.group(2) == null ? null : GroupSection.valueOf(matcher.group(2)));
      }
    }
    Map<String, GroupSection> groups = new LinkedHashMap<>();
    byPosition.values().forEach(name -> groups.put(name, sections.get(name)));
    return groups;
  }

  static List<Pair> parents() {
    List<Pair> parents = pairs(section(read(MIGRATION), "INSERT INTO equipment_group_parent", "INSERT INTO equipment_group_member"));
    parents.addAll(pairs(section(read(AMMO_MIGRATION), "INSERT INTO equipment_group_parent", "WITH moved")));
    return parents;
  }

  static List<Pair> members() {
    List<Pair> members = pairs(section(read(MIGRATION), "INSERT INTO equipment_group_member", null));
    List<Pair> moved = pairs(section(read(AMMO_MIGRATION), "WITH moved", null));
    Set<String> movedNames = moved.stream().map(Pair::other).collect(Collectors.toSet());
    members.removeIf(pair -> pair.group().equals("ammo") && movedNames.contains(pair.other()));
    members.addAll(moved);
    // db/data/V3_21 drops apostrophes from names: "'mechmortar1" is "mechmortar1"
    return members.stream().map(pair -> new Pair(pair.group(), pair.other().replace("'", ""))).collect(Collectors.toList());
  }

  /** The members db/equipment-group-members.sql gives the test database. */
  static List<Pair> testMembers() {
    return pairs(read(TEST_MEMBERS));
  }

  /** The tree the migrations make on a database holding these equipment rows. */
  public static EquipmentGroups tree(List<Equipment> stored) {
    return EquipmentGroups.of(rows(stored));
  }

  /** The equipment_group rows the migrations write on a database holding these equipment rows, in order. */
  public static List<EquipmentGroup> rows(List<Equipment> stored) {
    Map<String, List<UUID>> idsByName = stored.stream()
        .collect(Collectors.groupingBy(Equipment::getName, Collectors.mapping(Equipment::getId, Collectors.toList())));
    Map<String, EquipmentGroup> rows = new LinkedHashMap<>();
    int position = 0;
    for (Map.Entry<String, GroupSection> group : groups().entrySet()) {
      EquipmentGroup row = new EquipmentGroup();
      row.setId(UUID.randomUUID());
      row.setName(group.getKey());
      row.setSection(group.getValue());
      row.setPosition(++position);
      rows.put(group.getKey(), row);
    }
    parents().forEach(pair -> rows.get(pair.group()).getParentIds().add(rows.get(pair.other()).getId()));
    members().forEach(pair -> rows.get(pair.group()).getMemberIds().addAll(idsByName.getOrDefault(pair.other(), List.of())));
    return new ArrayList<>(rows.values());
  }

  private static String section(String sql, String start, String end) {
    int from = sql.indexOf(start);
    return end == null ? sql.substring(from) : sql.substring(from, sql.indexOf(end));
  }

  private static List<Pair> pairs(String sql) {
    List<Pair> pairs = new ArrayList<>();
    Matcher matcher = PAIR.matcher(sql);
    while (matcher.find()) {
      pairs.add(new Pair(unquote(matcher.group(1)), unquote(matcher.group(2))));
    }
    return pairs;
  }

  private static String unquote(String value) {
    return value.replace("''", "'");
  }

  private static String read(String resource) {
    try (InputStream in = GroupSeed.class.getResourceAsStream(resource)) {
      return new String(in.readAllBytes(), StandardCharsets.UTF_8);
    } catch (IOException e) {
      throw new UncheckedIOException(e);
    }
  }
}
