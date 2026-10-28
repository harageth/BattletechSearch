package com.battletech.search.model;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.jupiter.api.Test;

class FireControlTest {

  @Test
  void readsEquipmentNames() {
    assertThat(FireControl.fromEquipmentName("ArtemisIV")).isEqualTo(FireControl.ARTEMIS_IV);
    assertThat(FireControl.fromEquipmentName("artemis v")).isEqualTo(FireControl.ARTEMIS_V);
    assertThat(FireControl.fromEquipmentName("Apollo")).isEqualTo(FireControl.APOLLO);
    assertThat(FireControl.fromEquipmentName("LRM 20")).isNull();
  }

  @Test
  void fitsMissileLaunchers() {
    assertThat(FireControl.ARTEMIS_IV.fits("LRM 20")).isTrue();
    assertThat(FireControl.ARTEMIS_IV.fits("srm6")).isTrue();
    assertThat(FireControl.ARTEMIS_V.fits("MML 9")).isTrue();
    assertThat(FireControl.ARTEMIS_IV.fits("Improved LRM 20")).isTrue();
    assertThat(FireControl.ARTEMIS_IV.fits("LRT 15")).isTrue();
    assertThat(FireControl.ARTEMIS_IV.fits("Streak SRM 6")).isFalse();
    assertThat(FireControl.ARTEMIS_IV.fits("Extended LRM 20")).isFalse();
    assertThat(FireControl.ARTEMIS_IV.fits("MRM 20")).isFalse();
    assertThat(FireControl.APOLLO.fits("MRM 40")).isTrue();
    assertThat(FireControl.APOLLO.fits("LRM 20")).isFalse();
  }

  @Test
  void splitsALeadingFireControlOffASearch() {
    assertThat(FireControl.fromSearch("artemislrm20"))
        .isEqualTo(new FireControl.Filter(Set.of(FireControl.ARTEMIS_IV, FireControl.ARTEMIS_V), "lrm20"));
    assertThat(FireControl.fromSearch("artemisivlrm20"))
        .isEqualTo(new FireControl.Filter(Set.of(FireControl.ARTEMIS_IV), "lrm20"));
    assertThat(FireControl.fromSearch("artemisvsrm6"))
        .isEqualTo(new FireControl.Filter(Set.of(FireControl.ARTEMIS_V), "srm6"));
    assertThat(FireControl.fromSearch("apollomrm40"))
        .isEqualTo(new FireControl.Filter(Set.of(FireControl.APOLLO), "mrm40"));
    assertThat(FireControl.fromSearch("lrm20")).isNull();
    // just the system on its own isn't a launcher search
    assertThat(FireControl.fromSearch("artemisiv")).isNull();
  }
}
