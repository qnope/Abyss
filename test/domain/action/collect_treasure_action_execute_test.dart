import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/collect_treasure_result.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import 'collect_treasure_action_helper.dart';

void main() {
  group('CollectTreasureAction execute', () {
    test('resourceBonus adds algae, coral and ore', () {
      final scenario =
          createCollectScenario(content: CellContentType.resourceBonus);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      final result = action.execute(scenario.game, scenario.player)
          as CollectTreasureResult;
      expect(result.isSuccess, isTrue);
      // Random(42): nextInt(51)=7, nextInt(21)=15, nextInt(21)=12
      expect(result.deltas[ResourceType.algae], 50 + 7);
      expect(result.deltas[ResourceType.coral], 30 + 15);
      expect(result.deltas[ResourceType.ore], 30 + 12);
      expect(result.deltas.containsKey(ResourceType.pearl), isFalse);
    });

    test('ruins adds algae, coral, ore and pearl', () {
      final scenario = createCollectScenario(content: CellContentType.ruins);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      final result = action.execute(scenario.game, scenario.player)
          as CollectTreasureResult;
      expect(result.isSuccess, isTrue);
      // Random(42): nextInt(101)=5, nextInt(26)=8, nextInt(26)=6, nextInt(3)=1
      expect(result.deltas[ResourceType.algae], 5);
      expect(result.deltas[ResourceType.coral], 8);
      expect(result.deltas[ResourceType.ore], 6);
      expect(result.deltas[ResourceType.pearl], 1);
    });

    test('resourceBonus amounts stay within configured ranges', () {
      for (var seed = 0; seed < 50; seed++) {
        final scenario =
            createCollectScenario(content: CellContentType.resourceBonus);
        final result = CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(scenario.game, scenario.player) as CollectTreasureResult;
        expect(result.deltas[ResourceType.algae], inInclusiveRange(50, 100),
            reason: 'seed=$seed');
        expect(result.deltas[ResourceType.coral], inInclusiveRange(30, 50),
            reason: 'seed=$seed');
        expect(result.deltas[ResourceType.ore], inInclusiveRange(30, 50),
            reason: 'seed=$seed');
      }
    });

    test('ruins amounts stay within new ranges', () {
      for (var seed = 0; seed < 50; seed++) {
        final scenario = createCollectScenario(content: CellContentType.ruins);
        final result = CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(scenario.game, scenario.player) as CollectTreasureResult;
        expect(result.deltas[ResourceType.algae], inInclusiveRange(0, 100),
            reason: 'seed=$seed');
        expect(result.deltas[ResourceType.coral], inInclusiveRange(0, 25),
            reason: 'seed=$seed');
        expect(result.deltas[ResourceType.ore], inInclusiveRange(0, 25),
            reason: 'seed=$seed');
        expect(result.deltas[ResourceType.pearl], inInclusiveRange(0, 2),
            reason: 'seed=$seed');
      }
    });

    test('stamps collectedBy with calling player id on success', () {
      final scenario = createCollectScenario(content: CellContentType.ruins);
      CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      ).execute(scenario.game, scenario.player);
      expect(
        scenario.game.gameMap!.cellAt(1, 1).collectedBy,
        scenario.player.id,
      );
      expect(scenario.game.gameMap!.cellAt(1, 1).isCollected, isTrue);
    });

    test('collecting already-collected cell fails', () {
      final scenario =
          createCollectScenario(content: CellContentType.resourceBonus);
      CollectTreasureAction(targetX: 1, targetY: 1)
          .execute(scenario.game, scenario.player);
      final result = CollectTreasureAction(targetX: 1, targetY: 1)
          .execute(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Déjà collecté');
    });
  });
}
