import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnitBoost', () {
    test('none leaves every stat unchanged', () {
      expect(UnitBoost.none.atk(6), 6);
      expect(UnitBoost.none.def(6), 6);
      expect(UnitBoost.none.hp(25), 25);
    });

    test('applies each percent to its own stat, rounded', () {
      const boost = UnitBoost(atkPercent: 20, defPercent: 30, hpPercent: 10);
      expect(boost.atk(5), 6);
      expect(boost.def(6), 8); // 7.8 -> 8
      expect(boost.hp(25), 28); // 27.5 -> 28
    });

    test('tier bonuses stack additively', () {
      const boost = UnitBoost(atkPercent: 30 + 20 + 30);
      expect(boost.atk(10), 18);
    });
  });
}
