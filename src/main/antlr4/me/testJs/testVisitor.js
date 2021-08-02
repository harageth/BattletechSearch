import BattletechListener from './../BattletechListener.js'

class TestListener extends BattletechListener {

  // Enter a parse tree produced by BattletechParser#line.
  enterLine(ctx) {
    var children = ctx.children;
    children.forEach(function(child, index){

    });

  };

}