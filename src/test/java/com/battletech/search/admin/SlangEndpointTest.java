package com.battletech.search.admin;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.SearchFixtures;
import com.battletech.search.TestcontainersConfiguration;
import com.battletech.search.model.SlangKind;
import com.battletech.search.repositories.SlangRepository;
import com.battletech.search.services.SearchService;
import com.battletech.search.services.UnitService;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalManagementPort;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;

/** POST /actuator/slang on the management port, searched against the fixture units. */
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT, properties = "management.server.port=0")
@Import({TestcontainersConfiguration.class, SearchFixtures.class})
class SlangEndpointTest {
  @LocalManagementPort
  int managementPort;

  @Autowired
  TestRestTemplate rest;

  @Autowired
  SearchService searchService;

  @Autowired
  UnitService unitService;

  @Autowired
  SlangRepository slangRepo;

  @Autowired
  JdbcTemplate jdbcTemplate;

  @AfterEach
  void removeSlang() {
    jdbcTemplate.update("DELETE FROM slang WHERE kind = 'USER'");
  }

  private ResponseEntity<String> postSlang(String equipmentName, String terms) {
    return rest.postForEntity("http://127.0.0.1:" + managementPort + "/actuator/slang",
        Map.of("equipmentName", equipmentName, "terms", terms), String.class);
  }

  @Test
  void addedSlangIsSearchable() throws IOException {
    assertThat(postSlang("ppc", "particle cannon, ppc gun").getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);

    List<Map<String, Object>> ppc = searchService.performQuery("mechs with at least 2 ppc");
    assertThat(ppc).isNotEmpty();
    assertThat(searchService.performQuery("mechs with at least 2 particle cannon")).isEqualTo(ppc);
    assertThat(searchService.performQuery("mechs with at least 2 ppc gun")).isEqualTo(ppc);
  }

  @Test
  void slangIsFilteredByTechInSearches() throws IOException {
    // goes on every ER PPC; the tech word in a search filters it. The Black Knight BL-6-RR has a Clan one.
    assertThat(postSlang("ER PPC [Clan]", "clan big ppc").getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
    assertThat(slangRepo.findByLookup("bigppc")).get().extracting(slang -> slang.getTerm()).isEqualTo("big ppc");

    List<Map<String, Object>> clanErPpc = searchService.performQuery("mechs with at least 1 clan er ppc");
    assertThat(clanErPpc).extracting(row -> row.get("name") + " " + row.get("designation"))
        .contains("Black Knight BL-6-RR");
    assertThat(searchService.performQuery("mechs with at least 1 clan big ppc")).isEqualTo(clanErPpc);
    assertThat(searchService.performQuery("mechs with at least 1 is big ppc"))
        .isEqualTo(searchService.performQuery("mechs with at least 1 is er ppc"));
    assertThat(searchService.performQuery("mechs with at least 1 big ppc"))
        .isEqualTo(searchService.performQuery("mechs with at least 1 er ppc"));
  }

  @Test
  void addedSlangSurvivesTheSlangLoad() throws IOException {
    postSlang("ppc", "particle cannon");
    unitService.loadSlang();

    assertThat(slangRepo.findByLookup("particlecannon")).get().extracting(slang -> slang.getKind())
        .isEqualTo(SlangKind.USER);
    assertThat(searchService.performQuery("mechs with at least 2 particle cannon"))
        .isEqualTo(searchService.performQuery("mechs with at least 2 ppc"));
  }

  @Test
  void slangForEquipmentNoUnitHasIsRefused() {
    assertThat(postSlang("nonexistent gun", "ng").getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    assertThat(slangRepo.findByLookup("ng")).isEmpty();
  }
}
