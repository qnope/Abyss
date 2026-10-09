import 'dart:math';

import '../fight/monster_unit_stats.dart';
import 'monster_difficulty.dart';
import 'monster_family.dart';
import 'monster_lair.dart';

/// Builds the monster lair of a map cell.
abstract final class LairBuilder {
  /// A lair of [difficulty] on cell [cellIndex]. Its size is rolled with
  /// the map's [random]; its family comes from [familySeed] and the cell
  /// through a generator of its own, so placing families never consumes
  /// the map's dice: a seed still makes the same map, and replays of
  /// older games still find their lairs and treasures where they were.
  static MonsterLair build({
    required MonsterDifficulty difficulty,
    required Random random,
    required int familySeed,
    required int cellIndex,
  }) {
    final int rolled = _rollUnitCount(difficulty, random);
    final MonsterFamily family = familyFor(
      familySeed,
      cellIndex,
      MonsterUnitStats.levelFor(difficulty),
    );
    return MonsterLair(
      difficulty: difficulty,
      unitCount: MonsterUnitStats.countFor(family, rolled),
      family: family,
    );
  }

  static MonsterFamily familyFor(int seed, int cellIndex, int level) {
    final Random random = Random((seed * 7919 + cellIndex) & 0x7FFFFFFF);
    final List<MonsterFamily> families = MonsterFamily.availableAt(level);
    return families[random.nextInt(families.length)];
  }

  static int _rollUnitCount(MonsterDifficulty difficulty, Random random) =>
      switch (difficulty) {
        MonsterDifficulty.easy => 20 + random.nextInt(31),
        MonsterDifficulty.medium => 60 + random.nextInt(41),
        MonsterDifficulty.hard => 120 + random.nextInt(81),
      };
}
