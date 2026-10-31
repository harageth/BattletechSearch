package com.battletech.search.utils;

import static org.assertj.core.api.Assertions.assertThat;

import com.battletech.search.utils.ComponentNames.Kind;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class ComponentNamesTest {

  @Test
  void typesWithTheirKindWord() {
    assertThat(ComponentNames.find("xl engine").kind()).isEqualTo(Kind.ENGINE);
    assertThat(ComponentNames.find("XL Engine").types()).containsExactly("XL");
    assertThat(ComponentNames.find("xl gyro").kind()).isEqualTo(Kind.GYRO);
    assertThat(ComponentNames.find("small cockpit").types()).containsExactly("SMALL");
    assertThat(ComponentNames.find("command console").types()).containsExactly("COMMAND_CONSOLE");
    assertThat(ComponentNames.find("ferro-fibrous armor").kind()).isEqualTo(Kind.ARMOR);
    assertThat(ComponentNames.find("endo steel structure").kind()).isEqualTo(Kind.STRUCTURE);
    // MegaMek's "Fusion" is the standard engine
    assertThat(ComponentNames.find("standard engine").types()).containsExactly("FUSION");
  }

  @Test
  void armorAndStructureWithoutTheKindWordWhenThatsClear() {
    assertThat(ComponentNames.find("endo steel").kind()).isEqualTo(Kind.STRUCTURE);
    assertThat(ComponentNames.find("endo-steel").kind()).isEqualTo(Kind.STRUCTURE);
    assertThat(ComponentNames.find("ferro fibrous").kind()).isEqualTo(Kind.ARMOR);
    assertThat(ComponentNames.find("stealth").kind()).isEqualTo(Kind.ARMOR);
    // shared by several kinds, or an engine / gyro / cockpit: the kind word is needed
    for (String unclear : List.of("standard", "industrial", "xl", "compact", "small")) {
      assertThat(ComponentNames.find(unclear)).as(unclear).isNull();
    }
  }

  @Test
  void aBaseTypeTakesItsPrototypeAlong() {
    assertThat(ComponentNames.find("endo steel").types()).containsExactly("ENDO_STEEL", "ENDO_STEEL_PROTOTYPE");
    assertThat(ComponentNames.find("endo steel prototype").types()).containsExactly("ENDO_STEEL_PROTOTYPE");
    assertThat(ComponentNames.find("ferro-fibrous").types()).containsExactly("FERRO_FIBROUS", "FERRO_FIBROUS_PROTOTYPE");
  }

  @Test
  void noComponentNameIsAlsoEquipment() {
    // a component is looked up before equipment, so it must never hide a MegaMek name, family or shorthand
    Set<String> equipmentKeys = new HashSet<>();
    for (String resource : List.of(EquipmentNames.ALIASES, EquipmentNames.FAMILIES, EquipmentNames.SHORTHAND)) {
      for (String[] row : EquipmentNames.readTsv(resource)) {
        equipmentKeys.add(EquipmentNames.slangKey(row[0]));
        equipmentKeys.add(EquipmentNames.slangKey(row[1]));
      }
    }
    assertThat(ComponentNames.keys().keySet()).doesNotContainAnyElementsOf(equipmentKeys);
  }

  @Test
  void namesForTheSearchBox() {
    assertThat(ComponentNames.names().get(Kind.ENGINE)).contains("xl engine", "light engine", "fusion engine")
        .doesNotContain("none engine");
    assertThat(ComponentNames.names().get(Kind.COCKPIT)).contains("small cockpit", "command console");
  }
}
