package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.model.Tech;
import org.junit.jupiter.api.Test;

class EquipmentNamesTest {

  @Test
  void stripsSpacesAndCase() {
    assertThat(EquipmentNames.normalize("Medium Laser")).isEqualTo("mediumlaser");
    assertThat(EquipmentNames.normalize("medium laser")).isEqualTo("mediumlaser");
    assertThat(EquipmentNames.normalize("MediumLaser")).isEqualTo("mediumlaser");
    assertThat(EquipmentNames.normalize("LRM 20")).isEqualTo("lrm20");
  }

  @Test
  void stripsMountingAnnotations() {
    assertThat(EquipmentNames.normalize("Medium Laser (R)")).isEqualTo("mediumlaser");
    assertThat(EquipmentNames.normalize("SRM 6 (I-OS)")).isEqualTo("srm6");
    assertThat(EquipmentNames.normalize("srm 2 (os)")).isEqualTo("srm2");
    assertThat(EquipmentNames.normalize("Streak SRM 2 (iOS)")).isEqualTo("streaksrm2");
    assertThat(EquipmentNames.normalize("Large Laser (ST)")).isEqualTo("largelaser");
  }

  @Test
  void mapsMegaMekNamesToTheDisplayName() {
    // .mtf weapon lines use display names, .blk files and critical slots internal / lookup names
    assertThat(EquipmentNames.canonical("AC/20")).isEqualTo("ac/20");
    assertThat(EquipmentNames.canonical("Autocannon/20")).isEqualTo("ac/20");
    assertThat(EquipmentNames.canonical("ISAC20")).isEqualTo("ac/20");
    assertThat(EquipmentNames.canonical("LBXAC10")).isEqualTo("lb10-xac");
    assertThat(EquipmentNames.canonical("UltraAC10")).isEqualTo("ultraac/10");
    assertThat(EquipmentNames.canonical("MG")).isEqualTo("machinegun");
    assertThat(EquipmentNames.canonical("LightMG")).isEqualTo("lightmachinegun");
    assertThat(EquipmentNames.canonical("AntiMissileSystem")).isEqualTo("anti-missilesystem");
    assertThat(EquipmentNames.canonical("RL10")).isEqualTo("rocketlauncher10");
    assertThat(EquipmentNames.canonical("SRM2 IOS")).isEqualTo("srm2");
    // ammo: tech goes in its own column, so "[Clan]" is dropped
    assertThat(EquipmentNames.canonical("Ammo AC/20")).isEqualTo("ac/20ammo");
    assertThat(EquipmentNames.canonical("Gauss Ammo")).isEqualTo("gaussrifleammo");
  }

  @Test
  void stripsTechSuffixesBeforeTheLookup() {
    assertThat(EquipmentNames.canonical("Gauss Rifle Ammo [Clan]")).isEqualTo("gaussrifleammo");
    assertThat(EquipmentNames.canonical("Anti-Missile System Ammo [IS]")).isEqualTo(EquipmentNames.canonical("IS Ammo AMS"));
  }

  @Test
  void mapsLowercasedPrefixedNames() {
    // search lowercases before the lookup, where the case-sensitive prefix check can't help
    assertThat(EquipmentNames.canonical("isac20")).isEqualTo("ac/20");
    assertThat(EquipmentNames.canonical("cllrm20")).isEqualTo("lrm20");
    assertThat(EquipmentNames.canonical("islbxac10")).isEqualTo("lb10-xac");
  }

