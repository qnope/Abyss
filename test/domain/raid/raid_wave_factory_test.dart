import 'dart:math';

import 'package:abyss/domain/fight/monster_unit_stats.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks [wave] holds [generic] generic monsters shared between its two
/// families, the first one taking the larger half.
void expectShared(MonsterLair wave, int generic) {
  final int first = (generic + 1) ~/ 2;
  expect(wave.unitCount, MonsterUnitStats.countFor(wave.family, first));
  expect(
    wave.secondCount,
    MonsterUnitStats.countFor(wave.secondFamily, generic - first),
  );
}

void main() {
  test('weak waves hold at least 5 level 1 monsters', () {
    final wave = RaidWaveFactory.fromTotalNoise(10, random: Random(1));
    expect(wave.difficulty, MonsterDifficulty.easy);
    expectShared(wave, 5);
  });

  test('36 power per 100 noise, one level 1 monster per power below 30', () {
    final wave = RaidWaveFactory.fromTotalNoise(50, random: Random(1));
    expect(wave.difficulty, MonsterDifficulty.easy);
    expectShared(wave, 18);
  });

  test('level 2 monsters from 30 power, costing 2 power each', () {
    expect(
      RaidWaveFactory.fromTotalNoise(83).difficulty,
      MonsterDifficulty.easy,
    );
    expect(
      RaidWaveFactory.fromTotalNoise(84).difficulty,
      MonsterDifficulty.medium,
    );
    final wave = RaidWaveFactory.fromTotalNoise(150, random: Random(1));
    expect(wave.difficulty, MonsterDifficulty.medium);
    expectShared(wave, 27);
  });

  test('level 3 monsters from 80 power, costing 4 power each', () {
    final wave = RaidWaveFactory.fromTotalNoise(400, random: Random(1));
    expect(wave.difficulty, MonsterDifficulty.hard);
    expectShared(wave, 36);
  });

  test('a wave mixes two different families drawn at random', () {
    final Set<MonsterFamily> seen = <MonsterFamily>{};
    for (int seed = 0; seed < 40; seed++) {
      final wave = RaidWaveFactory.fromTotalNoise(150, random: Random(seed));
      expect(wave.secondFamily, isNot(wave.family));
      seen.addAll(wave.groups.keys.whereType<MonsterFamily>());
    }
    expect(seen, MonsterFamily.availableAt(3).toSet());
  });

  test('colossi never come with level 1 waves', () {
    for (int seed = 0; seed < 40; seed++) {
      final wave = RaidWaveFactory.fromTotalNoise(50, random: Random(seed));
      expect(wave.groups.keys, isNot(contains(MonsterFamily.colossus)));
    }
  });
}
