package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.entities.Equipment;
import com.battletech.search.model.GroupSection;
import com.battletech.search.model.Tech;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;

/** The group tree V3_17 writes (GroupSeed), on a database holding one row of every item it names. */
class EquipmentGroupsTest {
  private static final Map<String, Equipment> ROWS = new HashMap<>();
  private static final EquipmentGroups TREE;

  static {
    List<String> names = new ArrayList<>(GroupSeed.members().stream().map(GroupSeed.Pair::other).distinct().toList());
    names.add("targetingcomputer");
    names.forEach(name -> ROWS.put(name, row(name)));
    TREE = GroupSeed.tree(List.copyOf(ROWS.values()));
  }

  private static Equipment row(String name) {
    Equipment row = new Equipment(name, Tech.INNER_SPHERE);
    row.setId(UUID.randomUUID());
    return row;
  }

  private static Set<String> groupsOf(String name) {
    return TREE.groupsOf(ROWS.get(name).getId());
  }

  @Test
  void itemsAreInTheirGroupAndEveryGroupAboveIt() {
    assertThat(groupsOf("lrm20")).containsExactly("standard lrms", "lrms", "missiles");
    // two parents
    assertThat(groupsOf("streaksrm6")).containsExactly("streak srms", "srms", "streaks", "missiles");
    // ER lasers are standard lasers, and ER pulse, X-pulse and VSP lasers pulse lasers (user, 2026-11-01)
    assertThat(groupsOf("ermediumlaser")).containsExactly("er lasers", "standard lasers", "lasers", "energy weapons");
    assertThat(groupsOf("ermediumpulselaser")).containsExactly("er pulse lasers", "pulse lasers", "lasers", "energy weapons");
    assertThat(groupsOf("mediumx-pulselaser")).contains("x-pulse lasers", "pulse lasers").doesNotContain("standard lasers");
    assertThat(groupsOf("largevsplaser")).contains("vsp lasers", "pulse lasers");
    // in a group itself, not one under it
    assertThat(groupsOf("bombastlaser")).containsExactly("lasers", "energy weapons");
    assertThat(groupsOf("targetingcomputer")).isEmpty();
    // user, 2026-11-01: vibroblades under physical weapons; all ammo and the ECM suites are groups of the
    // equipment section, not under an "equipment" group
    assertThat(groupsOf("vibroblade(large)")).containsExactly("vibroblades", "physical weapons");
    assertThat(groupsOf("hatchet")).containsExactly("physical weapons");
    assertThat(ROWS.keySet().stream().filter(name -> name.contains("ammo")))
        .isNotEmpty().allSatisfy(ammo -> assertThat(groupsOf(ammo)).as(ammo).containsExactly("ammo"));
    // and what has ECM built in (user, 2026-11-01)
    for (String ecm : List.of("ecmsuite", "ecmsuite(guardian)", "angelecmsuite", "watchdogcompositeelectronicwarfaresystem(cews)",
        "novacombinedelectronicwarfaresystem(cews)", "electronicwarfareequipment")) {
      assertThat(groupsOf(ecm)).as(ecm).contains("ecm");
    }
    assertThat(groupsOf("narc")).containsExactly("narcs", "missiles");
    // user, 2026-11-01: the CEWS are probes too, and Nova is C3i (not plain C3); industrial tools are
    // physical weapons, shields equipment
    assertThat(groupsOf("watchdogcompositeelectronicwarfaresystem(cews)")).containsExactly("ecm", "probes");
    assertThat(groupsOf("novacombinedelectronicwarfaresystem(cews)")).containsExactlyInAnyOrder("ecm", "probes", "c3i", "c3");
    assertThat(TREE.directGroupsOf(ROWS.get("c3computer(master)").getId())).containsExactly("c3");
    assertThat(groupsOf("chainsaw")).containsExactly("industrial tools", "physical weapons");
    assertThat(groupsOf("trailerhitch")).containsExactly("industrial equipment");
    assertThat(groupsOf("shield(large)")).containsExactly("shields");
    assertThat(groupsOf("laserams")).containsExactly("ams");
    assertThat(groupsOf("heavymachinegunarray")).containsExactly("mg arrays", "ballistic weapons");
    assertThat(groupsOf("heavymachinegun")).containsExactly("machine guns", "ballistic weapons");
  }

  @Test
  void anItemCanBeInTwoGroupsOfItsOwn() {
    UUID erPulse = UUID.randomUUID();
    EquipmentGroups tree = EquipmentGroups.ofGroups(List.of(
        group("lasers", List.of(), GroupSection.WEAPONS),
        group("er lasers", List.of("lasers"), null, erPulse),
        group("pulse lasers", List.of("lasers"), null, erPulse)));
    assertThat(tree.directGroupsOf(erPulse)).containsExactly("er lasers", "pulse lasers");
    assertThat(tree.groupsOf(erPulse)).containsExactly("er lasers", "pulse lasers", "lasers");
    assertThat(tree.everythingIn("lasers")).containsExactly(erPulse);
  }

