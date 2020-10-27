package com.battletech.search.demo.model;

import javax.persistence.Embeddable;
import lombok.Data;

@Data
@Embeddable
public class Movement {
  int walk;
  int potentialWalk;
  int run;
  int potentialRun;
  int jump;
  int bonusJump;

  public void setWalk(int walk) {
    this.walk = walk;

    if(walk%2 == 0) {

    }
  }

}
