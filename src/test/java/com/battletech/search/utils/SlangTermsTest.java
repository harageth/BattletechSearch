package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.entities.AmbiguousSlang;
import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
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

/** The slang terms built from the real name files, for a handful of stored equipment rows. */
class SlangTermsTest {
  static final List<Equipment> STORED = new ArrayList<>();
  static final Map<String, Equipment> ROWS = new java.util.HashMap<>();

  static {
    for (String name : List.of("ac/20", "lb10-xac", "lrm20", "ppc", "erppc", "machinegun", "atm6", "atm12",
        "anti-missilesystem", "jumpjet", "mediumlaser", "streaksrm6", "machinegunammo[full]", "machinegunammo[half]",
        "mechmechanicaljumpboosters", "vibroblade(large)", "vibroblade(small)")) {
      for (Tech tech : List.of(Tech.INNER_SPHERE, Tech.CLAN)) {
        Equipment row = new Equipment(name, tech);
        row.setId(UUID.randomUUID());
        STORED.add(row);
        ROWS.put(name + "/" + tech, row);
      }
    }
  }

  static Equipment row(String name, Tech tech) {
    return ROWS.get(name + "/" + tech);
  }

  private static Map<String, Slang> terms(Set<String> userLookups) {
    return SlangTerms.build(STORED, userLookups).terms().stream()
        .collect(Collectors.toMap(Slang::getLookup, Function.identity()));
  }

  @Test
  void megaMekNamesStandForEveryTechOfTheEquipment() {
    Map<String, Slang> terms = terms(Set.of());
    // the display name and the internal names
    assertThat(terms.get("ac20").getEquipment()).containsExactlyInAnyOrder(row("ac/20", Tech.INNER_SPHERE), row("ac/20", Tech.CLAN));
    assertThat(terms.get("ac20").getKind()).isEqualTo(SlangKind.ALIAS);
    assertThat(terms.get("autocannon20").getEquipment()).isEqualTo(terms.get("ac20").getEquipment());
    assertThat(terms.get("lb10xac").getTerm()).isEqualTo("LB 10-X AC");
    assertThat(terms.get("lbxac10").getEquipment()).hasSize(2);
    assertThat(terms.get("mg").getEquipment()).contains(row("machinegun", Tech.INNER_SPHERE));
  }

