import 'dart:io';
import 'dart:convert';
import 'dart:math';

Map<int, int> calculated = {};

calculate3n1(int n) {
  if (!calculated.containsKey(n)) {
    calculated[n] = n == 1? 1: calculate3n1(n.isEven? n ~/ 2: 3*n + 1) + 1;
  }
  return calculated[n];
}

main() {
  
  var file = new File("3n1-test.txt");
  
  var future = file.readAsLines(encoding: Encoding.getByName("ASCII"));
  future.then((lines) {
    for (var l in lines) {
      var ls = l.split(" ");
      var i = int.parse(ls[0]);
      var j = int.parse(ls[1]);
      
      var maxij = 0; 
      for (var k = i; k<=j; k++) {
        calculated[k] = calculate3n1(k);
        maxij = max(maxij, calculated[k]);
      }
      print("$i $j $maxij");
        
    };
  });
  
}