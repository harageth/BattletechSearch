package com.battletech.search.utils;

import com.battletech.search.entities.EquipmentGroup;
import com.battletech.search.model.GroupSection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * The equipment group tree (the equipment_group tables): "missiles" holds "lrms", which holds
 * "standard lrms", "streak lrms", ... A search can name any level, and a group counts everything
 * under it. A group can sit under two others ("streak lrms" is in "lrms" and "streaks").
 */
public final class EquipmentGroups {

  /**
   * @param term what a search types, "standard lrms"
   * @param parents the groups it's in; empty for a top group
   * @param section the search guide's part a top group is in; null below the top
   * @param members ids of the equipment rows in the group itself (not through its children)
   */
  public record Group(UUID id, String term, List<String> parents, GroupSection section, Set<UUID> members) {
  }

  // in the search guide's order
  private final Map<String, Group> groups;
  private final Map<String, List<String>> children = new LinkedHashMap<>();
  // equipment id -> the groups it's in itself
  private final Map<UUID, List<String>> direct = new HashMap<>();

  private EquipmentGroups(Map<String, Group> groups) {
    this.groups = groups;
    groups.keySet().forEach(term -> children.put(term, new ArrayList<>()));
    for (Group group : groups.values()) {
      if (group.parents().isEmpty() != (group.section() != null)) {
        throw new IllegalStateException("Equipment group " + group.term()
            + (group.section() == null ? " is under no other group and has no section" : " is under another group and has a section"));
      }
      for (String parent : group.parents()) {
        if (!groups.containsKey(parent)) {
          throw new IllegalStateException("Equipment group " + group.term() + " is under " + parent + ", which isn't a group");
        }
        children.get(parent).add(group.term());
      }
      group.members().forEach(id -> direct.computeIfAbsent(id, k -> new ArrayList<>()).add(group.term()));
    }
    groups.keySet().forEach(term -> checkNoCycle(term, new LinkedHashSet<>()));
  }

  /** The tree from its table rows (EquipmentGroupRepository.findTree), in their order. */
  public static EquipmentGroups of(List<EquipmentGroup> rows) {
    Map<UUID, String> names = new HashMap<>();
    rows.forEach(row -> names.put(row.getId(), row.getName()));
    return ofGroups(rows.stream().map(row -> new Group(row.getId(), row.getName(),
        row.getParentIds().stream().map(names::get).sorted().toList(), row.getSection(), Set.copyOf(row.getMemberIds())))
        .toList());
  }

  static EquipmentGroups ofGroups(List<Group> list) {
    Map<String, Group> groups = new LinkedHashMap<>();
    for (Group group : list) {
      if (groups.put(group.term(), group) != null) {
        throw new IllegalStateException("Equipment group " + group.term() + " is listed twice");
      }
    }
    return new EquipmentGroups(groups);
  }

  public List<Group> groups() {
    return List.copyOf(groups.values());
  }

  /** The weapon groups under no other ("missiles", "energy weapons", ...). */
  public List<String> top() {
    return top(GroupSection.WEAPONS);
  }

  /** The top groups of the search guide's equipment section ("ammo", "ecm"). */
  public List<String> equipmentTop() {
    return top(GroupSection.EQUIPMENT);
  }

  private List<String> top(GroupSection section) {
    return groups.values().stream().filter(group -> group.section() == section).map(Group::term).toList();
  }

  /** The groups right under this one. */
  public List<String> children(String term) {
    return children.getOrDefault(term, List.of());
  }

  /**
   * The groups right under a top group ("lrms", "lasers", "autocannons"): what the search box offers
   * in place of each other, the way the weapon families were.
   */
  public List<String> familyLevel() {
    Set<String> top = new HashSet<>(top());
    return groups.values().stream().filter(group -> group.parents().stream().anyMatch(top::contains))
        .map(Group::term).toList();
  }

  /** The groups this equipment row is in itself. */
  public List<String> directGroupsOf(UUID equipmentId) {
    return direct.getOrDefault(equipmentId, List.of());
  }

  /** Every group this equipment row is in, its own and the ones above them, nearest first. */
  public Set<String> groupsOf(UUID equipmentId) {
    Set<String> found = new LinkedHashSet<>();
    List<String> next = directGroupsOf(equipmentId);
    while (!next.isEmpty()) {
      List<String> above = new ArrayList<>();
      for (String term : next) {
        if (found.add(term)) {
          above.addAll(groups.get(term).parents());
        }
      }
      next = above;
    }
    return found;
  }

  /** The equipment rows in a group and every group under it. */
  public Set<UUID> everythingIn(String term) {
    Set<UUID> found = new LinkedHashSet<>();
    collect(term, new HashSet<>(), found);
    return found;
  }

  private void collect(String term, Set<String> seen, Set<UUID> found) {
    if (seen.add(term)) {
      found.addAll(groups.get(term).members());
      children(term).forEach(child -> collect(child, seen, found));
    }
  }

  private void checkNoCycle(String term, Set<String> path) {
    if (!path.add(term)) {
      throw new IllegalStateException("Equipment groups loop: " + String.join(" > ", path) + " > " + term);
    }
    for (String parent : groups.get(term).parents()) {
      checkNoCycle(parent, new LinkedHashSet<>(path));
    }
  }
}