  @Test
  void readsTheTechANameCarries() {
    assertThat(EquipmentNames.techOf("Gauss Rifle Ammo [Clan]")).isEqualTo(Tech.CLAN);
    assertThat(EquipmentNames.techOf("Anti-Missile System Ammo [IS]")).isEqualTo(Tech.INNER_SPHERE);
    assertThat(EquipmentNames.techOf("Ammo LRM-20 (Clan) Artemis-capable")).isEqualTo(Tech.CLAN);
    // MegaMek prefixes, also lowercased the way searches arrive
    assertThat(EquipmentNames.techOf("ISAC20")).isEqualTo(Tech.INNER_SPHERE);
    assertThat(EquipmentNames.techOf("isac20")).isEqualTo(Tech.INNER_SPHERE);
    assertThat(EquipmentNames.techOf("cllrm20")).isEqualTo(Tech.CLAN);
    assertThat(EquipmentNames.techOf("Clan Gauss Ammo")).isEqualTo(Tech.CLAN);
    // no tech of their own
    assertThat(EquipmentNames.techOf("ac/20")).isNull();
    assertThat(EquipmentNames.techOf("Gauss Rifle Ammo")).isNull();
    assertThat(EquipmentNames.techOf("lrm20")).isNull();
  }

  @Test
  void tagsAreDroppedFromTheName() {
    // the tech goes in its own column
    assertThat(EquipmentNames.normalize("Ammo LRM-20 (Clan) Artemis-capable")).isEqualTo("ammolrm-20artemis-capable");
    assertThat(EquipmentNames.canonical("Gauss Rifle Ammo [Clan]")).isEqualTo(EquipmentNames.canonical("Gauss Rifle Ammo"));
  }

  @Test
  void listsOlderSpellingsOfACanonicalName() {
    assertThat(EquipmentNames.equivalentNames("ac/2")).first().isEqualTo("ac/2");
    assertThat(EquipmentNames.equivalentNames("ac/2")).contains("autocannon/2", "ac2");
    assertThat(EquipmentNames.equivalentNames("lb10-xac")).contains("lbxac10");
    assertThat(EquipmentNames.equivalentNames("machinegun")).contains("mg");
    // unknown names are just themselves
    assertThat(EquipmentNames.equivalentNames("nonexistentgun")).containsExactly("nonexistentgun");
  }

  @Test
  void mapsWhatPeopleType() {
    assertThat(EquipmentNames.canonical("ac 20")).isEqualTo("ac/20");
    assertThat(EquipmentNames.canonical("lb 10-x ac")).isEqualTo("lb10-xac");
    assertThat(EquipmentNames.canonical("machine gun")).isEqualTo("machinegun");
    assertThat(EquipmentNames.canonical("lrm 20")).isEqualTo("lrm20");
    assertThat(EquipmentNames.canonical("extended lrm 20")).isEqualTo("extendedlrm20");
    assertThat(EquipmentNames.canonical("mrm 40")).isEqualTo("mrm40");
  }

  @Test
  void handWrittenShorthand() {
    assertThat(EquipmentNames.canonical("ams")).isEqualTo("anti-missilesystem");
    assertThat(EquipmentNames.canonical("AMS")).isEqualTo("anti-missilesystem");
    assertThat(EquipmentNames.canonical("jj")).isEqualTo("jumpjet");
    assertThat(EquipmentNames.canonical("Jump Jet")).isEqualTo("jumpjet");
    assertThat(EquipmentNames.canonical("VehicleJumpJet")).isEqualTo("jumpjet");
  }

  @Test
  void unknownNamesAreJustNormalized() {
    assertThat(EquipmentNames.canonical("Nonexistent Gun")).isEqualTo("nonexistentgun");
    assertThat(EquipmentNames.canonical("ml")).isEqualTo("ml");
  }

  @Test
  void keepsAnnotationsThatNameADifferentItem() {
    assertThat(EquipmentNames.normalize("Flamer (Vehicle)")).isEqualTo("flamer(vehicle)");
    assertThat(EquipmentNames.normalize("Anti-BattleArmor Pods (B-Pods)")).isEqualTo("anti-battlearmorpods(b-pods)");
    assertThat(EquipmentNames.normalize("Rifle (Cannon, Heavy)")).isEqualTo("rifle(cannon,heavy)");
  }
}
