package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.entities.AmbiguousSlang;
import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.GroupSection;
import com.battletech.search.model.SlangKind;
import com.battletech.search.model.Tech;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Test;

/**
 * The slang terms built from the MegaMek names and the groups, for a handful of stored equipment rows.
 * The hand-written terms (V3_19) are tested on imported units, in UnitServiceImportTest.
 */
class SlangTermsTest {
  static final List<Equipment> STORED = new ArrayList<>();
  static final Map<String, Equipment> ROWS = new java.util.HashMap<>();

  static {
    for (String name : List.of("ac/20", "lb10-xac", "lrm20", "ppc", "erppc", "machinegun", "atm6", "atm12",
        "anti-missilesystem", "jumpjet", "mediumlaser", "streaksrm6", "machinegunammo[full]", "machinegunammo[half]",
        "mechmechanicaljumpboosters", "vibroblade(large)", "vibroblade(small)", "mashequipment",
        "paramedicequipment")) {
      for (Tech tech : List.of(Tech.INNER_SPHERE, Tech.CLAN)) {
        Equipment row = new Equipment(name, tech);
        row.setId(UUID.randomUUID());
        STORED.add(row);
        ROWS.put(name + "/" + tech, row);
      }
    }
  }

  // the groups V3_17 makes for these rows
  static final EquipmentGroups TREE = GroupSeed.tree(STORED);

  static Equipment row(String name, Tech tech) {
    return ROWS.get(name + "/" + tech);
  }

  /** The rows a term stands for: its own, or for a group's term everything in the group. */
  static Set<Equipment> stands(Slang term) {
    if (term.getEquipmentGroupId() == null) {
      return term.getEquipment();
    }
    String group = TREE.groups().stream().filter(g -> g.id().equals(term.getEquipmentGroupId()))
        .findFirst().orElseThrow().term();
    Set<UUID> ids = TREE.everythingIn(group);
    return STORED.stream().filter(row -> ids.contains(row.getId())).collect(Collectors.toSet());
  }

  private static Map<String, Slang> terms(Set<String> handWritten) {
    return SlangTerms.build(STORED, handWritten, TREE).terms().stream()
        .collect(Collectors.toMap(Slang::getLookup, Function.identity()));
  }

  @Test
  void megaMekNamesStandForEveryTechOfTheEquipment() {
    Map<String, Slang> terms = terms(Set.of());
    // the display name and the internal names
    assertThat(stands(terms.get("ac20"))).containsExactlyInAnyOrder(row("ac/20", Tech.INNER_SPHERE), row("ac/20", Tech.CLAN));
    assertThat(terms.get("ac20").getKind()).isEqualTo(SlangKind.ALIAS);
    assertThat(stands(terms.get("autocannon20"))).isEqualTo(stands(terms.get("ac20")));
    assertThat(terms.get("lb10xac").getTerm()).isEqualTo("LB 10-X AC");
    assertThat(stands(terms.get("lbxac10"))).hasSize(2);
    assertThat(stands(terms.get("mg"))).contains(row("machinegun", Tech.INNER_SPHERE));
  }