  @Test
  void aTechPrefixLinksOnlyThatTech() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("cllrm20").getEquipment()).containsExactly(row("lrm20", Tech.CLAN));
    assertThat(terms.get("isac20").getEquipment()).containsExactly(row("ac/20", Tech.INNER_SPHERE));
  }

  @Test
  void onlyStoredEquipmentGetsTerms() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms).doesNotContainKey("gaussrifle");
    assertThat(terms.values()).allSatisfy(term -> assertThat(term.getEquipment()).isNotEmpty());
  }

  @Test
  void familiesStandForEveryWeaponInThem() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("lrms").getKind()).isEqualTo(SlangKind.FAMILY);
    assertThat(terms.get("lrms").getEquipment()).contains(row("lrm20", Tech.CLAN)).doesNotContain(row("streaksrm6", Tech.CLAN));
    assertThat(terms.get("streaks").getEquipment()).contains(row("streaksrm6", Tech.INNER_SPHERE));
    assertThat(terms.get("ppcs").getEquipment()).contains(row("ppc", Tech.CLAN), row("erppc", Tech.INNER_SPHERE));
    assertThat(terms.get("gaussrifles")).isNull();
  }

  @Test
  void aFamilyInTheSingularUnlessSomethingHasThatName() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("atm").getKind()).isEqualTo(SlangKind.FAMILY_SINGULAR);
    assertThat(terms.get("atm").getEquipment()).isEqualTo(terms.get("atms").getEquipment());
    assertThat(terms.get("laser").getKind()).isEqualTo(SlangKind.FAMILY_SINGULAR);
    // "ppc" is the PPC
    assertThat(terms.get("ppc").getKind()).isEqualTo(SlangKind.ALIAS);
    assertThat(terms.get("ppc").getEquipment()).containsExactlyInAnyOrder(row("ppc", Tech.INNER_SPHERE), row("ppc", Tech.CLAN));
  }

  @Test
  void handWrittenShorthand() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("ams").getKind()).isEqualTo(SlangKind.SHORTHAND);
    assertThat(terms.get("ams").getEquipment()).hasSize(2);
    assertThat(terms.get("jj").getEquipment()).contains(row("jumpjet", Tech.CLAN));
  }

  @Test
  void aShorthandTermOnSeveralLinesLinksEveryItem() {
    Map<String, Slang> terms = terms(Set.of());
    assertThat(terms.get("machinegunammo").getKind()).isEqualTo(SlangKind.SHORTHAND);
    assertThat(terms.get("machinegunammo").getEquipment()).containsExactlyInAnyOrder(
        row("machinegunammo[full]", Tech.INNER_SPHERE), row("machinegunammo[full]", Tech.CLAN),
        row("machinegunammo[half]", Tech.INNER_SPHERE), row("machinegunammo[half]", Tech.CLAN));
    // the battle armor booster isn't stored, so only the mech one is linked
    assertThat(terms.get("mechanicaljumpbooster").getEquipment()).hasSize(2);
    // every size of mech vibroblade; "vibro sword" also means the infantry blades, not stored here
    assertThat(terms.get("vibroblades").getEquipment()).containsExactlyInAnyOrder(
        row("vibroblade(large)", Tech.INNER_SPHERE), row("vibroblade(large)", Tech.CLAN),
        row("vibroblade(small)", Tech.INNER_SPHERE), row("vibroblade(small)", Tech.CLAN));
    assertThat(terms.get("vibrosword").getEquipment()).isEqualTo(terms.get("vibroblades").getEquipment());
  }

  /** Built without the shipped shorthand, which settles every key MegaMek gives to two items. */
  private static SlangTerms.Result withoutShorthand(Set<String> userLookups) {
    return SlangTerms.build(STORED, userLookups, EquipmentNames.readTsv(EquipmentNames.ALIASES),
        EquipmentNames.readTsv(EquipmentNames.FAMILIES), List.of());
  }

  @Test
  void theShorthandSettlesAmbiguousKeys() {
    assertThat(withoutShorthand(Set.of()).ambiguous()).extracting(AmbiguousSlang::getLookup).contains("machinegunammo");
    assertThat(SlangTerms.build(STORED, Set.of()).ambiguous()).extracting(AmbiguousSlang::getLookup)
        .doesNotContain("machinegunammo");
  }

  @Test
  void ambiguousKeysAreKeptForSomeoneToDecide() {
    SlangTerms.Result result = withoutShorthand(Set.of());
    assertThat(result.ambiguous()).isNotEmpty();
    Map<String, List<AmbiguousSlang>> byKey = result.ambiguous().stream()
        .collect(Collectors.groupingBy(AmbiguousSlang::getLookup));
    // each lists at least two candidates, and gets no term
    Map<String, Slang> terms = result.terms().stream().collect(Collectors.toMap(Slang::getLookup, Function.identity()));
    byKey.forEach((key, candidates) -> {
      assertThat(candidates.stream().map(AmbiguousSlang::getEquipmentName).distinct()).as(key).hasSizeGreaterThan(1);
      assertThat(terms).as(key).doesNotContainKey(key);
    });
  }

  @Test
  void slangAddedByHandIsLeftAlone() {
    String someAmbiguousKey = withoutShorthand(Set.of()).ambiguous().get(0).getLookup();
    SlangTerms.Result result = withoutShorthand(Set.of("ac20", someAmbiguousKey));
    assertThat(result.terms()).extracting(Slang::getLookup).doesNotContain("ac20");
    // a key someone decided isn't ambiguous any more
    assertThat(result.ambiguous()).extracting(AmbiguousSlang::getLookup).doesNotContain(someAmbiguousKey);
  }
}
