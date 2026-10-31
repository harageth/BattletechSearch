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
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.SlangRepository;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class EquipmentServiceTest {
  SlangRepository slangRepo;
  EquipmentRepository equipRepo;
  EquipmentService service;
  Equipment isAmmo = new Equipment("gaussrifleammo", Tech.INNER_SPHERE);
  Equipment clanAmmo = new Equipment("gaussrifleammo", Tech.CLAN);

  @BeforeEach
  void setUp() {
    slangRepo = mock(SlangRepository.class);
    equipRepo = mock(EquipmentRepository.class);
    service = new EquipmentService(slangRepo, equipRepo);
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
    equipment.setDisplayName(displayName);
    return equipment;
  }

  @Test
  void listsEachItemOnceWithItsSlang() {
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

    // by name; the item's own name and tech-prefixed spellings of it aren't repeated
    assertThat(rows).containsExactly(
        new EquipmentService.EquipmentTerms("AMS", List.of("Clan"), List.of(), List.of("Anti-Missile System")),
        new EquipmentService.EquipmentTerms("LRM 20", List.of("IS", "Clan"), List.of("lrms", "lrm"), List.of("OS LRM-20")));
  }
}