  @Test
  void aTechPrefixLinksOnlyThatTech() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(stands(terms.get("cllrm20"))).containsExactly(row("lrm20", Tech.CLAN));
    assertThat(stands(terms.get("isac20"))).containsExactly(row("ac/20", Tech.INNER_SPHERE));
  }

  @Test
  void onlyStoredEquipmentGetsTerms() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms).doesNotContainKey("gaussrifle");
    assertThat(terms.values()).allSatisfy(term -> assertThat(stands(term)).isNotEmpty());
  }

  @Test
  void familiesStandForEveryWeaponInThem() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("lrms").getKind()).isEqualTo(SlangKind.FAMILY);
    assertThat(stands(terms.get("lrms"))).contains(row("lrm20", Tech.CLAN)).doesNotContain(row("streaksrm6", Tech.CLAN));
    assertThat(stands(terms.get("streaks"))).contains(row("streaksrm6", Tech.INNER_SPHERE));
    assertThat(stands(terms.get("ppcs"))).contains(row("ppc", Tech.CLAN), row("erppc", Tech.INNER_SPHERE));
    assertThat(terms.get("gaussrifles")).isNull();
  }

  @Test
  void aGroupHoldsEverythingInTheGroupsUnderIt() {
    Map<String, Slang> terms = terms(Set.of());
    // missiles > lrms > standard lrms > LRM 20
    assertThat(terms.get("missiles").getKind()).isEqualTo(SlangKind.FAMILY);
    assertThat(stands(terms.get("missiles"))).contains(row("lrm20", Tech.CLAN), row("streaksrm6", Tech.INNER_SPHERE),
        row("atm12", Tech.CLAN)).doesNotContain(row("mediumlaser", Tech.CLAN));
    assertThat(stands(terms.get("standardlrms")))
        .containsExactlyInAnyOrder(row("lrm20", Tech.INNER_SPHERE), row("lrm20", Tech.CLAN));
    // streak srms are under srms and streaks both
    assertThat(stands(terms.get("srms"))).contains(row("streaksrm6", Tech.CLAN));
    assertThat(stands(terms.get("streaksrms")))
        .containsExactlyInAnyOrder(row("streaksrm6", Tech.INNER_SPHERE), row("streaksrm6", Tech.CLAN));
    assertThat(stands(terms.get("energyweapons"))).contains(row("mediumlaser", Tech.CLAN), row("erppc", Tech.CLAN));
    assertThat(terms.get("energyweapon").getKind()).isEqualTo(SlangKind.FAMILY_SINGULAR);
    // nothing stored in it, no term
    assertThat(terms).doesNotContainKey("thunderbolts");
  }

  @Test
  void aGroupTermNamesTheGroupAndLinksNoRows() {
    Slang lrms = terms(Set.of()).get("lrms");
    assertThat(lrms.getEquipmentGroupId()).isEqualTo(TREE.groups().stream()
        .filter(group -> group.term().equals("lrms")).findFirst().orElseThrow().id());
    assertThat(lrms.getEquipment()).isEmpty();
  }

  @Test
  void aGroupNotEndingInSHasNoSingular() {
    EquipmentGroups groups = EquipmentGroups.ofGroups(List.of(new EquipmentGroups.Group(UUID.randomUUID(), "artillery",
        List.of(), GroupSection.WEAPONS, Set.of(row("ac/20", Tech.INNER_SPHERE).getId(), row("ac/20", Tech.CLAN).getId()))));
    Map<String, Slang> terms = SlangTerms.build(STORED, Set.of(), List.of(), groups).terms().stream()
        .collect(Collectors.toMap(Slang::getLookup, Function.identity()));
    assertThat(groups.everythingIn("artillery")).hasSize(2);
    assertThat(terms.get("artillery").getKind()).isEqualTo(SlangKind.FAMILY);
    assertThat(terms).doesNotContainKey("artiller");
  }

  @Test
  void aFamilyInTheSingularUnlessSomethingHasThatName() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("atm").getKind()).isEqualTo(SlangKind.FAMILY_SINGULAR);
    assertThat(stands(terms.get("atm"))).isEqualTo(stands(terms.get("atms")));
    assertThat(terms.get("laser").getKind()).isEqualTo(SlangKind.FAMILY_SINGULAR);
    // "ppc" is the PPC
    assertThat(terms.get("ppc").getKind()).isEqualTo(SlangKind.ALIAS);
    assertThat(stands(terms.get("ppc"))).containsExactlyInAnyOrder(row("ppc", Tech.INNER_SPHERE), row("ppc", Tech.CLAN));
  }

  @Test
  void aGroupWinsOverAMegaMekNameButNotOverAHandWrittenTerm() {
    // "ams" is every anti-missile system (user, 2026-11-01)
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("ams").getKind()).isEqualTo(SlangKind.FAMILY);
    assertThat(stands(terms.get("ams"))).hasSize(2);
    assertThat(terms).doesNotContainKey("am");
    // a hand-written "ams" keeps the word, and the group is reported (user, 2026-11-13)
    SlangTerms.Result result = SlangTerms.build(STORED, Set.of("ams"), TREE);
    assertThat(result.terms()).extracting(Slang::getLookup).doesNotContain("ams");
    assertThat(result.groupsWithoutTerm()).containsExactly("ams");
    assertThat(SlangTerms.build(STORED, Set.of(), TREE).groupsWithoutTerm()).isEmpty();
    // nor its singular: a hand-written "lasers" leaves the group no "laser"
    assertThat(terms.get("laser").getKind()).isEqualTo(SlangKind.FAMILY_SINGULAR);
    SlangTerms.Result lasers = SlangTerms.build(STORED, Set.of("lasers"), TREE);
    assertThat(lasers.terms()).extracting(Slang::getLookup).doesNotContain("lasers", "laser");
    assertThat(lasers.groupsWithoutTerm()).containsExactly("lasers");
  }

  @Test
  void aHandWrittenTermSettlesAnAmbiguousKey() {
    // MegaMek names the full and half ton bins alike; the shorthand "machine gun ammo" links both
    assertThat(SlangTerms.build(STORED, Set.of(), TREE).ambiguous()).extracting(AmbiguousSlang::getLookup)
        .contains("machinegunammo");
    assertThat(SlangTerms.build(STORED, Set.of("machinegunammo"), TREE).ambiguous()).extracting(AmbiguousSlang::getLookup)
        .doesNotContain("machinegunammo");
  }

  @Test
  void ambiguousKeysAreKeptForSomeoneToDecide() {
    SlangTerms.Result result = SlangTerms.build(STORED, Set.of(), TREE);
    assertThat(result.ambiguous()).isNotEmpty();
    Map<String, List<AmbiguousSlang>> byKey = result.ambiguous().stream()
        .collect(Collectors.groupingBy(AmbiguousSlang::getLookup));
    // each lists at least two candidates, and gets no term
    Map<String, Slang> terms = result.terms().stream().collect(Collectors.toMap(Slang::getLookup, Function.identity()));
    byKey.forEach((key, candidates) -> {
      assertThat(candidates.stream().map(AmbiguousSlang::getEquipmentName).distinct()).as(key).hasSizeGreaterThan(1);
      assertThat(terms).as(key).doesNotContainKey(key);
    });
    // only keys of something a unit has: no pulse laser rifle is stored
    assertThat(byKey).containsKey("machinegunammo").doesNotContainKey("pulselaserrifle");
  }

  @Test
  void slangAddedByHandIsLeftAlone() {
    String someAmbiguousKey = SlangTerms.build(STORED, Set.of(), TREE).ambiguous().get(0).getLookup();
    SlangTerms.Result result = SlangTerms.build(STORED, Set.of("ac20", someAmbiguousKey), TREE);
    assertThat(result.terms()).extracting(Slang::getLookup).doesNotContain("ac20");
    // a key someone decided isn't ambiguous any more
    assertThat(result.ambiguous()).extracting(AmbiguousSlang::getLookup).doesNotContain(someAmbiguousKey);
  }
}
