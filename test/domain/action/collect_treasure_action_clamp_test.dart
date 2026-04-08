import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/collect_treasure_result.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import 'collect_treasure_action_helper.dart';

void main() {
  group('CollectTreasureAction execute clamping', () {
    test('resourceBonus delta is clamped at maxStorage', () {
      final scenario =
          createCollectScenario(content: CellContentType.resourceBonus);
      scenario.player.resources[ResourceType.algae]!.amount = 4990;
      final result = CollectTreasureAction(targetX: 1, targetY: 1)
              .execute(scenario.game, scenario.player)
          as CollectTreasureResult;
      expect(result.deltas[ResourceType.algae], lessThanOrEqualTo(10));
      expect(result.deltas[ResourceType.algae], 5000 - 4990);
      expect(scenario.player.resources[ResourceType.algae]!.amount, 5000);
    });

    test('ruins delta is clamped at maxStorage when resource full', () {
      final scenario = createCollectScenario(content: CellContentType.ruins);
      for (final type in ResourceType.values) {
        scenario.player.resources[type]!.amount =
            scenario.player.resources[type]!.maxStorage;
      }
      final result = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      ).execute(scenario.game, scenario.player) as CollectTreasureResult;
      expect(result.deltas[ResourceType.algae], 0);
      expect(result.deltas[ResourceType.coral], 0);
      expect(result.deltas[ResourceType.ore], 0);
      expect(result.deltas[ResourceType.pearl], 0);
    });
  });
}
