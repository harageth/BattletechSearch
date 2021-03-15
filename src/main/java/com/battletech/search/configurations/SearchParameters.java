package com.battletech.search.configurations;


import com.battletech.search.entities.Unit;
import java.util.HashMap;
import java.util.Map;

public class SearchParameters {

    /*
    Lets think about the data type here...
    We need to be able to search for any of the values in a particular List but then after we find the values we need to
    be able to reassociate them with whatever they are... This seems like a graph. vee -> vehicle, tracked -> is a vehicle
     */
    public Map<String, Unit> unitType = new HashMap<String, Unit>();
}
