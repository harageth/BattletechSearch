package com.battletech.search.utils;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.EquipmentGroup;
import com.battletech.search.model.GroupSection;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * The equipment group tree as the V3_17 migration writes it, for tests without a database: its groups,
 * parents and (group, equipment name) members, read from the migration file.
 */
public final class GroupSeed {
  static final String MIGRATION = "/db/migration/V3_17__equipment_group_rows.sql";
  static final String TEST_MEMBERS = "/db/equipment-group-members.sql";

  private static final Pattern GROUP = Pattern.compile("\\(gen_random_uuid\\(\\), '((?:[^']|'')*)', (?:NULL|'(\\w+)'), \\d+\\)");
  private static final Pattern PAIR = Pattern.compile("^\\s+\\('((?:[^']|'')*)', '((?:[^']|'')*)'\\)", Pattern.MULTILINE);

  /** A row of the seed: a group and one of its parents, or a group and an equipment name in it. */
  record Pair(String group, String other) {
  }

  private GroupSeed() {
  }

  /** The group names, in order, and the section of each top group. */
  static Map<String, GroupSection> groups() {
    Map<String, GroupSection> groups = new LinkedHashMap<>();
    Matcher matcher = GROUP.matcher(read(MIGRATION));
    while (matcher.find()) {
      groups.put(unquote(matcher.group(1)), matcher.group(2) == null ? null : GroupSection.valueOf(matcher.group(2)));
    }
    return groups;
  }

  static List<Pair> parents() {
    return pairs(section(read(MIGRATION), "INSERT INTO equipment_group_parent", "INSERT INTO equipment_group_member"));
  }

  static List<Pair> members() {
    return pairs(section(read(MIGRATION), "INSERT INTO equipment_group_member", null));
  }

  /** The members db/equipment-group-members.sql gives the test database. */
  static List<Pair> testMembers() {
    return pairs(read(TEST_MEMBERS));
  }

  /** The tree V3_17 makes on a database holding these equipment rows. */
  public static EquipmentGroups tree(List<Equipment> stored) {
    return EquipmentGroups.of(rows(stored));
  }

  /** The equipment_group rows V3_17 writes on a database holding these equipment rows, in order. */
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
