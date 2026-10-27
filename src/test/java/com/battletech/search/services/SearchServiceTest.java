package com.battletech.search.services;


import java.io.IOException;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@Disabled("No Spring context or test data yet; to be rewritten with proper search tests")
class SearchServiceTest {
  @Autowired
  SearchService service;

  @Test
  public void searchTest() throws IOException {
    //we will need to setup the data here...
    service.performQuery("Mechs with 2 LL");
  }
}
