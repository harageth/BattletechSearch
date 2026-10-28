package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.Heatsinks.HeatsinkType;
import com.battletech.search.model.Location;
import com.battletech.search.model.Locomotion;
import com.battletech.search.model.Tech;
import com.battletech.search.model.WeightClass;
import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.util.List;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

/**
 * Parses real MegaMek files copied from MegaMek/mm-data (see the importers skill for the pinned
 * commit). Disabled tests describe the correct result for known bugs listed in the importers skill;
 * enable each one when its bug is fixed.
 */
class ReadMegaMekTest {

  private static File fixture(String path) {
    try {
      return Path.of(ReadMegaMekTest.class.getResource("/megamek/" + path).toURI()).toFile();
    } catch (URISyntaxException e) {
      throw new IllegalStateException(e);
    }
  }

  private static Mech mech(String file) throws IOException {
    return (Mech) ReadMegaMek.ReadMechMTF(fixture("meks/" + file));
  }

  private static Unit vehicle(String file) throws IOException {
    return ReadMegaMek.ReadVehicleBlk(fixture("vehicles/" + file));
  }

  private static List<UnitEquipment> at(Unit unit, Location location) {
    return unit.getMechEquipment().stream().filter(equip -> equip.getLocation() == location).toList();
  }

  // --- mechs ---

  @Test
  void readsMechHeaderFields() throws IOException {
    Mech atlas = mech("Atlas AS7-D.mtf");

    assertThat(atlas.getName()).isEqualTo("Atlas");
    assertThat(atlas.getDesignation()).isEqualTo("AS7-D");
    assertThat(atlas.getTech()).isEqualTo(Tech.INNER_SPHERE);
    assertThat(atlas.getWeight()).isEqualTo(100);
    assertThat(atlas.getWeightClass()).isEqualTo(WeightClass.ASSAULT);
    assertThat(atlas.getEra()).isEqualTo("2755");
    assertThat(atlas.getRulesLevel()).isEqualTo(1);
    assertThat(atlas.getLocomotion()).isEqualTo(Locomotion.BIPED);
    assertThat(atlas.getEngine()).isEqualTo("300 Fusion Engine");
    assertThat(atlas.getMovement().getWalk()).isEqualTo(3);
    assertThat(atlas.getMovement().getJump()).isZero();
    assertThat(atlas.getHeatsinks().getHeatsinkQuantity()).isEqualTo(20);
    assertThat(atlas.getHeatsinks().getType()).isEqualTo(HeatsinkType.SINGLE);
  }

