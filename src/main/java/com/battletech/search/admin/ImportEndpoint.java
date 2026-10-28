package com.battletech.search.admin;

import com.battletech.search.services.UnitService;
import java.io.IOException;
import org.springframework.boot.actuate.endpoint.InvalidEndpointRequestException;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.WriteOperation;
import org.springframework.stereotype.Component;

/**
 * POST /actuator/import {"source": "mechs" | "vehicles" | "recognition-guide"} on the management
 * port. Mechs and vehicles come from MEGAMEK_MECHS_PATH / MEGAMEK_VEHICLES_PATH; importing again
 * updates units already stored (matched on their MegaMek uuid) instead of duplicating them.
 */
@Component
@Endpoint(id = "import")
public class ImportEndpoint {
  static final String MECHS = "mechs";
  static final String VEHICLES = "vehicles";
  static final String RECOGNITION_GUIDE = "recognition-guide";

  private final UnitService unitService;

  public ImportEndpoint(UnitService unitService) {
    this.unitService = unitService;
  }

  @WriteOperation
  public Object importUnits(String source) throws IOException {
    switch (source) {
      case MECHS:
        return unitService.persistMechs();
      case VEHICLES:
        return unitService.persistVehicles();
      case RECOGNITION_GUIDE:
        unitService.importRecognitionGuide();
        return "Imported " + source;
      default:
        throw new InvalidEndpointRequestException("Unknown import source: " + source,
            "Unknown import source; supported: " + MECHS + ", " + VEHICLES + ", " + RECOGNITION_GUIDE);
    }
  }
}
