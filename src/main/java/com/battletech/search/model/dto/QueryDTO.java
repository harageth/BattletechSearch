package com.battletech.search.model.dto;

import java.util.List;
import java.util.Map;
import lombok.Data;

@Data
public class QueryDTO {
  List<String> errors;
  List<Map<String, Object>> resultSet;
}
