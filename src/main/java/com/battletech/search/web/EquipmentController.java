package com.battletech.search.web;

import com.battletech.search.antlr.QueryVocabulary;
import com.battletech.search.services.EquipmentService;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.ModelAndView;

/**
 * The search guide: how a query is put together, the words each part takes, and every stored item
 * with the slang a search knows it by. The word lists come from QueryVocabulary, like the search
 * box's, so they stay in step with the grammar.
 */
@Controller
public class EquipmentController {
  private final EquipmentService equipmentService;

  public EquipmentController(EquipmentService equipmentService) {
    this.equipmentService = equipmentService;
  }

  @GetMapping("/equipment")
  public ModelAndView equipment() {
    ModelAndView page = new ModelAndView("equipment");
    page.addObject("equipment", equipmentService.equipmentTree());
    page.addObject("weightClasses", QueryVocabulary.weightClasses());
    page.addObject("omniWords", QueryVocabulary.omniWords());
    page.addObject("withWords", QueryVocabulary.withWords());
    page.addObject("comparatorsBefore", QueryVocabulary.comparatorsBefore());
    page.addObject("comparatorsAfter", QueryVocabulary.comparatorsAfter());
    page.addObject("techWords", List.copyOf(QueryVocabulary.techs().keySet()));
    page.addObject("fireControls", QueryVocabulary.fireControls());
    page.addObject("components", QueryVocabulary.components());
    return page;
  }
}
