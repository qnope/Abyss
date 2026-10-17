import 'dart:math';

import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

String _keyOf(MonsterLair w) =>
    '${w.difficulty} ${w.family} ${w.unitCount} '
    '${w.secondFamily} ${w.secondCount}';

void main() {
  group('RaidWaveFactory.everyFromTotalNoise', () {
    test('holds one wave for each ordered pair of families', () {
      // Level 1 monsters come in 3 families, tougher ones in 4.
      expect(RaidWaveFactory.everyFromTotalNoise(10), hasLength(6));
      expect(RaidWaveFactory.everyFromTotalNoise(3000), hasLength(12));
    });

    test('holds every wave the noise can draw, and only those', () {
      for (final int noise in <int>[10, 300, 3000]) {
        final Set<String> every =
            RaidWaveFactory.everyFromTotalNoise(
              noise,
              monsterPercent: 70,
            ).map(_keyOf).toSet();
        final Set<String> drawn = <String>{
          for (int seed = 0; seed < 200; seed++)
            _keyOf(
              RaidWaveFactory.fromTotalNoise(
                noise,
                random: Random(seed),
                monsterPercent: 70,
              ),
            ),
        };
        expect(drawn, every, reason: 'noise $noise');
      }
    });
  });
}
