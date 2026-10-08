import '../map/monster_difficulty.dart';
import '../map/monster_lair.dart';

/// Builds the monster wave of a raid from the noise made so far.
///
/// The wave power is `totalNoise × powerPer100Noise / 100` (about noise
/// ÷ 2.9). Weak waves are made of level 1 monsters; stronger ones switch to
/// fewer, tougher monsters.
abstract final class RaidWaveFactory {
  /// Wave power earned by every 100 points of noise. Calibrated with the
  /// simulation of step 6, then again after the exponential costs of
  /// step 8, so that a careful player (the `conquest` script) wins about
  /// 10 % of the games.
  static const int powerPer100Noise = 35;
  static const int minMonsters = 5;
  static const int mediumFromPower = 30;
  static const int hardFromPower = 80;

  static MonsterLair fromTotalNoise(int totalNoise) {
    final int power = totalNoise * powerPer100Noise ~/ 100;
    final MonsterDifficulty difficulty = power >= hardFromPower
        ? MonsterDifficulty.hard
        : power >= mediumFromPower
            ? MonsterDifficulty.medium
            : MonsterDifficulty.easy;
    final int count = power ~/ _costOf(difficulty);
    return MonsterLair(
      difficulty: difficulty,
      unitCount: count < minMonsters ? minMonsters : count,
    );
  }

  static int _costOf(MonsterDifficulty difficulty) => switch (difficulty) {
        MonsterDifficulty.easy => 1,
        MonsterDifficulty.medium => 2,
        MonsterDifficulty.hard => 4,
      };
}
