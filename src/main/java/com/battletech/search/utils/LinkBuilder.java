package com.battletech.search.utils;

import java.nio.charset.StandardCharsets;
import org.springframework.web.util.UriUtils;

public class LinkBuilder {
  public static String buildSarnaUnitURI(String unit, String designation) {
    // MediaWiki uses underscores for spaces in page names and section anchors
    StringBuilder builder = new StringBuilder();
    builder.append("https://www.sarna.net/wiki/");
    builder.append(UriUtils.encodePath(unit.replace(' ', '_'), StandardCharsets.UTF_8));
    builder.append("#");
    builder.append(UriUtils.encodeFragment(designation.replace(' ', '_'), StandardCharsets.UTF_8));
    return builder.toString();
  }
}
