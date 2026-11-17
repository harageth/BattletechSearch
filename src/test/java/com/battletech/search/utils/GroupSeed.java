package com.battletech.search.utils;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.EquipmentGroup;
import com.battletech.search.model.GroupSection;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
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
 * V3_20 and V3_23 add groups to it (the ammo groups, environmental sealing, infantry weapons, transport bays), add items
 * to groups and move items out of the group above into them, statement by statement.
 */
public final class GroupSeed {
  static final String MIGRATION = "/db/migration/V3_17__equipment_group_rows.sql";
  static final List<String> GROUPS_MIGRATIONS = List.of("/db/migration/V3_20__ammo_groups.sql",
      "/db/migration/V3_23__support_vehicle_groups.sql");
  static final String TEST_MEMBERS = "/db/equipment-group-members.sql";

  private static final Pattern GROUP = Pattern.compile("\\(gen_random_uuid\\(\\), '((?:[^']|'')*)', (?:NULL|'(\\w+)'), (\\d+)\\)");
  private static final Pattern PAIR = Pattern.compile("^\\s+\\('((?:[^']|'')*)', '((?:[^']|'')*)'\\)", Pattern.MULTILINE);
  // V3_20 makes room for its groups: "SET position = position + 22 WHERE position > 58"
  private static final Pattern SHIFT = Pattern.compile("SET position = position \\+ (\\d+) WHERE position > (\\d+)");
  // and moves items out of the group above: "a.name = 'ammo'"
  private static final Pattern MOVED_OUT_OF = Pattern.compile("a\\.name = '((?:[^']|'')*)'");

  /** A row of the seed: a group and one of its parents, or a group and an equipment name in it. */
  record Pair(String group, String other) {
  }

  private GroupSeed() {
  }

  /** The group names, in the guide's order, and the section of each top group. */
  static Map<String, GroupSection> groups() {
    Map<String, GroupSection> sections = new HashMap<>();
    Map<String, Integer> positions = new HashMap<>();
    addGroups(read(MIGRATION), sections, positions);
    for (String statement : groupsStatements()) {
      Matcher shift = SHIFT.matcher(statement);
      if (shift.find()) {
        int by = Integer.parseInt(shift.group(1));
        int after = Integer.parseInt(shift.group(2));
        positions.replaceAll((name, position) -> position > after ? position + by : position);
      } else if (statement.startsWith("INSERT INTO equipment_group ")) {
        addGroups(statement, sections, positions);
      }
    }
    TreeMap<Integer, String> byPosition = new TreeMap<>();
    positions.forEach((name, position) -> byPosition.put(position, name));
    Map<String, GroupSection> groups = new LinkedHashMap<>();
    byPosition.values().forEach(name -> groups.put(name, sections.get(name)));
    return groups;
  }

  private static void addGroups(String sql, Map<String, GroupSection> sections, Map<String, Integer> positions) {
    Matcher matcher = GROUP.matcher(sql);
    while (matcher.find()) {
      String name = unquote(matcher.group(1));
      positions.put(name, Integer.parseInt(matcher.group(3)));
      sections.put(name, matcher.group(2) == null ? null : GroupSection.valueOf(matcher.group(2)));
    }
  }

  static List<Pair> parents() {
    List<Pair> parents = pairs(section(read(MIGRATION), "INSERT INTO equipment_group_parent", "INSERT INTO equipment_group_member"));
    groupsStatements().stream().filter(statement -> statement.startsWith("INSERT INTO equipment_group_parent"))
        .forEach(statement -> parents.addAll(pairs(statement)));
    return parents;
  }

  static List<Pair> members() {
    List<Pair> members = pairs(section(read(MIGRATION), "INSERT INTO equipment_group_member", null));
    // db/data/V3_22 renames the troop space V3_17 calls the infantry bay, before V3_23 moves it
    members.replaceAll(pair -> pair.other().equals("infantrybay") ? new Pair(pair.group(), "infantrycompartment") : pair);
    for (String statement : groupsStatements()) {
      if (statement.startsWith("INSERT INTO equipment_group_member")) {
        members.addAll(pairs(statement));
      } else if (statement.startsWith("WITH moved")) {
        List<Pair> moved = pairs(statement);
        Matcher outOf = MOVED_OUT_OF.matcher(statement);
        outOf.find();
        Set<String> movedNames = moved.stream().map(Pair::other).collect(Collectors.toSet());
        members.removeIf(pair -> pair.group().equals(unquote(outOf.group(1))) && movedNames.contains(pair.other()));
        members.addAll(moved);
      }
    }
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

  private static List<String> groupsStatements() {
    return GROUPS_MIGRATIONS.stream().flatMap(migration -> statements(read(migration)).stream()).toList();
  }

  // a migration's statements, without its comments (a comment can hold a ";")
  private static List<String> statements(String sql) {
    String code = sql.lines().filter(line -> !line.stripLeading().startsWith("--")).collect(Collectors.joining("\n"));
    return Arrays.stream(code.split(";")).map(String::strip).filter(statement -> !statement.isEmpty()).toList();
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
