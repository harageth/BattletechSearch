package com.battletech.search.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assumptions.assumeTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.battletech.search.TestcontainersConfiguration;
import com.battletech.search.services.SearchService;
import com.battletech.search.services.UnitService;
import com.battletech.search.services.UnitService.ImportResult;
import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.NetworkInterface;
import java.net.Socket;
import java.net.SocketException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalManagementPort;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

/** Runs the real app on random ports: search on the public port, admin endpoints on the management port. */
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT, properties = "management.server.port=0")
@Import(TestcontainersConfiguration.class)
class AdminEndpointsTest {
  @LocalServerPort
  int port;

  @LocalManagementPort
  int managementPort;

  @Autowired
  TestRestTemplate rest;

  @Autowired
  SearchService searchService;

  @Autowired
  JdbcTemplate jdbcTemplate;

  @MockitoBean
  UnitService unitService;

  @AfterEach
  void removeSlang() {
    jdbcTemplate.update("DELETE FROM equipment_slang WHERE slang IN ('particle cannon', 'ppcs')");
  }

  private ResponseEntity<String> postAdmin(String endpoint, Map<String, Object> body) {
    return rest.postForEntity("http://127.0.0.1:" + managementPort + "/actuator/" + endpoint, body, String.class);
  }

  @Test
  void addedSlangIsSearchable() throws IOException {
    assertThat(postAdmin("slang", Map.of("equipmentName", "ppc", "terms", "particle cannon, ppcs"))
        .getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);

    List<Map<String, Object>> ppc = searchService.performQuery("mechs with at least 4 ppc");
    assertThat(ppc).isNotEmpty();
    assertThat(searchService.performQuery("mechs with at least 4 particle cannon")).isEqualTo(ppc);
    assertThat(searchService.performQuery("mechs with at least 4 ppcs")).isEqualTo(ppc);
  }

  @Test
  void importsTheRecognitionGuide() {
    assertThat(postAdmin("import", Map.of("source", "recognition-guide")).getStatusCode())
        .isEqualTo(HttpStatus.OK);
    verify(unitService).importRecognitionGuide();
  }

  @Test
  void importsMegaMekUnits() throws IOException {
    when(unitService.persistMechs()).thenReturn(new ImportResult(3, 1, 0, 0));
    ResponseEntity<String> mechs = postAdmin("import", Map.of("source", "mechs"));
    assertThat(mechs.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(mechs.getBody()).contains("\"added\":3", "\"updated\":1");

    when(unitService.persistVehicles()).thenReturn(new ImportResult(2, 0, 1, 0));
    assertThat(postAdmin("import", Map.of("source", "vehicles")).getStatusCode()).isEqualTo(HttpStatus.OK);
    verify(unitService).persistVehicles();
  }

  @Test
  void rejectsUnknownImportSources() {
    assertThat(postAdmin("import", Map.of("source", "dropships")).getStatusCode())
        .isEqualTo(HttpStatus.BAD_REQUEST);
    verifyNoInteractions(unitService);
  }

  @Test
  void healthIsOnTheManagementPort() {
    assertThat(rest.getForEntity("http://127.0.0.1:" + managementPort + "/actuator/health", String.class)
        .getStatusCode()).isEqualTo(HttpStatus.OK);
  }

  @Test
  void adminEndpointsAreNotOnThePublicPort() {
    String publicUrl = "http://127.0.0.1:" + port;
    assertThat(rest.postForEntity(publicUrl + "/actuator/slang", Map.of(), String.class).getStatusCode())
        .isEqualTo(HttpStatus.NOT_FOUND);
    assertThat(rest.getForEntity(publicUrl + "/actuator/health", String.class).getStatusCode())
        .isEqualTo(HttpStatus.NOT_FOUND);
    // the old admin URLs are gone
    assertThat(rest.getForEntity(publicUrl + "/readFile/", String.class).getStatusCode())
        .isEqualTo(HttpStatus.NOT_FOUND);
    assertThat(rest.postForEntity(publicUrl + "/addSlang/ppc", new String[] {"x"}, String.class).getStatusCode())
        .isEqualTo(HttpStatus.NOT_FOUND);
  }

  @Test
  void managementPortOnlyListensOnLoopback() throws IOException {
    Optional<InetAddress> lanAddress = nonLoopbackAddress();
    assumeTrue(lanAddress.isPresent(), "machine has no non-loopback IPv4 address");

    // the public port listens on every interface, the management port only on 127.0.0.1
    try (Socket socket = new Socket()) {
      socket.connect(new InetSocketAddress(lanAddress.get(), port), 2000);
    }
    assertThatThrownBy(() -> {
      try (Socket socket = new Socket()) {
        socket.connect(new InetSocketAddress(lanAddress.get(), managementPort), 2000);
      }
    }).isInstanceOf(IOException.class);
  }

  private static Optional<InetAddress> nonLoopbackAddress() throws SocketException {
    return NetworkInterface.networkInterfaces()
        .filter(nic -> {
          try {
            return nic.isUp() && !nic.isLoopback();
          } catch (SocketException e) {
            return false;
          }
        })
        .flatMap(NetworkInterface::inetAddresses)
        .filter(address -> address instanceof Inet4Address && !address.isLinkLocalAddress())
        .findFirst();
  }
}
