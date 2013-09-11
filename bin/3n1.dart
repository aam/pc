import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:unittest/unittest.dart';

Map<int, int> calculated = {};

calculate3n1(int n) {
  if (!calculated.containsKey(n)) {
    calculated[n] = n == 1? 1: calculate3n1(n.isEven? n ~/ 2: 3*n + 1) + 1;
  }
  return calculated[n];
}

solve(i, j) {
  var maxij = 0;
  for (var k = i; k<=j; k++) {
    calculated[k] = calculate3n1(k);
    maxij = max(maxij, calculated[k]);
  }
  return maxij;
}

solveFile() {
  var file = new File("3n1-test.txt");
  
  var future = file.readAsLines(encoding: Encoding.getByName("ASCII"));
  future.then((lines) {
    for (var l in lines) {
      var ls = l.split(" ");
      var i = int.parse(ls[0]);
      var j = int.parse(ls[1]);
      var maxij = solve(i, j);
      print("$i $j $maxij");
    };
  });
  
}

void main() {
  test('1-10', () =>
      expect(solve(1, 10), 20));
  test('100-200', () =>
      expect(solve(100, 200), 125));
  test('201-210', () =>
      expect(solve(201, 210), 89));
  test('900-1000', () =>
      expect(solve(900, 1000), 174));
}