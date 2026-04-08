import 'dart:math';

import '../map/monster_difficulty.dart';
import '../resource/resource_type.dart';

class LootCalculator {
  final Random _random;

  LootCalculator({Random? random}) : _random = random ?? Random();

  Map<ResourceType, int> compute(MonsterDifficulty difficulty) {
    final range = _rangeFor(difficulty);
    final pearls = _pearlsFor(difficulty);
    return {
      ResourceType.algae: _roll(range.$1, range.$2),
      ResourceType.coral: _roll(range.$1, range.$2),
      ResourceType.ore: _roll(range.$1, range.$2),
      ResourceType.pearl: pearls,
    };
  }

  int _roll(int min, int max) => min + _random.nextInt(max - min + 1);

  (int, int) _rangeFor(MonsterDifficulty difficulty) {
    switch (difficulty) {
      case MonsterDifficulty.easy:
        return (300, 500);
      case MonsterDifficulty.medium:
        return (500, 1000);
      case MonsterDifficulty.hard:
        return (1000, 2000);
    }
  }

  int _pearlsFor(MonsterDifficulty difficulty) {
    switch (difficulty) {
      case MonsterDifficulty.easy:
        return 0;
      case MonsterDifficulty.medium:
        return 2;
      case MonsterDifficulty.hard:
        return 10;
    }
  }
}
