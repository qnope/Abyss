import 'dart:math';

import '../fight/loot_calculator.dart';
import '../map/monster_difficulty.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';

/// Resources won or lost at the end of a raid.
abstract final class RaidSpoils {
  /// Share of each stock (pearls aside) the monsters carry away.
  static const double pillageRate = 0.3;

  /// Half the loot of a lair of the same [difficulty], or [percent] % of
  /// that half for a lesser fight.
  static Map<ResourceType, int> loot(
    MonsterDifficulty difficulty, {
    Random? random,
    int percent = 100,
  }) {
    final Map<ResourceType, int> full =
        LootCalculator(random: random).compute(difficulty);
    return full.map(
      (ResourceType t, int v) => MapEntry(t, v * percent ~/ 200),
    );
  }

  /// Removes [rate] of every stock but pearls and returns what was taken.
  static Map<ResourceType, int> pillage(
    Map<ResourceType, Resource> resources, {
    double rate = pillageRate,
  }) {
    final Map<ResourceType, int> taken = <ResourceType, int>{};
    for (final MapEntry<ResourceType, Resource> e in resources.entries) {
      if (e.key == ResourceType.pearl) continue;
      final int amount = (e.value.amount * rate).floor();
      if (amount <= 0) continue;
      e.value.amount -= amount;
      taken[e.key] = amount;
    }
    return taken;
  }
}
