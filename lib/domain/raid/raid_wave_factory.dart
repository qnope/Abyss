import 'dart:math';

import '../fight/monster_unit_stats.dart';
import '../map/monster_difficulty.dart';
import '../map/monster_family.dart';
import '../map/monster_lair.dart';

/// Builds the monster wave of a raid from the noise made so far.
///
/// The wave power is `totalNoise × powerPer100Noise / 100` (about noise
/// ÷ 2.8). Weak waves are made of level 1 monsters; stronger ones switch to
/// fewer, tougher monsters. The power is shared between two families
/// drawn at random, each turned into its own number of monsters.
abstract final class RaidWaveFactory {
  /// Wave power earned by every 100 points of noise, before the
  /// difficulty scales it (see `Difficulty.monsterPercent`).
  static const int powerPer100Noise = 36;
  static const int minMonsters = 5;
  static const int mediumFromPower = 30;
  static const int hardFromPower = 80;

  /// [monsterPercent] scales the power, so a harder game also switches
  /// sooner to tougher monsters.
  static MonsterLair fromTotalNoise(
    int totalNoise, {
    Random? random,
    int monsterPercent = 100,
  }) {
    final int power = totalNoise * powerPer100Noise * monsterPercent ~/ 10000;
    final MonsterDifficulty level =
        power >= hardFromPower
            ? MonsterDifficulty.hard
            : power >= mediumFromPower
            ? MonsterDifficulty.medium
            : MonsterDifficulty.easy;
    final int generic = max(power ~/ _costOf(level), minMonsters);
    final List<MonsterFamily> families = List<MonsterFamily>.of(
      MonsterFamily.availableAt(MonsterUnitStats.levelFor(level)),
    )..shuffle(random ?? Random());
    final int firstShare = (generic + 1) ~/ 2;
    return MonsterLair(
      difficulty: level,
      family: families[0],
      unitCount: MonsterUnitStats.countFor(families[0], firstShare),
      secondFamily: families[1],
      secondCount: MonsterUnitStats.countFor(families[1], generic - firstShare),
    );
  }

  static int _costOf(MonsterDifficulty difficulty) => switch (difficulty) {
    MonsterDifficulty.easy => 1,
    MonsterDifficulty.medium => 2,
    MonsterDifficulty.hard => 4,
  };
}
