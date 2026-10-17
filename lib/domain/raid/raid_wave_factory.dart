import 'dart:math';

import '../fight/monster_unit_stats.dart';
import '../map/monster_difficulty.dart';
import '../map/monster_family.dart';
import '../map/monster_lair.dart';

/// Builds the monster wave of a raid from the noise made so far, or from
/// the strength of the base when that is the larger.
///
/// The wave power is `totalNoise × powerPer100Noise / 100` (about noise
/// ÷ 2.8), or [defenceSharePercent] % of the `DefenceStrength` of the
/// base when that is more, so a large garrison is never left in peace.
/// Weak waves are made of level 1 monsters; stronger ones switch to
/// fewer, tougher monsters. The power is shared between two families
/// drawn at random, each turned into its own number of monsters.
abstract final class RaidWaveFactory {
  /// Wave power earned by every 100 points of noise, before the
  /// difficulty scales it (see `Difficulty.monsterPercent`).
  static const int powerPer100Noise = 36;

  /// Share of the base's strength a wave matches, at least.
  static const int defenceSharePercent = 75;
  static const int minMonsters = 5;
  static const int mediumFromPower = 30;
  static const int hardFromPower = 80;

  /// [monsterPercent] scales the power, so a harder game also switches
  /// sooner to tougher monsters. [defenceStrength] is the
  /// `DefenceStrength` of the base the wave strikes.
  static MonsterLair fromTotalNoise(
    int totalNoise, {
    Random? random,
    int monsterPercent = 100,
    int defenceStrength = 0,
  }) {
    final (MonsterDifficulty level, int generic) = _sizeOf(
      totalNoise,
      monsterPercent,
      defenceStrength,
    );
    final List<MonsterFamily> families = List<MonsterFamily>.of(
      MonsterFamily.availableAt(MonsterUnitStats.levelFor(level)),
    )..shuffle(random ?? Random());
    return _wave(level, generic, families[0], families[1]);
  }

  /// Every wave [fromTotalNoise] can draw for the same noise, one for each
  /// pair of families, so a defence can be checked against all of them.
  static List<MonsterLair> everyFromTotalNoise(
    int totalNoise, {
    int monsterPercent = 100,
  }) {
    final (MonsterDifficulty level, int generic) = _sizeOf(
      totalNoise,
      monsterPercent,
      0,
    );
    final List<MonsterFamily> families = MonsterFamily.availableAt(
      MonsterUnitStats.levelFor(level),
    );
    return <MonsterLair>[
      for (final MonsterFamily a in families)
        for (final MonsterFamily b in families)
          if (a != b) _wave(level, generic, a, b),
    ];
  }

  static (MonsterDifficulty, int) _sizeOf(
    int totalNoise,
    int monsterPercent,
    int defenceStrength,
  ) {
    final int raw = max(
      totalNoise * powerPer100Noise,
      defenceStrength * defenceSharePercent,
    );
    final int power = raw * monsterPercent ~/ 10000;
    final MonsterDifficulty level =
        power >= hardFromPower
            ? MonsterDifficulty.hard
            : power >= mediumFromPower
            ? MonsterDifficulty.medium
            : MonsterDifficulty.easy;
    return (level, max(power ~/ _costOf(level), minMonsters));
  }

  static MonsterLair _wave(
    MonsterDifficulty level,
    int generic,
    MonsterFamily first,
    MonsterFamily second,
  ) {
    final int firstShare = (generic + 1) ~/ 2;
    return MonsterLair(
      difficulty: level,
      family: first,
      unitCount: MonsterUnitStats.countFor(first, firstShare),
      secondFamily: second,
      secondCount: MonsterUnitStats.countFor(second, generic - firstShare),
    );
  }

  static int _costOf(MonsterDifficulty difficulty) => switch (difficulty) {
    MonsterDifficulty.easy => 1,
    MonsterDifficulty.medium => 2,
    MonsterDifficulty.hard => 4,
  };
}
