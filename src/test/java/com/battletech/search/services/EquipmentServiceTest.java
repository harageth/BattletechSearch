package com.battletech.search.services;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.battletech.search.entities.Equipment;
import com.battletech.search.entities.EquipmentSlang;
import com.battletech.search.model.Tech;
import com.battletech.search.repositories.EquipmentRepository;
import com.battletech.search.repositories.EquipmentSlangRepository;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class EquipmentServiceTest {
  EquipmentSlangRepository slangRepo;
  EquipmentRepository equipRepo;
  EquipmentService service;
  Equipment isAmmo = new Equipment("gaussrifleammo", Tech.INNER_SPHERE);
  Equipment clanAmmo = new Equipment("gaussrifleammo", Tech.CLAN);

  @BeforeEach
  void setUp() {
    slangRepo = mock(EquipmentSlangRepository.class);
    equipRepo = mock(EquipmentRepository.class);
    service = new EquipmentService(slangRepo, equipRepo);
    when(equipRepo.findByNameIn(anyCollection())).thenReturn(List.of(isAmmo, clanAmmo));
  }

  @Test
  void slangGoesOnEveryTechByDefault() {
    service.addSlangToEquipment("Gauss Rifle Ammo", List.of("gauss ammo"));
    verify(slangRepo, times(2)).save(any());
  }

  @Test
  void slangNeverCarriesATech() {
    // tech is a search filter, not part of the slang: "clan sniper rounds" is stored as "sniperrounds",
    // on every tech of the equipment, even when the name has one
    service.addSlangToEquipment("Gauss Rifle Ammo [Clan]", List.of("clan sniper rounds"));

    ArgumentCaptor<EquipmentSlang> saved = ArgumentCaptor.forClass(EquipmentSlang.class);
    verify(slangRepo, times(2)).save(saved.capture());
    assertThat(saved.getAllValues()).extracting(EquipmentSlang::getSlang).containsOnly("sniperrounds");
    assertThat(saved.getAllValues()).extracting(EquipmentSlang::getEquipment).containsExactly(isAmmo, clanAmmo);
  }
}
