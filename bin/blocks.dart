import 'package:unittest/unittest.dart';

solve(input) {
  return "abc";
}

main() {
  test('sample', () =>
      expect(solve(
          '10\n'
          'move 9 onto 1\n'
          'move 8 over 1\n'
          'move 7 over 1\n'
          'move 6 over 1\n'
          'pile 8 over 6\n'
          'pile 8 over 5\n'
          'move 2 over 1\n'
          'move 4 over 9\n'
          'quit\n'),
          '0: 0\n'
          '1: 1 9 2 4\n'
          '2:\n'
          '3: 3\n'
          '4:\n'
          '5: 5 8 7 6\n'
          '6:\n'
          '7:\n'
          '8:\n'
          '9:\n')
      );
  
  
}