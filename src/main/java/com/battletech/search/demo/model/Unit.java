package com.battletech.search.demo.model;

import lombok.Data;

@Data
public class Unit extends Searchable {
    String name;
    Tech techLevel;

    Movement movement;

    String era;

    int weight;
    int weightClass;// could be a derived value

    public String getQuery() {

        return null;
    }
}
