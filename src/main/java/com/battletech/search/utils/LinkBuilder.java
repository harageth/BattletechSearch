package com.battletech.search.utils;

public class LinkBuilder {
  public static String buildSarnaUnitURI(String unit, String designation) {
    StringBuilder builder = new StringBuilder();
    builder.append("https://www.sarna.net/wiki/");
    builder.append(unit);
    builder.append("#");
    builder.append(designation);
    return builder.toString();
  }
}
