import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';

void main() {
  group('squareSideForLevel', () {
    test('level 0 returns 2', () {
      expect(RevealAreaCalculator.squareSideForLevel(0), 2);
    });

    test('level 1 returns 3', () {
      expect(RevealAreaCalculator.squareSideForLevel(1), 3);
    });

    test('level 2 returns 4', () {
      expect(RevealAreaCalculator.squareSideForLevel(2), 4);
    });

    test('level 3 returns 5', () {
      expect(RevealAreaCalculator.squareSideForLevel(3), 5);
    });

    test('level 4 returns 7', () {
      expect(RevealAreaCalculator.squareSideForLevel(4), 7);
    });

    test('level 5 returns 9', () {
      expect(RevealAreaCalculator.squareSideForLevel(5), 9);
    });
  });
}
