import 'package:abyss/domain/fight/damage_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DamageCalculator.compute', () {
    test('returns atk when defender has no defense', () {
      expect(DamageCalculator.compute(atk: 10, def: 0), 10);
    });

    test('ceils fractional damage when defense reduces output', () {
      // 10 * 100 / 110 = 9.0909... -> ceil -> 10
      expect(DamageCalculator.compute(atk: 10, def: 10), 10);
    });

    test('ceils to 1 when result is exactly 1.0', () {
      // 2 * 100 / 200 = 1.0 -> ceil -> 1
      expect(DamageCalculator.compute(atk: 2, def: 100), 1);
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

    test('is deterministic across repeated calls', () {
      final samples = <List<int>>[
        [50, 25],
        [7, 13],
        [123, 456],
        [1, 0],
        [99, 99],
      ];
      for (final sample in samples) {
        final atk = sample[0];
        final def = sample[1];
        final first = DamageCalculator.compute(atk: atk, def: def);
        final second = DamageCalculator.compute(atk: atk, def: def);
        expect(first, second);
        expect(first, greaterThanOrEqualTo(1));

        final critFirst =
            DamageCalculator.compute(atk: atk, def: def, crit: true);
        expect(critFirst, first * 3);
      }
    });

    test('matches the explicit formula for several combinations', () {
      const cases = <Map<String, int>>[
        {'atk': 100, 'def': 0, 'expected': 100},
        {'atk': 100, 'def': 100, 'expected': 50},
        {'atk': 100, 'def': 300, 'expected': 25},
        {'atk': 50, 'def': 50, 'expected': 34}, // 50*100/150 = 33.33 -> 34
        {'atk': 33, 'def': 67, 'expected': 20}, // 33*100/167 = 19.76 -> 20
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
