import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/collect_treasure_result.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import 'collect_treasure_action_helper.dart';

void main() {
  group('CollectTreasureAction ranges', () {
    test('ruins min and max are reachable', () {
      final maxes = <ResourceType, int>{};
      final mins = <ResourceType, int>{};
      for (var seed = 0; seed < 200; seed++) {
        final scenario =
            createCollectScenario(content: CellContentType.ruins);
        final result = CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(scenario.game, scenario.player) as CollectTreasureResult;
        for (final entry in result.deltas.entries) {
          maxes[entry.key] =
              (maxes[entry.key] ?? entry.value) > entry.value
                  ? maxes[entry.key]!
                  : entry.value;
          mins[entry.key] =
              (mins[entry.key] ?? entry.value) < entry.value
                  ? mins[entry.key]!
                  : entry.value;
        }
      }
      expect(maxes[ResourceType.algae], 100);
      expect(maxes[ResourceType.coral], 25);
      expect(maxes[ResourceType.ore], 25);
      expect(maxes[ResourceType.pearl], 2);
      expect(mins[ResourceType.algae], 0);
      expect(mins[ResourceType.coral], 0);
      expect(mins[ResourceType.ore], 0);
      expect(mins[ResourceType.pearl], 0);
    });
  });
}
