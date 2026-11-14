package com.battletech.search.services;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.Slang;
import com.battletech.search.model.SlangKind;
import com.battletech.search.model.Tech;
import com.battletech.search.repositories.EquipmentGroupRepository;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.utils.GroupSeed;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class EquipmentServiceTest {
  SlangRepository slangRepo;
  EquipmentRepository equipRepo;
  EquipmentGroupRepository groupRepo;
  EquipmentService service;
  Equipment isAmmo = new Equipment("gaussrifleammo", Tech.INNER_SPHERE);
  Equipment clanAmmo = new Equipment("gaussrifleammo", Tech.CLAN);

  @BeforeEach
  void setUp() {
    slangRepo = mock(SlangRepository.class);
    equipRepo = mock(EquipmentRepository.class);
    groupRepo = mock(EquipmentGroupRepository.class);
    service = new EquipmentService(slangRepo, equipRepo, groupRepo);
    when(equipRepo.findAllByNameOrSlang(anyString(), anyString())).thenReturn(List.of(clanAmmo));
    when(equipRepo.findByNameIn(anyCollection())).thenReturn(List.of(isAmmo, clanAmmo));
    when(slangRepo.findByLookup(anyString())).thenReturn(Optional.empty());
  }

  private Slang saved() {
    ArgumentCaptor<Slang> saved = ArgumentCaptor.forClass(Slang.class);
    verify(slangRepo).save(saved.capture());
    return saved.getValue();
  }

  @Test
  void slangGoesOnEveryTech() {
    service.addSlangToEquipment("Gauss Rifle Ammo", List.of("gauss ammo"));
    Slang slang = saved();
    assertThat(slang.getTerm()).isEqualTo("gauss ammo");
    assertThat(slang.getLookup()).isEqualTo("gaussammo");
    assertThat(slang.getKind()).isEqualTo(SlangKind.USER);
    assertThat(slang.getEquipment()).containsExactlyInAnyOrder(isAmmo, clanAmmo);
  }

  @Test
  void slangNeverCarriesATech() {
    // tech is a search filter, not part of the slang: "clan sniper rounds" is stored as "sniper rounds",
    // on every tech of the equipment, even when the name has one
    service.addSlangToEquipment("Gauss Rifle Ammo [Clan]", List.of("clan sniper rounds"));
    Slang slang = saved();
    assertThat(slang.getLookup()).isEqualTo("sniperrounds");
    assertThat(slang.getEquipment()).containsExactlyInAnyOrder(isAmmo, clanAmmo);
  }

  @Test
  void anExistingTermBecomesUserSlangAndKeepsWhatItStoodFor() {
    Equipment ppc = new Equipment("ppc", Tech.INNER_SPHERE);
    when(slangRepo.findByLookup("gaussstuff"))
        .thenReturn(Optional.of(new Slang("gauss stuff", "gaussstuff", SlangKind.ALIAS, Set.of(ppc))));
    service.addSlangToEquipment("Gauss Rifle Ammo", List.of("gauss stuff"));
    Slang slang = saved();
    assertThat(slang.getKind()).isEqualTo(SlangKind.USER);
    assertThat(slang.getEquipment()).containsExactlyInAnyOrder(ppc, isAmmo, clanAmmo);
  }

  @Test
  void equipmentNoUnitHasIsRefused() {
    when(equipRepo.findAllByNameOrSlang(anyString(), anyString())).thenReturn(List.of());
    assertThatThrownBy(() -> service.addSlangToEquipment("Nonexistent Gun", List.of("ng")))
        .isInstanceOf(IllegalArgumentException.class);
    verify(slangRepo, never()).save(any());
  }

  private static Equipment displayed(String name, String displayName, Tech tech) {
    Equipment equipment = new Equipment(name, tech);
    equipment.setId(UUID.randomUUID());
    equipment.setDisplayName(displayName);
    return equipment;
  }

  @Test
  void listsEachItemOnceWithItsSlangButNotItsGroups() {
    Equipment isLrm = displayed("lrm20", "LRM 20", Tech.INNER_SPHERE);
    Equipment clanLrm = displayed("lrm20", "LRM 20", Tech.CLAN);
    Equipment ams = displayed("antimissilesystem", "AMS", Tech.CLAN);
    when(equipRepo.findAll()).thenReturn(List.of(clanLrm, ams, isLrm));
    when(slangRepo.findAllWithEquipment()).thenReturn(List.of(
        new Slang("LRM 20", "lrm20", SlangKind.ALIAS, Set.of(isLrm, clanLrm)),
        new Slang("CLLRM20", "cllrm20", SlangKind.ALIAS, Set.of(clanLrm)),
        new Slang("IS LRM 20", "islrm20", SlangKind.ALIAS, Set.of(isLrm)),
        new Slang("OS LRM-20", "oslrm20", SlangKind.ALIAS, Set.of(isLrm, clanLrm)),
        new Slang("Clan OS LRM-20", "clanoslrm20", SlangKind.ALIAS, Set.of(clanLrm)),
        new Slang("lrms", "lrms", SlangKind.FAMILY, Set.of(isLrm, clanLrm)),
        new Slang("lrm", "lrm", SlangKind.FAMILY_SINGULAR, Set.of(isLrm, clanLrm)),
        new Slang("Anti-Missile System", "antimissilesystem", SlangKind.ALIAS, Set.of(ams)),
        new Slang("ams", "ams", SlangKind.SHORTHAND, Set.of(ams))));

    List<EquipmentService.EquipmentTerms> rows = service.equipmentWithSlang();

    // by name; the item's own name and tech-prefixed spellings of it aren't repeated, and group terms
    // ("lrms") are left to the tree
    assertThat(rows).containsExactly(
        new EquipmentService.EquipmentTerms("AMS", List.of("Clan"), List.of(), List.of("Anti-Missile System")),
        new EquipmentService.EquipmentTerms("LRM 20", List.of("IS", "Clan"), List.of(), List.of("OS LRM-20")));
  }

  @Test
  void theTreePutsEachItemUnderItsGroups() {
    Equipment lrm = displayed("lrm20", "LRM 20", Tech.INNER_SPHERE);
    Equipment streak = displayed("streaklrm20", "Streak LRM 20", Tech.CLAN);
    Equipment erPulse = displayed("ermediumpulselaser", "ER Medium Pulse Laser", Tech.CLAN);
    Equipment tc = displayed("targetingcomputer", "Targeting Computer", Tech.CLAN);
    when(equipRepo.findAll()).thenReturn(List.of(lrm, streak, erPulse, tc));
    // the groups V3_17 makes for these rows
    when(groupRepo.findTree()).thenReturn(GroupSeed.rows(List.of(lrm, streak, erPulse, tc)));
    when(slangRepo.findAllWithEquipment()).thenReturn(List.of());

    EquipmentService.EquipmentTree tree = service.equipmentTree();

    // only groups with something in them, in their order
    assertThat(tree.groups()).extracting(EquipmentService.EquipmentGroup::term).containsExactly("missiles", "energy weapons");
    EquipmentService.EquipmentGroup missiles = tree.groups().get(0);
    assertThat(missiles.count()).isEqualTo(2);
    assertThat(missiles.items()).isEmpty();
    // "streak lrms" is under both "lrms" and "streaks"
    assertThat(missiles.groups()).extracting(EquipmentService.EquipmentGroup::term).containsExactly("lrms", "streaks");
    EquipmentService.EquipmentGroup lrms = missiles.groups().get(0);
    assertThat(lrms.count()).isEqualTo(2);
    assertThat(lrms.groups()).extracting(EquipmentService.EquipmentGroup::term).containsExactly("standard lrms", "streak lrms");
    assertThat(lrms.groups().get(0).items()).extracting(EquipmentService.EquipmentTerms::name).containsExactly("LRM 20");
    assertThat(missiles.groups().get(1).groups().get(0).items()).extracting(EquipmentService.EquipmentTerms::name)
        .containsExactly("Streak LRM 20");
    // energy weapons > lasers > pulse lasers > er pulse lasers
    EquipmentService.EquipmentGroup lasers = tree.groups().get(1).groups().get(0);
    assertThat(lasers.groups()).extracting(EquipmentService.EquipmentGroup::term).containsExactly("pulse lasers");
    assertThat(lasers.groups().get(0).groups()).extracting(EquipmentService.EquipmentGroup::term)
        .containsExactly("er pulse lasers");
    assertThat(lasers.count()).isEqualTo(1);
    assertThat(tree.other()).extracting(EquipmentService.EquipmentTerms::name).containsExactly("Targeting Computer");
  }
}
