package ;

import haxe.unit.*;
import transform.*;
using Lambda;

typedef Item = {
  name:String,
  value:Float,
}

typedef State = {
  shop:{
    items:Array<Item>,
    taxPercent:Int,
  },
}
class RunTests extends TestCase {

  static function main() {
    var runner = new TestRunner();
    runner.add(new RunTests());
    travix.Logger.exit(runner.run() ? 0 : 500); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }
  
  function testTransform() {
    var subtotalCount = 0;
    var taxCount = 0;
    var totalCount = 0;
    
    function shopItems(state:State) return state.shop.items;
    function taxPercent(state:State) return state.shop.taxPercent;
    var subtotal = Transformer.create(shopItems, function(items:Array<Item>) {
      subtotalCount ++;
      return items.fold(function(item, acc) return acc + item.value, 0);
    });
    var tax = Transformer.create([subtotal, taxPercent], function(subtotal:Float, taxPercent:Int) {
      taxCount ++;
      return subtotal * taxPercent / 100;
    });
    var total = Transformer.create([subtotal, tax], function(subtotal:Float, tax:Float) {
      totalCount ++;
      return {total: subtotal + tax};
    });
    
    var exampleState = {
      shop: {
        taxPercent: 8,
        items: [
          {name: 'apple', value: 1.2},
          {name: 'orange', value: 0.95},
        ]
      }
    }
    
    assertEquals(2.15, subtotal(exampleState));
    assertEquals(0.172, tax(exampleState));
    assertEquals(2.322, total(exampleState).total);
    assertEquals(1, subtotalCount);
    assertEquals(1, taxCount);
    assertEquals(1, totalCount);
    
    assertEquals(2.15, subtotal(exampleState));
    assertEquals(0.172, tax(exampleState));
    assertEquals(2.322, total(exampleState).total);
    assertEquals(1, subtotalCount);
    assertEquals(1, taxCount);
    assertEquals(1, totalCount);
    
    exampleState.shop.taxPercent = 10;
    assertEquals(2.15, subtotal(exampleState));
    assertEquals(0.215, tax(exampleState));
    assertEquals(2365, Math.round(total(exampleState).total*1000));
    assertEquals(1, subtotalCount);
    assertEquals(2, taxCount);
    assertEquals(2, totalCount);
    
    assertEquals(2.15, subtotal(exampleState));
    assertEquals(0.215, tax(exampleState));
    assertEquals(2365, Math.round(total(exampleState).total*1000));
    assertEquals(1, subtotalCount);
    assertEquals(2, taxCount);
    assertEquals(2, totalCount);
    
    exampleState.shop.items = exampleState.shop.items.concat([{name: 'pear', value: 1}]);
    assertEquals(3.15, subtotal(exampleState));
    assertEquals(0.315, tax(exampleState));
    assertEquals(3465, Math.round(total(exampleState).total*1000));
    assertEquals(2, subtotalCount);
    assertEquals(3, taxCount);
    assertEquals(3, totalCount);
    
    assertEquals(3.15, subtotal(exampleState));
    assertEquals(0.315, tax(exampleState));
    assertEquals(3465, Math.round(total(exampleState).total*1000));
    assertEquals(2, subtotalCount);
    assertEquals(3, taxCount);
    assertEquals(3, totalCount);
  }
  
}