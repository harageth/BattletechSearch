package com.battletech.search;

import java.util.LinkedList;
import java.util.List;

public class Fibinacci {

  List<Float> cachedFib = new LinkedList<Float>();

  public Fibinacci(){
    cachedFib.add(0.0f);
    cachedFib.add(1.0f);
  }

  public float calculateFibinacci(int x) {
    if(cachedFib.get(x) != null) {
      return cachedFib.get(x);
    }


    float total = 0;
    //float result = Fibinacci(x-2) + Fibinacci(x-1)/x;
    for(int i = 2; i<=x; i++) {

      //Fibinacci(x-2)
      total += cachedFib.get(x-2);

      //Fibinacci(x-1)/x
      total += cachedFib.get(x-1)/x;
      cachedFib.add(total);
    }


    return total;
  }

}
