package com.battletech.search.demo.web;

import com.battletech.search.demo.entities.Unit;
import com.battletech.search.demo.services.EquipmentService;
import com.battletech.search.demo.services.SearchService;
import com.battletech.search.demo.services.UnitService;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.websocket.server.PathParam;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
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
  public List<Map<String, Object>> search(@RequestParam("query") String query) throws IOException {

    return searchService.performQuery(query);
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
