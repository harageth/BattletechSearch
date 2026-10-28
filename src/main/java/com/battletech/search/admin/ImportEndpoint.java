package com.battletech.search.admin;

import com.battletech.search.services.UnitService;
import org.springframework.boot.actuate.endpoint.InvalidEndpointRequestException;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.WriteOperation;
import org.springframework.stereotype.Component;

/**
 * POST /actuator/import {"source": "recognition-guide"} on the management port.
 * MegaMek mech/vehicle sources come with the importer work; importing them today would
 * duplicate every unit (see the importers skill).
 */
@Component
@Endpoint(id = "import")
public class ImportEndpoint {
  static final String RECOGNITION_GUIDE = "recognition-guide";

  private final UnitService unitService;

  public ImportEndpoint(UnitService unitService) {
    this.unitService = unitService;
  }

  @WriteOperation
  public String importUnits(String source) {
    if (RECOGNITION_GUIDE.equals(source)) {
      unitService.importRecognitionGuide();
      return "Imported " + source;
    }
    throw new InvalidEndpointRequestException("Unknown import source: " + source,
        "Unknown import source; supported: " + RECOGNITION_GUIDE);
  }
}
