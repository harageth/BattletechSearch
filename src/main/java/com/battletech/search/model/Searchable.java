package com.battletech.search.model;

public interface Searchable {

  // everything should be searchable but we want to decorate our mech with more information to extend this function
  public abstract String getQuery();
}
