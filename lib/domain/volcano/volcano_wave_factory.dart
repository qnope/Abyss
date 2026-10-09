import 'dart:math';

import '../map/monster_difficulty.dart';
import '../map/monster_family.dart';
import '../map/monster_lair.dart';

/// Builds the kraken wave that hits a kernel of a given level: the closer
/// to victory, the more krakens rise from the depths.
abstract final class VolcanoWaveFactory {
  /// Krakens of a wave on a level 0 kernel.
  static const int baseKrakens = 2;

  /// Krakens added by every three kernel levels. Calibrated so that the
  /// garrison that wins 9 times in 10 (Briseurs and Gardiens, 2 for 1,
  /// with the magma rampart) holds about 12 units at level 1, 30 at
  /// level 5 and 50 at level 9.
  static const int krakensPerThreeLevels = 4;

  /// Krakens of a wave on a kernel of [kernelLevel], scaled by
  /// [monsterPercent] (see `Difficulty.monsterPercent`); at least one.
  static int krakensFor(int kernelLevel, {int monsterPercent = 100}) => max(
    1,
    (baseKrakens + krakensPerThreeLevels * kernelLevel ~/ 3) *
        monsterPercent ~/
        100,
  );

  static MonsterLair fromKernelLevel(
    int kernelLevel, {
    int monsterPercent = 100,
  }) => MonsterLair(
    difficulty: MonsterDifficulty.hard,
    family: MonsterFamily.kraken,
    unitCount: krakensFor(kernelLevel, monsterPercent: monsterPercent),
  );
}
