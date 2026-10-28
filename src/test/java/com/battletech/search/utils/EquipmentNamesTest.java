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
  void keepsAnnotationsThatNameADifferentItem() {
    assertThat(EquipmentNames.normalize("Flamer (Vehicle)")).isEqualTo("flamer(vehicle)");
    assertThat(EquipmentNames.normalize("Anti-BattleArmor Pods (B-Pods)")).isEqualTo("anti-battlearmorpods(b-pods)");
    assertThat(EquipmentNames.normalize("Rifle (Cannon, Heavy)")).isEqualTo("rifle(cannon,heavy)");
  }
}