  @Test
  void aGroupHoldsEverythingUnderItAsDeepAsItGoes() {
    UUID lrm = ROWS.get("lrm20").getId();
    UUID streak = ROWS.get("streaksrm6").getId();
    assertThat(TREE.everythingIn("missiles")).contains(lrm, streak);
    assertThat(TREE.everythingIn("streaks")).contains(streak).doesNotContain(lrm);
    assertThat(TREE.everythingIn("standard lrms")).contains(lrm).doesNotContain(streak);
  }

  @Test
  void lrmsHoldEveryLrmType() {
    assertThat(TREE.children("lrms"))
        .containsExactly("standard lrms", "enhanced lrms", "extended lrms", "improved lrms", "streak lrms");
    for (String lrm : List.of("lrm5", "enhancedlrm10", "extendedlrm15", "improvedlrm20", "streaklrm20")) {
      assertThat(groupsOf(lrm)).as(lrm).contains("lrms");
    }
    assertThat(groupsOf("lrt20")).doesNotContain("lrms").contains("torpedoes", "missiles");
  }

  @Test
  void theTreeHangsTogether() {
    assertThat(TREE.top()).containsExactly(
        "missiles", "energy weapons", "ballistic weapons", "artillery", "physical weapons", "ams", "pods");
    // not weapons: their own section of the guide, and not in the search box's families
    assertThat(TREE.equipmentTop()).containsExactly("ammo", "ecm", "probes", "c3", "jump jets", "case", "myomers",
        "speed boosters", "stealth systems", "heat", "shields", "industrial equipment", "chassis mods", "drones", "cargo",
        "medical");
    // every group is under a top group of either section; ofGroups() checks the parents exist and there are no loops
    Set<String> reached = Stream.concat(TREE.top().stream(), TREE.equipmentTop().stream())
        .flatMap(top -> reachable(top).stream()).collect(Collectors.toSet());
    assertThat(reached).containsAll(TREE.groups().stream().map(EquipmentGroups.Group::term).toList());
    assertThat(TREE.familyLevel()).contains("lrms", "srms", "streaks", "lasers", "ppcs", "autocannons")
        .doesNotContain("missiles", "standard lrms", "improved atms", "ammo", "ecm");
    // every group has something in it, itself or under it
    assertThat(TREE.groups()).allSatisfy(group -> assertThat(TREE.everythingIn(group.term())).as(group.term()).isNotEmpty());
  }

  private Set<String> reachable(String term) {
    Set<String> found = new java.util.HashSet<>(Set.of(term));
    TREE.children(term).forEach(child -> found.addAll(reachable(child)));
    return found;
  }

  @Test
  void theTestDatabaseGetsTheMigrationsMembers() {
    assertThat(GroupSeed.testMembers()).containsExactlyElementsOf(GroupSeed.members());
  }

  @Test
  void everyGroupCanBeTyped() {
    // a search names them, and the guide lists them
    assertThat(TREE.groups()).allSatisfy(group -> assertThat(QueryVocabulary.isTypeable(group.term())).as(group.term()).isTrue());
  }

  @Test
  void aBrokenTreeIsRefused() {
    assertThatThrownBy(() -> EquipmentGroups.ofGroups(List.of(group("lrms", List.of("missiles"), null))))
        .hasMessageContaining("missiles, which isn't a group");
    assertThatThrownBy(() -> EquipmentGroups.ofGroups(List.of(group("a", List.of("b"), null), group("b", List.of("a"), null))))
        .hasMessageContaining("loop");
    assertThatThrownBy(() -> EquipmentGroups.ofGroups(List.of(group("a", List.of(), GroupSection.WEAPONS),
        group("a", List.of(), GroupSection.WEAPONS)))).hasMessageContaining("twice");
    assertThatThrownBy(() -> EquipmentGroups.ofGroups(List.of(group("a", List.of(), null))))
        .hasMessageContaining("no section");
    assertThatThrownBy(() -> EquipmentGroups.ofGroups(List.of(group("a", List.of(), GroupSection.WEAPONS),
        group("b", List.of("a"), GroupSection.EQUIPMENT)))).hasMessageContaining("has a section");
  }

  private static EquipmentGroups.Group group(String term, List<String> parents, GroupSection section, UUID... members) {
    return new EquipmentGroups.Group(UUID.randomUUID(), term, parents, section, Set.of(members));
  }
}
