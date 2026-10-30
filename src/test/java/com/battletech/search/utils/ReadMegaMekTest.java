package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Mech;
import com.battletech.search.entities.Tank;
import com.battletech.search.entities.Unit;
import com.battletech.search.entities.UnitEquipment;
import com.battletech.search.entities.Vtol;
import com.battletech.search.model.ArmorType;
import com.battletech.search.model.CockpitType;
import com.battletech.search.model.EngineType;
import com.battletech.search.model.FireControl;
import com.battletech.search.model.GyroType;
import com.battletech.search.model.Heatsinks.HeatsinkType;
import com.battletech.search.model.Location;
import com.battletech.search.model.LamType;
import com.battletech.search.model.Locomotion;
import com.battletech.search.model.MotiveSystem;
import com.battletech.search.model.StructureType;
import com.battletech.search.model.Tech;
import com.battletech.search.model.WeightClass;
import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

/**
 * Parses real MegaMek files copied from MegaMek/mm-data (see the importers skill for the pinned
 * commit). When fixing a bug from the importers skill, add a test here with the correct result.
 */
class ReadMegaMekTest {

  private static ImportProblems.InFile problems() {
    return new ImportProblems().in(new File("test.mtf"));
  }

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
    assertThat(atlas).extracting(Mech::getEngineType, Mech::getEngineTech, Mech::getEngineRating)
        .containsExactly(EngineType.FUSION, Tech.INNER_SPHERE, 300);
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

