import 'dart:math';

import 'package:abyss/domain/fight/crit_roller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CritRoller', () {
    test('always returns false with critChance 0.0', () {
      final roller = CritRoller(critChance: 0.0, random: Random(42));
      for (var i = 0; i < 100; i++) {
        expect(roller.roll(), isFalse);
      }
    });

    test('always returns true with critChance 1.0', () {
      final roller = CritRoller(critChance: 1.0, random: Random(42));
      for (var i = 0; i < 100; i++) {
        expect(roller.roll(), isTrue);
      }
    });

    test('produces deterministic sequence with fixed seed', () {
      final roller = CritRoller(critChance: 0.05, random: Random(1));
      final expected = <bool>[
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ];
      final actual = <bool>[for (var i = 0; i < 10; i++) roller.roll()];
      expect(actual, expected);
    });

    test('observed rate is within [0.03, 0.07] over 10000 rolls', () {
      final roller = CritRoller(critChance: 0.05, random: Random(1));
      var hits = 0;
      for (var i = 0; i < 10000; i++) {
        if (roller.roll()) hits++;
      }
      final rate = hits / 10000;
      expect(rate, greaterThanOrEqualTo(0.03));
      expect(rate, lessThanOrEqualTo(0.07));
    });

    test('defaults to 0.05 critChance and a fresh Random', () {
      final roller = CritRoller();
      expect(roller.critChance, 0.05);
      // Smoke test: roll() must not throw.
      roller.roll();
    });
  });
}
