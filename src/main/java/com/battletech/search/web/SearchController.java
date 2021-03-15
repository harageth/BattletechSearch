package com.battletech.search.web;

import com.battletech.search.entities.Unit;
import com.battletech.search.model.dto.MechDTO;
import com.battletech.search.services.EquipmentService;
import com.battletech.search.services.SearchService;
import com.battletech.search.services.UnitService;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

@Slf4j
@Controller
@RequestMapping("/")
public class SearchController {
  SearchService searchService;
  UnitService unitService;
  EquipmentService equipService;


  @Autowired
  public SearchController(SearchService searchService, UnitService unitService, EquipmentService equipService) {
    //initialize any class level things here
    this.searchService = searchService;
    this.unitService = unitService;
    this.equipService = equipService;
  }

  // this should be a post mapping with a body value
  @GetMapping("/search/")
  public ModelAndView search(@RequestParam("query") String query) throws IOException {
    ModelAndView modelAndView = new ModelAndView("search");
    List<Map<String, Object>> results = searchService.performQuery(query);
    MechDTO dto = new MechDTO();
    for(Map<String, Object> value: results) {
      dto.addUnit(value.get("name").toString(), value.get("designation").toString());
    }

    modelAndView.addObject("form", dto);
    return modelAndView;
  }

  @GetMapping("/readFile/")
  public List<Unit> readStuffIn() throws IOException {
    // read in file and submit to database
    unitService.PDFTest();
    //unitService.persistVehicles();
    //unitService.persistMechs();
    //Unit mech = ReadMegaMek.ReadMTF();
    //return Collections.singletonList(mech);
    return null;
  }

  @PostMapping("/addSlang/{equipName}")
  public void addSlang(@PathVariable String equipName, @RequestBody List<String>slangTerms) {
    equipService.addSlangToEquipment(equipName, slangTerms);
  }


}