    assertThat(ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE, problems()))
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

    assertThat(ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE, problems()))
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
  void variableSizeEquipmentKeepsItsSizeOnTheMech() {
    Map<String, List<String>> slots = new LinkedHashMap<>();
    // the size is the whole item's, repeated in each of its slots (Perseus P1E, Thunder Fox TFT-C3)
    slots.put("right torso", List.of("Communications Equipment (OMNIPOD):SIZE:3.0",
        "Communications Equipment (OMNIPOD):SIZE:3.0", "Communications Equipment (OMNIPOD):SIZE:3.0",
        "MechanicalJumpBooster:SIZE:4.0", "Targeting Computer"));
    slots.put("left torso", List.of("MechanicalJumpBooster:SIZE:4.0", "Communications Equipment:SIZE:1.0"));

    assertThat(ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE, problems()))
        .extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getTonnage, UnitEquipment::getJumpBoost)
        .containsExactly(
            tuple("communicationsequipment", 3.0, null),
            // the booster's size is jump MP, not tons
            tuple("mechanicaljumpbooster", 0.0, 4),
            tuple("targetingcomputer", 0.0, null),
            // a second one of another size
            tuple("communicationsequipment", 1.0, null));
  }

  @Test
  void turretArtemisGoesOnTheTurretLauncher() {
    // Doom Courser Prime: "CLLRM20 (T) (OMNIPOD)" x4, then "CLArtemisIV (T) (OMNIPOD)"
    List<UnitEquipment> weapons = List.of(weapon("lrm20", "Left Torso"));
    Map<String, List<String>> slots = Map.of("left torso",
        List.of("CLLRM20 (T) (OMNIPOD)", "CLLRM20 (T) (OMNIPOD)", "CLArtemisIV (T) (OMNIPOD)"));

    ReadMegaMek.attachMtfFireControl(weapons, slots, problems());

    assertThat(weapons).extracting(UnitEquipment::getFireControl).containsExactly(FireControl.ARTEMIS_IV);
  }

  @Test
  void vehicleSizesGoOnTheItemNotTheName() {
    assertThat(ReadMegaMek.convertToEquipment(
            List.of("Communications Equipment:SIZE:4.0", "ISDroneCarrierControlSystem:OMNI:SIZE:6.0"),
            Tech.INNER_SPHERE, Location.BODY, problems()))
        .extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getTonnage, UnitEquipment::isOmniPod)
        .containsExactly(
            tuple("communications equipment", 4.0, false),
            // a drone carrier's size is drones, which isn't kept yet
            tuple("dronecarriercontrolsystem", 0.0, true));
  }

  @Test
  void whatCantBeReadIsReported() {
    ImportProblems problems = new ImportProblems();
    ImportProblems.InFile inFile = problems.in(new File("Tarantula ZPH-1.mtf"));

    // no mech has wings
    ReadMegaMek.readMtfSlotEquipment(Map.of("left wing", List.of("Jump Jet")), Tech.INNER_SPHERE, inFile);
    // nothing for the Artemis to go on
    ReadMegaMek.attachMtfFireControl(List.of(weapon("mediumlaser", "Left Torso")),
        Map.of("left torso", List.of("Medium Laser", "ISArtemisIV")), inFile);
    // a drone carrier's drones aren't kept
    ReadMegaMek.convertToEquipment(List.of("ISDroneCarrierControlSystem:SIZE:6.0"), Tech.INNER_SPHERE, Location.BODY, inFile);
    ReadMegaMek.parseUuid("not-a-uuid", inFile);

    assertThat(problems.of(ImportProblems.Kind.UNKNOWN_LOCATION)).containsExactly("Tarantula ZPH-1.mtf: Jump Jet in left wing");
    assertThat(problems.of(ImportProblems.Kind.FIRE_CONTROL_WITHOUT_LAUNCHER))
        .containsExactly("Tarantula ZPH-1.mtf: ISArtemisIV in left torso");
    assertThat(problems.of(ImportProblems.Kind.SIZE_NOT_KEPT))
        .containsExactly("Tarantula ZPH-1.mtf: dronecarriercontrolsystem size 6.0");
    assertThat(problems.counts()).containsEntry(ImportProblems.Kind.INVALID_UUID, 1);
    assertThat(problems.summary()).contains("UNKNOWN_LOCATION 1", "FIRE_CONTROL_WITHOUT_LAUNCHER 1");
  }

  @Test
  void superheavySidesRotorAndSlotlessSectionsAreRead(@TempDir Path dir) throws IOException {
    Path file = dir.resolve("Superheavy.blk");
    Files.writeString(file, String.join("\n", "<UnitType>", "Tank", "</UnitType>", "<Name>", "Superheavy", "</Name>",
        "<Model></Model>", "<type>", "IS Level 2", "</type>", "<motion_type>", "Tracked", "</motion_type>",
        "<cruiseMP>", "3", "</cruiseMP>", "<armor>", "10", "</armor>", "<tonnage>", "150.0", "</tonnage>",
        "<Front Equipment>", "Medium Laser", "</Front Equipment>",
        "<Front Left Equipment>", "Light Machine Gun", "</Front Left Equipment>",
        "<Rear Right Equipment>", "</Rear Right Equipment>",
        "<Rotor Equipment>", "Mast Mount", "</Rotor Equipment>",
        "<slotless_equipment>", "CLCASE", "</slotless_equipment>", ""));
    ImportProblems problems = new ImportProblems();

    Unit tank = ReadMegaMek.ReadVehicleBlk(file.toFile(), problems.in(file.toFile()));

    assertThat(tank.getMechEquipment()).extracting(equip -> equip.getEquipment().getName(), UnitEquipment::getLocation)
        .containsExactly(tuple("medium laser", Location.FRONT), tuple("light machine gun", Location.FRONT_LEFT),
            tuple("mast mount", Location.ROTOR), tuple("case", Location.BODY));
    assertThat(problems.counts()).isEmpty();
  }

  @Test
  void vehicleSectionsTheReaderSkipsAreReported(@TempDir Path dir) throws IOException {
    // only on fixed-wing support vehicles, which are skipped; checked on a tank to see the report
    Path file = dir.resolve("Winged.blk");
    Files.writeString(file, String.join("\n", "<UnitType>", "Tank", "</UnitType>", "<Name>", "Winged", "</Name>",
        "<Model></Model>", "<type>", "IS Level 2", "</type>", "<motion_type>", "Tracked", "</motion_type>",
        "<cruiseMP>", "3", "</cruiseMP>", "<armor>", "10", "</armor>", "<tonnage>", "50.0", "</tonnage>",
        "<Left Wing Equipment>", "Light Machine Gun", "</Left Wing Equipment>",
        "<Nose Equipment>", "</Nose Equipment>", ""));
    ImportProblems problems = new ImportProblems();

    ReadMegaMek.ReadVehicleBlk(file.toFile(), problems.in(file.toFile()));

    // only the section with something in it
    assertThat(problems.of(ImportProblems.Kind.UNREAD_SECTION))
        .containsExactly("Winged.blk: <left wing equipment> [Light Machine Gun]");
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

    ReadMegaMek.attachMtfFireControl(weapons, slots, problems());

    assertThat(weapons).extracting(UnitEquipment::getFireControl).containsExactly(FireControl.ARTEMIS_V, null);
  }

  @Test
  void artemisFitsImprovedLaunchersButNotStreaks() {
    List<UnitEquipment> weapons = List.of(weapon("streaksrm6", "Left Torso"), weapon("improvedlrm20", "Left Torso"));
    Map<String, List<String>> slots = Map.of("left torso",
        List.of("CLStreakSRM6", "Improved LRM 20", "CLArtemisIV"));

    ReadMegaMek.attachMtfFireControl(weapons, slots, problems());

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

    assertThat(ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE, problems()))
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
    // the first word of every Config: at the pinned commit
    assertThat(List.of("Tripod OmniMek", "LAM", "QuadVee OmniMek")).extracting(config -> Locomotion.fromString(config.split(" ")[0]))
        .containsExactly(Locomotion.TRIPOD, Locomotion.LAM, Locomotion.QUADVEE);
  }

  @Test
  void readsMechComponents() throws IOException {
    // type, tech, rating / armor and structure with their tech / gyro and cockpit
    assertThat(mech("Mad Cat (Timber Wolf) Prime.mtf")).extracting(Mech::getEngineType, Mech::getEngineTech,
            Mech::getEngineRating, Mech::getArmorType, Mech::getArmorTech, Mech::getStructureType, Mech::getStructureTech,
            Mech::getGyro, Mech::getCockpit)
        .containsExactly(EngineType.XL, Tech.CLAN, 375, ArmorType.FERRO_FIBROUS, Tech.CLAN, StructureType.ENDO_STEEL,
            Tech.CLAN, GyroType.STANDARD, CockpitType.STANDARD);
    // mixed tech: "Fusion Engine(IS)", "Ferro-Fibrous(Clan)", and "Standard" structure takes the IS chassis tech
    assertThat(mech("Hybrid Rifleman RFL-3N (Sneede II).mtf")).extracting(Mech::getEngineType, Mech::getEngineTech,
            Mech::getArmorType, Mech::getArmorTech, Mech::getStructureType, Mech::getStructureTech)
        .containsExactly(EngineType.FUSION, Tech.INNER_SPHERE, ArmorType.FERRO_FIBROUS, Tech.CLAN, StructureType.STANDARD,
            Tech.INNER_SPHERE);
    assertThat(mech("Flamberge D.mtf")).extracting(Mech::getEngineType, Mech::getEngineTech, Mech::getArmorTech)
        .containsExactly(EngineType.XL, Tech.CLAN, Tech.INNER_SPHERE);
    assertThat(mech("Deep Lord RCL-Z1M MilitiaMech.mtf")).extracting(Mech::getEngineType, Mech::getEngineRating,
            Mech::getStructureType, Mech::getCockpit)
        .containsExactly(EngineType.FUEL_CELL, 195, StructureType.INDUSTRIAL, CockpitType.INDUSTRIAL);
    assertThat(mech("Akuma AKU-2X.mtf").getGyro()).isEqualTo(GyroType.COMPACT);
    assertThat(mech("Atlas AS7-D.mtf").getLamType()).isNull();
  }

  @Test
  void readsLamAndQuadVeeComponents() {
    ImportProblems problems = new ImportProblems();
    Mech lam = new Mech();
    lam.setLocomotion(Locomotion.LAM);
    ReadMegaMek.readMtfComponents(lam, Map.of("engine", "405 Large XXL (Clan) Engine", "armor", "Patchwork",
        "structure", "Hybrid", "lam", "Bimodal", "cockpit", "Small Cockpit"), Tech.INNER_SPHERE, problems.in(new File("Lam.mtf")));
    Mech quadVee = new Mech();
    quadVee.setLocomotion(Locomotion.QUADVEE);
    ReadMegaMek.readMtfComponents(quadVee, Map.of("engine", "300 XL Engine", "armor", "Standard(Clan)",
        "structure", "Clan Standard", "motive", "Wheel"), Tech.CLAN, problems.in(new File("QuadVee.mtf")));

    // a large engine is its type with a rating over 400; patchwork and hybrid take the chassis tech
    assertThat(lam).extracting(Mech::getEngineType, Mech::getEngineTech, Mech::getEngineRating, Mech::getArmorType,
            Mech::getArmorTech, Mech::getStructureType, Mech::getLamType, Mech::getCockpit)
        .containsExactly(EngineType.XXL, Tech.CLAN, 405, ArmorType.PATCHWORK, Tech.INNER_SPHERE, StructureType.HYBRID,
            LamType.BIMODAL, CockpitType.SMALL);
    assertThat(quadVee.getQuadVeeMotive()).isEqualTo(MotiveSystem.Wheeled);
    assertThat(quadVee.getEngineTech()).isEqualTo(Tech.CLAN);
    assertThat(problems.counts()).isEmpty();
  }

  @Test
  void unknownComponentsAreReported() {
    ImportProblems problems = new ImportProblems();
    Mech mech = new Mech();
    ReadMegaMek.readMtfComponents(mech, Map.of("engine", "300 Warp Engine", "armor", "Standard(Inner Sphere)",
        "structure", "IS Standard", "gyro", "Spinning Gyro"), Tech.INNER_SPHERE, problems.in(new File("Odd.mtf")));

    assertThat(mech.getEngineType()).isNull();
    assertThat(problems.of(ImportProblems.Kind.UNKNOWN_COMPONENT))
        .containsExactly("Odd.mtf: engine 300 Warp Engine", "Odd.mtf: gyro Spinning Gyro");
  }

  @Test
  void readsVehicleComponents() throws IOException {
    // ICE, hover: 8 MP x 50 tons - 235 suspension
    assertThat(vehicle("Condor Heavy Hover Tank (Davion).blk")).extracting(Unit::getEngineType, Unit::getEngineTech,
            Unit::getEngineRating, Unit::getArmorType, Unit::getArmorTech, Unit::getStructureType, Unit::getStructureTech)
        .containsExactly(EngineType.ICE, Tech.INNER_SPHERE, 165, ArmorType.STANDARD, Tech.INNER_SPHERE,
            StructureType.STANDARD, Tech.INNER_SPHERE);
    // tracked: no suspension
    assertThat(vehicle("DI Morgan Assault Tank (LRM).blk")).extracting(Unit::getEngineType, Unit::getEngineRating,
            Unit::getArmorType)
        .containsExactly(EngineType.XL, 300, ArmorType.HEAVY_FERRO_FIBROUS);
    // Clan chassis with an IS engine (<clan_engine>false); armor tech level -1 is the chassis tech
    assertThat(vehicle("Chalchiuhtotolin Support Tank (Bombast Laser).blk")).extracting(Unit::getEngineType,
            Unit::getEngineTech, Unit::getEngineRating, Unit::getArmorType, Unit::getArmorTech)
        .containsExactly(EngineType.FUSION, Tech.INNER_SPHERE, 230, ArmorType.FERRO_FIBROUS, Tech.CLAN);
    // VTOL: 9 x 21 - 140 = 49, up to a multiple of 5
    assertThat(vehicle("Warrior H-7 Attack Helicopter.blk").getEngineRating()).isEqualTo(50);
  }

  @Test
  void quadAndTripodLegsAreLocations() {
    ImportProblems problems = new ImportProblems();
    Map<String, List<String>> slots = new LinkedHashMap<>();
    slots.put("front left leg", List.of("Jump Jet"));
    slots.put("rear right leg", List.of("IS Ammo SRM-6"));
    slots.put("center leg", List.of("CASE"));

    List<UnitEquipment> equipment = ReadMegaMek.readMtfSlotEquipment(slots, Tech.INNER_SPHERE, problems.in(new File("Quad.mtf")));

    assertThat(equipment).extracting(UnitEquipment::getLocation)
        .containsExactlyInAnyOrder(Location.FRONT_LEFT_LEG, Location.REAR_RIGHT_LEG, Location.CENTER_LEG);
    assertThat(problems.counts()).isEmpty();
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
