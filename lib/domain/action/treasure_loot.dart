import 'dart:math';

import '../event/event_rules.dart';
import '../map/cell_content_type.dart';
import '../resource/resource_type.dart';

/// What a treasure, ruins or a wreck hold, before the tech loot bonus and
/// the storage cap.
abstract final class TreasureLoot {
  /// Treasures and ruins are rarer, so each one is worth more.
  static const int rewardMultiplier = 3;

  /// Loot of [content] on [level], rolled with [random] in a fixed order;
  /// nothing for a cell that holds no loot.
  static Map<ResourceType, int> of(
    CellContentType content,
    Random random,
    int level,
  ) => switch (content) {
    CellContentType.resourceBonus => _multiplied({
      ResourceType.algae: 50 + random.nextInt(51),
      ResourceType.coral: 30 + random.nextInt(21),
      ResourceType.ore: 30 + random.nextInt(21),
    }),
    CellContentType.ruins => _multiplied({
      ResourceType.algae: random.nextInt(101),
      ResourceType.coral: random.nextInt(26),
      ResourceType.ore: random.nextInt(26),
      // Deeper ruins hold more pearls: 0-2 on level 1, 0-3 on 2, 0-4 on 3.
      ResourceType.pearl: random.nextInt(level + 2),
    }),
    // A wreck holds a fixed loot, never multiplied.
    CellContentType.wreck => const {
      ResourceType.coral: EventRules.wreckCoral,
      ResourceType.ore: EventRules.wreckOre,
      ResourceType.pearl: EventRules.wreckPearls,
    },
    _ => const {},
  };

  static Map<ResourceType, int> _multiplied(Map<ResourceType, int> base) =>
      base.map((type, amount) => MapEntry(type, amount * rewardMultiplier));
}
