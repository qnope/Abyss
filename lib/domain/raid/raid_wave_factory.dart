import '../map/monster_difficulty.dart';
import '../map/monster_lair.dart';

/// Builds the monster wave of a raid from the noise made so far.
///
/// The wave power is `totalNoise / 5`. Weak waves are made of level 1
/// monsters; stronger ones switch to fewer, tougher monsters.
abstract final class RaidWaveFactory {
  static const int noisePerPower = 5;
  static const int minMonsters = 5;
  static const int mediumFromPower = 30;
  static const int hardFromPower = 80;

  static MonsterLair fromTotalNoise(int totalNoise) {
    final int power = totalNoise ~/ noisePerPower;
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
