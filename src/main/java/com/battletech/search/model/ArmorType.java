package com.battletech.search.model;

/**
 * A unit's armor type. Mech files name it ("Ferro-Fibrous(Clan)"); vehicle files give MegaMek's
 * EquipmentType.T_ARMOR_* code (<armor_type>). Patchwork armor has a type per location, which isn't
 * stored until armor is imported.
 */
public enum ArmorType {
  STANDARD("Standard", 0),
  FERRO_FIBROUS("Ferro-Fibrous", 1),
  REACTIVE("Reactive", 2),
  REFLECTIVE("Reflective", 3),
  HARDENED("Hardened", 4),
  LIGHT_FERRO_FIBROUS("Light Ferro-Fibrous", 5),
  HEAVY_FERRO_FIBROUS("Heavy Ferro-Fibrous", 6),
  PATCHWORK("Patchwork", 7),
  // mechs' and vehicles' stealth armor are different codes
  STEALTH("Stealth", 8, 22),
  FERRO_FIBROUS_PROTOTYPE("Ferro-Fibrous Prototype", 9),
  COMMERCIAL("Commercial", 10),
  INDUSTRIAL("Industrial", 14),
  HEAVY_INDUSTRIAL("Heavy Industrial", 15),
  FERRO_LAMELLOR("Ferro-Lamellor", 16),
  PRIMITIVE("Primitive", 17),
  ANTI_PENETRATIVE_ABLATION("Anti-Penetrative Ablation", 23),
  HEAT_DISSIPATING("Heat-Dissipating", 24),
  IMPACT_RESISTANT("Impact-Resistant", 25),
  BALLISTIC_REINFORCED("Ballistic-Reinforced", 26),
  // support vehicle armor by barrier armor rating
  BAR_2("BAR 2", 43),
  BAR_3("BAR 3", 44),
  BAR_4("BAR 4", 45),
  BAR_5("BAR 5", 46),
  BAR_6("BAR 6", 47),
  BAR_7("BAR 7", 48),
  BAR_8("BAR 8", 49),
  BAR_9("BAR 9", 50),
  BAR_10("BAR 10", 51);

  private final String text;
  private final int[] codes;

  ArmorType(String text, int... codes) {
    this.text = text;
    this.codes = codes;
  }

  public String getText() {
    return text;
  }

  public static ArmorType fromString(String text) {
    for (ArmorType type : values()) {
      if (type.text.equalsIgnoreCase(text.trim())) {
        return type;
      }
    }
    return null;
  }

  public static ArmorType fromCode(int code) {
    for (ArmorType type : values()) {
      for (int each : type.codes) {
        if (each == code) {
          return type;
        }
      }
    }
    return null;
  }
}
