package com.battletech.search.model.dto;

import static com.battletech.search.utils.LinkBuilder.buildSarnaUnitURI;

import com.battletech.search.entities.Unit;
import java.util.LinkedList;
import java.util.List;

public class MechDTO {
  public List<UnitDTO> units;
  public List<String> link;

  public MechDTO() {
    units = new LinkedList();
    link = new LinkedList();
  }

  public List<UnitDTO> getUnits() {
    return units;
  }

  public void addUnit(String name, String designation) {
    UnitDTO unit = new UnitDTO();
    unit.setName(name);
    unit.setDesignation(designation);
    unit.setLink(buildSarnaUnitURI(name, designation));
    units.add(unit);
  }

}
