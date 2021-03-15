package com.battletech.search.services;


import java.io.IOException;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

class SearchServiceTest {
  @Autowired
  SearchService service;

  @Test
  public void searchTest() throws IOException {
    //we will need to setup the data here...
    service.performQuery("Mechs with 2 LL");
  }
}