package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

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
