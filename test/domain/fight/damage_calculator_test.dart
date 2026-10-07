import 'package:abyss/domain/fight/damage_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DamageCalculator.compute', () {
    test('returns atk when defender has no defense', () {
      expect(DamageCalculator.compute(atk: 10, def: 0), 10);
    });

    test('defense equal to the armour constant halves damage', () {
      expect(DamageCalculator.compute(atk: 10, def: 10), 5);
    });

    test('floors fractional damage so small DEF already matters', () {
      // 5 * 10 / 12 = 4.17 -> floor -> 4
      expect(DamageCalculator.compute(atk: 5, def: 2), 4);
      // 2 * 10 / 16 = 1.25 -> floor -> 1
      expect(DamageCalculator.compute(atk: 2, def: 6), 1);
    });

    test('clamps to minimum of 1 when defense is overwhelming', () {
      expect(DamageCalculator.compute(atk: 1, def: 1000), 1);
    });

    test('triples damage on critical hit with no defense', () {
      expect(DamageCalculator.compute(atk: 10, def: 0, crit: true), 30);
    });

    test('triples clamped minimum on critical hit', () {
      expect(DamageCalculator.compute(atk: 1, def: 1000, crit: true), 3);
    });

    test('ignoreDef deals full atk whatever the defense', () {
      expect(
        DamageCalculator.compute(atk: 10, def: 20, ignoreDef: true),
        10,
      );
    });

    test('multiplier scales damage before the crit', () {
      expect(DamageCalculator.compute(atk: 8, def: 10, multiplier: 2), 8);
      expect(
        DamageCalculator.compute(
          atk: 8,
          def: 10,
          multiplier: 2,
          crit: true,
        ),
        24,
      );
    });

    test('matches the explicit formula for several combinations', () {
      const cases = <Map<String, int>>[
        {'atk': 100, 'def': 0, 'expected': 100},
        {'atk': 100, 'def': 10, 'expected': 50},
        {'atk': 100, 'def': 30, 'expected': 25},
        {'atk': 50, 'def': 5, 'expected': 33}, // 500/15 = 33.3 -> 33
        {'atk': 7, 'def': 4, 'expected': 5}, // 70/14 = 5
      ];
      for (final c in cases) {
        expect(
          DamageCalculator.compute(atk: c['atk']!, def: c['def']!),
          c['expected'],
          reason: 'atk=${c['atk']} def=${c['def']}',
        );
      }
    });
  });
}
