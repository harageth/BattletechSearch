package com.battletech.search.admin;

import com.battletech.search.services.EquipmentService;
import java.util.List;
import org.springframework.boot.actuate.endpoint.InvalidEndpointRequestException;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.WriteOperation;
import org.springframework.stereotype.Component;

/**
 * POST /actuator/slang {"equipmentName": "medium laser", "terms": "ml, medium l"}
 * on the management port.
 */
@Component
@Endpoint(id = "slang")
public class SlangEndpoint {
  private final EquipmentService equipService;

  public SlangEndpoint(EquipmentService equipService) {
    this.equipService = equipService;
  }

  // Actuator reads the JSON body as string values only, so terms is one comma-separated string
  // that the conversion service splits (and trims) into the array
  @WriteOperation
  public void addSlang(String equipmentName, String[] terms) {
    try {
      equipService.addSlangToEquipment(equipmentName, List.of(terms));
    } catch (IllegalArgumentException e) {
      throw new InvalidEndpointRequestException(e.getMessage(), e.getMessage());
    }
  }
}
