package com.battletech.search.model;

import jakarta.persistence.Embeddable;
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