  @Test
  void readsMechWeapons() throws IOException {
    assertThat(mech("Atlas AS7-D.mtf").getMechEquipment())
        .extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getLocation)
        .containsExactly(
            tuple("mediumlaser", Location.LEFT_ARM),
            tuple("mediumlaser", Location.RIGHT_ARM),
            tuple("lrm20", Location.LEFT_TORSO),
            tuple("srm6", Location.LEFT_TORSO),
            tuple("ac/20", Location.RIGHT_TORSO),
            tuple("mediumlaser", Location.CENTER_TORSO),
            tuple("mediumlaser", Location.CENTER_TORSO));
  }

  @Test
  void weaponsTakeTheUnitTech() throws IOException {
    // weapon lines don't say IS or Clan, so each weapon gets the mech's tech
    assertThat(mech("Mad Cat (Timber Wolf) Prime.mtf").getMechEquipment())
        .extracting(equip -> equip.getEquipment().getTech())
        .containsOnly(Tech.CLAN);
  }

  @Test
  void weaponNamesCanContainCommas() throws IOException {
    assertThat(mech("Deep Lord RCL-Z1M MilitiaMech.mtf").getMechEquipment())
        .extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getLocation)
        .containsExactly(
            tuple("rifle(cannon,heavy)", Location.LEFT_TORSO),
            tuple("srm6", Location.RIGHT_TORSO));
  }

  @Test
  void readsMechConfigurations() throws IOException {
    Mech madCat = mech("Mad Cat (Timber Wolf) Prime.mtf");
    assertThat(madCat.getName()).isEqualTo("Mad Cat");
    assertThat(madCat.getDesignation()).isEqualTo("Prime");
    assertThat(madCat.getTech()).isEqualTo(Tech.CLAN);
    // "Biped OmniMek"
    assertThat(madCat.getLocomotion()).isEqualTo(Locomotion.BIPED);

    assertThat(mech("Goliath GOL-1M.mtf").getLocomotion()).isEqualTo(Locomotion.QUAD);
  }

  @Disabled("importers skill bug 5: Mixed (IS Chassis) isn't mapped to a tech")
  @Test
  void mixedTechMech() throws IOException {
    assertThat(mech("Black Knight BL-6-RR.mtf").getTech()).isEqualTo(Tech.MIXED_TECH);
  }

  @Disabled("importers skill bug 18: '17 Clan Double' / '20 IS Double' heat sinks aren't recognized")
  @Test
  void doubleHeatSinks() throws IOException {
    assertThat(mech("Mad Cat (Timber Wolf) Prime.mtf").getHeatsinks().getType()).isEqualTo(HeatsinkType.DOUBLE);
  }

  // --- vehicles ---

  @Test
  void readsTanks() throws IOException {
    Unit bulldog = vehicle("Bulldog Medium Tank (AC2).blk");

    assertThat(bulldog).isExactlyInstanceOf(Tank.class);
    // names are lowercased on import (importers skill bug 17)
    assertThat(bulldog.getName()).isEqualToIgnoringCase("Bulldog Medium Tank");
    assertThat(bulldog.getDesignation()).isEqualToIgnoringCase("(AC2)");
    assertThat(bulldog.getTech()).isEqualTo(Tech.INNER_SPHERE);
    assertThat(bulldog.getWeight()).isEqualTo(60);
    assertThat(bulldog.getMovement().getWalk()).isEqualTo(4);
    assertThat(at(bulldog, Location.FRONT)).extracting(equip -> equip.getEquipment().getName())
        .containsExactly("machine gun", "machine gun");
    assertThat(at(bulldog, Location.FRONTTURRET)).extracting(equip -> equip.getEquipment().getName())
        .containsExactly("srm 4", "srm 4", "autocannon/2", "autocannon/2");
  }

  @Test
  void readsAllSidesOfATank() throws IOException {
    Unit puma = vehicle("Puma Assault Tank PAT-001.blk");

    assertThat(at(puma, Location.FRONT)).hasSize(3);
    assertThat(at(puma, Location.LEFT)).extracting(equip -> equip.getEquipment().getName()).containsExactly("lrm 20");
    assertThat(at(puma, Location.RIGHT)).extracting(equip -> equip.getEquipment().getName()).containsExactly("lrm 20");
    assertThat(at(puma, Location.REAR)).hasSize(2);
    assertThat(at(puma, Location.FRONTTURRET)).extracting(equip -> equip.getEquipment().getName()).containsExactly("ppc");
  }

  @Test
  void readsVtolsAndHovercraft() throws IOException {
    Unit warrior = vehicle("Warrior H-7 Attack Helicopter.blk");
    assertThat(warrior).isExactlyInstanceOf(Vtol.class);
    assertThat(at(warrior, Location.FRONT)).extracting(equip -> equip.getEquipment().getName())
        .containsExactly("srm 4", "autocannon/2");

    // motive type isn't stored yet (importers skill bug 12), so a hover tank is just a Tank
    assertThat(vehicle("Condor Heavy Hover Tank (Davion).blk")).isExactlyInstanceOf(Tank.class);
  }

  @Test
  void clanPrefixesSetTheEquipmentTech() throws IOException {
    assertThat(at(vehicle("Chalchiuhtotolin Support Tank (Bombast Laser).blk"), Location.FRONT))
        .extracting(equip -> equip.getEquipment().getName(), equip -> equip.getEquipment().getTech())
        .containsExactly(tuple("lightmg", Tech.CLAN));
  }

  @Test
  void skipsSupportVehicles() throws IOException {
    // importers skill bug 13; also checks a one-line <Model></Model> doesn't break parsing
    assertThat(vehicle("Air Car.blk")).isNull();
  }

  @Disabled("importers skill bug 10: <Body Equipment> is never imported")
  @Test
  void readsBodyEquipment() throws IOException {
    assertThat(at(vehicle("Bulldog Medium Tank (AC2).blk"), Location.BODY)).hasSize(3);
  }

  @Disabled("importers skill bug 11: 'Mixed (Clan Chassis)' contains \"is\" and becomes INNER_SPHERE")
  @Test
  void mixedTechVehicle() throws IOException {
    assertThat(vehicle("Chalchiuhtotolin Support Tank (Bombast Laser).blk").getTech()).isEqualTo(Tech.MIXED_TECH);
  }
}
