import 'package:abyss/domain/fight/military_bonus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MilitaryBonus.boost', () {
    test('level 0 leaves the stat unchanged', () {
      expect(MilitaryBonus.boost(6, 0), 6);
    });

    test('adds 20 % per level, rounded', () {
      expect(MilitaryBonus.boost(5, 1), 6);
      expect(MilitaryBonus.boost(6, 3), 10);
      expect(MilitaryBonus.boost(10, 5), 20);
    });
  });
}
