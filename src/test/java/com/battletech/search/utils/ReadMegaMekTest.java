package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.FireControl;
import com.battletech.search.model.Heatsinks.HeatsinkType;
import com.battletech.search.model.Location;
import com.battletech.search.model.Locomotion;
import com.battletech.search.model.MotiveSystem;
import com.battletech.search.model.Tech;
import com.battletech.search.model.WeightClass;
import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

/**
 * Parses real MegaMek files copied from MegaMek/mm-data (see the importers skill for the pinned
 * commit). When fixing a bug from the importers skill, add a test here with the correct result.
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
            tuple("mediumlaser", Location.CENTER_TORSO),
            // then the ammo from the critical slots, one per ton
            tuple("ammolrm-20", Location.LEFT_TORSO),
            tuple("ammolrm-20", Location.LEFT_TORSO),
            tuple("ammosrm-6", Location.LEFT_TORSO),
            tuple("ammoac/20", Location.RIGHT_TORSO),
            tuple("ammoac/20", Location.RIGHT_TORSO));
  }

  @Test
  void readsAmmoAndEquipmentFromSlots() throws IOException {
    // "Clan Ammo LRM-20 (OMNIPOD)": prefix gives the tech, the mounting note is dropped
    assertThat(mech("Mad Cat (Timber Wolf) Prime.mtf").getMechEquipment())
        .extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getLocation, equip -> equip.getEquipment().getTech())
        .endsWith(
            tuple("ammolrm-20", Location.LEFT_TORSO, Tech.CLAN),
            tuple("ammolrm-20", Location.RIGHT_TORSO, Tech.CLAN),
            tuple("machinegunammo-full", Location.RIGHT_TORSO, Tech.CLAN));

    // the probe fills two slots but is one piece of equipment
    assertThat(mech("Black Knight BL-6-RR.mtf").getMechEquipment())
        .extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getLocation, equip -> equip.getEquipment().getTech())
        .containsOnlyOnce(tuple("beagleactiveprobe", Location.CENTER_TORSO, Tech.INNER_SPHERE));
  }

  @Test
  void slotEquipmentIsAllowListed() {
    Map<String, List<String>> slots = new LinkedHashMap<>();
    // a weapon's slots, spelled unlike the weapons list ("LB 10-X AC"), aren't equipment
    slots.put("right torso", List.of("ISLBXAC10", "ISLBXAC10", "IS Ammo LB 10-X AC", "ISCASE"));
    slots.put("left torso", List.of("Targeting Computer", "Targeting Computer", "CLCASE"));

    assertThat(ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE))
        .extracting(equip -> equip.getEquipment().getName(), equip -> equip.getEquipment().getTech())
        .containsExactly(
            tuple("ammolb10-xac", Tech.INNER_SPHERE),
            tuple("case", Tech.INNER_SPHERE),
            tuple("targetingcomputer", Tech.INNER_SPHERE));
  }

  @Test
  void readsSlotsThatHoldTwoAmmoBinsSizesAndNarcPods() {
    Map<String, List<String>> slots = new LinkedHashMap<>();
    // half a ton of each in one slot (Ares ARS-V1 Aphrodite)
    slots.put("left torso", List.of("CLRotaryAC5 Ammo|CLRotaryAC5 Ammo (OMNIPOD)", "ISNarc Pods", "ISiNarc Pods (OMNIPOD)"));
    slots.put("right torso", List.of("Communications Equipment:SIZE:3.0", "MediumShield", "Lance"));

    assertThat(ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE))
        .extracting(equip -> equip.getEquipment().getName(), equip -> equip.getEquipment().getTech())
        .containsExactly(
            tuple("rotaryac5ammo", Tech.CLAN),
            tuple("narcpods", Tech.INNER_SPHERE),
            tuple("inarcpods", Tech.INNER_SPHERE),
            tuple("communicationsequipment", Tech.INNER_SPHERE),
            tuple("mediumshield", Tech.INNER_SPHERE),
            tuple("lance", Tech.INNER_SPHERE));
  }

  @Test
  void turretArtemisGoesOnTheTurretLauncher() {
    // Doom Courser Prime: "CLLRM20 (T) (OMNIPOD)" x4, then "CLArtemisIV (T) (OMNIPOD)"
    List<UnitEquipment> weapons = List.of(weapon("lrm20", "Left Torso"));
    Map<String, List<String>> slots = Map.of("left torso",
        List.of("CLLRM20 (T) (OMNIPOD)", "CLLRM20 (T) (OMNIPOD)", "CLArtemisIV (T) (OMNIPOD)"));

    ReadMegaMek.attachMtfFireControl(weapons, slots);

    assertThat(weapons).extracting(UnitEquipment::getFireControl).containsExactly(FireControl.ARTEMIS_IV);
  }

  @Test
  void vehicleSizesArentPartOfTheName() {
    assertThat(ReadMegaMek.convertToEquipment(
            List.of("Communications Equipment:SIZE:4.0", "ISDroneCarrierControlSystem:OMNI:SIZE:6.0"),
            Tech.INNER_SPHERE, Location.BODY))
        .extracting(equip -> equip.getEquipment().getName())
        .containsExactly("communications equipment", "dronecarriercontrolsystem");
  }

  private static List<UnitEquipment> named(Unit unit, String name) {
    return unit.getMechEquipment().stream().filter(equip -> equip.getEquipment().getName().equals(name)).toList();
  }

  @Test
  void fireControlGoesOnTheLauncher() throws IOException {
    Mech champion = mech("Champion CHP-1N2.mtf");
    // "SRM 6, SRM 6, ISArtemisIV" in the left torso
    assertThat(named(champion, "srm6")).extracting(UnitEquipment::getFireControl).containsExactly(FireControl.ARTEMIS_IV);
    assertThat(named(champion, "artemisiv")).isEmpty();
    // Artemis-capable ammo stays its own ammo type
    assertThat(named(champion, "ammosrm-6artemis-capable")).hasSize(1);

    assertThat(named(mech("Akuma AKU-2X.mtf"), "mrm40")).extracting(UnitEquipment::getFireControl)
        .containsExactly(FireControl.APOLLO);
    // other weapons don't get one
    assertThat(mech("Atlas AS7-D.mtf").getMechEquipment()).extracting(UnitEquipment::getFireControl).containsOnlyNulls();
  }

  private static UnitEquipment weapon(String name, String location) {
    return new UnitEquipment(new Equipment(name, Tech.CLAN), location);
  }

  @Test
  void artemisVFillsTwoSlotsButIsOneSystem() {
    List<UnitEquipment> weapons = List.of(weapon("lrt15", "Left Torso"), weapon("lrt15", "Left Torso"));
    Map<String, List<String>> slots = Map.of("left torso",
        List.of("CLLRT15", "CLLRT15", "CLArtemisV (OMNIPOD)", "CLArtemisV (OMNIPOD)", "CLLRT15", "CLLRT15"));

    ReadMegaMek.attachMtfFireControl(weapons, slots);

    assertThat(weapons).extracting(UnitEquipment::getFireControl).containsExactly(FireControl.ARTEMIS_V, null);
  }

  @Test
  void artemisFitsImprovedLaunchersButNotStreaks() {
    List<UnitEquipment> weapons = List.of(weapon("streaksrm6", "Left Torso"), weapon("improvedlrm20", "Left Torso"));
    Map<String, List<String>> slots = Map.of("left torso",
        List.of("CLStreakSRM6", "Improved LRM 20", "CLArtemisIV"));

    ReadMegaMek.attachMtfFireControl(weapons, slots);

    assertThat(weapons).extracting(UnitEquipment::getFireControl).containsExactly(null, FireControl.ARTEMIS_IV);
  }

  @Test
  void vehicleFireControlGoesOnTheLauncherBeforeIt() throws IOException {
    Unit morgan = vehicle("DI Morgan Assault Tank (LRM).blk");

    // "LRM 20, ISArtemisIV" four times in the turret
    assertThat(at(morgan, Location.FRONTTURRET))
        .extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getFireControl)
        .containsExactly(
            tuple("lrm 20", FireControl.ARTEMIS_IV),
            tuple("lrm 20", FireControl.ARTEMIS_IV),
            tuple("lrm 20", FireControl.ARTEMIS_IV),
            tuple("lrm 20", FireControl.ARTEMIS_IV));
    assertThat(at(morgan, Location.BODY)).extracting(equip -> equip.getEquipment().getName())
        .contains("ammo lrm-20 artemis-capable");
  }

  @Test
  void jumpJetsAreCountedBySlotSize() {
    Map<String, List<String>> slots = new LinkedHashMap<>();
    // improved jump jets take two slots, and one can be split across locations
    slots.put("left torso", List.of("Jump Jet", "Jump Jet", "Improved Jump Jet"));
    slots.put("right torso", List.of("Improved Jump Jet", "Improved Jump Jet", "Improved Jump Jet"));

    assertThat(ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE))
        .extracting(equip -> equip.getEquipment().getName())
        .containsExactly("jumpjet", "jumpjet", "improvedjumpjet", "improvedjumpjet");
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
        .startsWith(
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

  @Test
  void mixedTechMech() throws IOException {
    Mech blackKnight = mech("Black Knight BL-6-RR.mtf");

    assertThat(blackKnight.getTech()).isEqualTo(Tech.MIXED_TECH);
    // Clan weapons are "CL..." in the critical slots; unprefixed ones are the IS chassis' tech
    assertThat(blackKnight.getMechEquipment())
        .extracting(equip -> equip.getEquipment().getName(), equip -> equip.getEquipment().getTech())
        .containsExactly(
            tuple("ermediumlaser", Tech.CLAN),
            tuple("erppc", Tech.CLAN),
            tuple("ermediumlaser", Tech.CLAN),
            tuple("largelaser", Tech.INNER_SPHERE),
            tuple("ermediumlaser", Tech.CLAN),
            tuple("largelaser", Tech.INNER_SPHERE),
            tuple("ermediumlaser", Tech.CLAN),
            tuple("smalllaser", Tech.INNER_SPHERE),
            tuple("beagleactiveprobe", Tech.INNER_SPHERE));
  }

  @Test
  void mixedTechMechWithBothVersionsOfAWeapon() throws IOException {
    Mech rifleman = mech("Hybrid Rifleman RFL-3N (Sneede II).mtf");

    assertThat(rifleman.getTech()).isEqualTo(Tech.MIXED_TECH);
    // "CLERMediumLaser" in the left arm, "ISERMediumLaser (R)" (rear-facing) in the center torso
    assertThat(named(rifleman, "ermediumlaser"))
        .extracting(UnitEquipment::getLocation, equip -> equip.getEquipment().getTech())
        .containsExactly(tuple(Location.LEFT_ARM, Tech.CLAN), tuple(Location.CENTER_TORSO, Tech.INNER_SPHERE));
    assertThat(named(rifleman, "smallx-pulselaser")).extracting(equip -> equip.getEquipment().getTech())
        .containsExactly(Tech.INNER_SPHERE);
    // Clan Artemis V on the Clan LRM 20, and the Clan ammo for it
    assertThat(named(rifleman, "lrm20")).extracting(equip -> equip.getEquipment().getTech(), UnitEquipment::getFireControl)
        .containsExactly(tuple(Tech.CLAN, FireControl.ARTEMIS_V));
    assertThat(rifleman.getMechEquipment()).filteredOn(equip -> equip.getEquipment().getName().startsWith("ammo"))
        .extracting(equip -> equip.getEquipment().getTech()).containsOnly(Tech.CLAN);
    // "15 Clan Double" on an IS chassis
    assertThat(rifleman.getHeatsinks().getType()).isEqualTo(HeatsinkType.DOUBLE);
    assertThat(rifleman.getHeatsinks().getTechType()).isEqualTo(Tech.CLAN);
  }

  @Test
  void clanChassisMixedTechMech() throws IOException {
    Mech flamberge = mech("Flamberge D.mtf");

    assertThat(flamberge.getTech()).isEqualTo(Tech.MIXED_TECH);
    // the reverse of the Black Knight: "CL..." Clan weapons, "ISPlasmaRifle" IS
    assertThat(named(flamberge, "srm6")).extracting(equip -> equip.getEquipment().getTech()).containsOnly(Tech.CLAN);
    assertThat(named(flamberge, "mediumpulselaser")).hasSize(4)
        .extracting(equip -> equip.getEquipment().getTech()).containsOnly(Tech.CLAN);
    assertThat(named(flamberge, "plasmarifle")).hasSize(2)
        .extracting(equip -> equip.getEquipment().getTech()).containsOnly(Tech.INNER_SPHERE);
    // ammo keeps its own prefix: 4 tons of IS plasma rifle ammo, 2 of Clan SRM 6
    assertThat(named(flamberge, "plasmarifleammo")).hasSize(4)
        .extracting(equip -> equip.getEquipment().getTech()).containsOnly(Tech.INNER_SPHERE);
    assertThat(named(flamberge, "ammosrm-6")).hasSize(2)
        .extracting(equip -> equip.getEquipment().getTech()).containsOnly(Tech.CLAN);
    // jump MP 4, unprefixed jump jets get the Clan chassis' tech
    assertThat(named(flamberge, "jumpjet")).hasSize(4)
        .extracting(equip -> equip.getEquipment().getTech()).containsOnly(Tech.CLAN);
  }

  @Test
  void slotTechMatchesPrefixedSlots() {
    List<String> slots = List.of("Shoulder", "CLUltraAC10", "Clan Ultra AC/10 Ammo", "ISERLargeLaser", "Large Laser");

    assertThat(ReadMegaMek.slotTech(slots, "Ultra AC/10")).isEqualTo(Tech.CLAN);
    assertThat(ReadMegaMek.slotTech(slots, "ER Large Laser")).isEqualTo(Tech.INNER_SPHERE);
    assertThat(ReadMegaMek.slotTech(slots, "Large Laser")).isNull();
    assertThat(ReadMegaMek.slotTech(slots, "PPC")).isNull();
  }

  @Test
  void heatSinks() throws IOException {
    Mech madCat = mech("Mad Cat (Timber Wolf) Prime.mtf");
    // "17 Clan Double"
    assertThat(madCat.getHeatsinks().getHeatsinkQuantity()).isEqualTo(17);
    assertThat(madCat.getHeatsinks().getType()).isEqualTo(HeatsinkType.DOUBLE);
    assertThat(madCat.getHeatsinks().getTechType()).isEqualTo(Tech.CLAN);

    Mech mixed = new Mech();
    mixed.setTech(Tech.MIXED_TECH);
    mixed.setHeatsinks("20 IS Double");
    assertThat(mixed.getHeatsinks().getType()).isEqualTo(HeatsinkType.DOUBLE);
    assertThat(mixed.getHeatsinks().getTechType()).isEqualTo(Tech.INNER_SPHERE);
    mixed.setHeatsinks("10 Laser");
    assertThat(mixed.getHeatsinks().getType()).isEqualTo(HeatsinkType.LASER);
    assertThat(mixed.getHeatsinks().getTechType()).isEqualTo(Tech.MIXED_TECH);
  }

  // --- vehicles ---

  @Test
  void readsTanks() throws IOException {
    Unit bulldog = vehicle("Bulldog Medium Tank (AC2).blk");

    assertThat(bulldog).isExactlyInstanceOf(Tank.class);
    assertThat(bulldog.getName()).isEqualTo("Bulldog Medium Tank");
    assertThat(bulldog.getDesignation()).isEqualTo("(AC2)");
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

    Unit condor = vehicle("Condor Heavy Hover Tank (Davion).blk");
    assertThat(condor).isExactlyInstanceOf(Tank.class);
    assertThat(((Tank) condor).getMotiveSystem()).isEqualTo(MotiveSystem.Hover);
  }

  @Test
  void readsMotiveTypes() throws IOException {
    assertThat(((Tank) vehicle("Bulldog Medium Tank (AC2).blk")).getMotiveSystem()).isEqualTo(MotiveSystem.Tracked);
    assertThat(((Tank) vehicle("Chalchiuhtotolin Support Tank (Bombast Laser).blk")).getMotiveSystem())
        .isEqualTo(MotiveSystem.Wheeled);
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

  @Test
  void readsBodyEquipment() throws IOException {
    assertThat(at(vehicle("Bulldog Medium Tank (AC2).blk"), Location.BODY))
        .extracting(equip -> equip.getEquipment().getName(), equip -> equip.getEquipment().getTech())
        .containsExactly(
            tuple("ammo srm-4", Tech.INNER_SPHERE),
            tuple("ammo ac/2", Tech.INNER_SPHERE),
            tuple("machine gun ammo - half", Tech.INNER_SPHERE));
  }

  @Test
  void mixedTechVehicle() throws IOException {
    Unit tank = vehicle("Chalchiuhtotolin Support Tank (Bombast Laser).blk");

    assertThat(tank.getTech()).isEqualTo(Tech.MIXED_TECH);
    // "CLStreakSRM4" is Clan, and unprefixed equipment gets the Clan chassis' tech. That's wrong for
    // the IS Bombast Laser, a known limitation (importers skill, bug 11)
    assertThat(at(tank, Location.FRONTTURRET))
        .extracting(equip -> equip.getEquipment().getName(), equip -> equip.getEquipment().getTech())
        .containsExactly(
            tuple("bombast laser", Tech.CLAN),
            tuple("streaksrm4", Tech.CLAN),
            tuple("streaksrm4", Tech.CLAN));
  }

  @Test
  void unprefixedEquipmentGetsTheChassisTech() throws IOException {
    assertThat(vehicle("Puma Assault Tank PAT-001.blk").getMechEquipment())
        .extracting(equip -> equip.getEquipment().getTech())
        .containsOnly(Tech.INNER_SPHERE);
  }
}
