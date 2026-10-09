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
  /// Wave power earned by every 100 points of noise. Calibrated on the
  /// plan of a human win (`scenarios/replays/victoire-tour-85.json`)
  /// played again with other dice and a careful defence: with the noise
  /// of the kernel levels, the research choices and the monster
  /// families, it wins 5 of 40 games, and the careful script (conquest)
  /// 3 of 20.
  static const int powerPer100Noise = 36;
  static const int minMonsters = 5;
  static const int mediumFromPower = 30;
  static const int hardFromPower = 80;

  static MonsterLair fromTotalNoise(int totalNoise, {Random? random}) {
    final int power = totalNoise * powerPer100Noise ~/ 100;
    final MonsterDifficulty difficulty =
        power >= hardFromPower
            ? MonsterDifficulty.hard
            : power >= mediumFromPower
            ? MonsterDifficulty.medium
            : MonsterDifficulty.easy;
    final int generic = max(power ~/ _costOf(difficulty), minMonsters);
    final List<MonsterFamily> families = List<MonsterFamily>.of(
      MonsterFamily.availableAt(MonsterUnitStats.levelFor(difficulty)),
    )..shuffle(random ?? Random());
    final int firstShare = (generic + 1) ~/ 2;
    return MonsterLair(
      difficulty: difficulty,
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
