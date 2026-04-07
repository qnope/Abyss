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
      final game = createCollectGame(content: CellContentType.resourceBonus);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      final result = action.execute(game) as CollectTreasureResult;
      expect(result.isSuccess, isTrue);
      // Random(42): nextInt(51)=7, nextInt(21)=15, nextInt(21)=12
      expect(result.deltas[ResourceType.algae], 50 + 7);
      expect(result.deltas[ResourceType.coral], 30 + 15);
      expect(result.deltas[ResourceType.ore], 30 + 12);
      expect(result.deltas.containsKey(ResourceType.pearl), isFalse);
    });

    test('ruins adds algae, coral, ore and pearl', () {
      final game = createCollectGame(content: CellContentType.ruins);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      final result = action.execute(game) as CollectTreasureResult;
      expect(result.isSuccess, isTrue);
      // Random(42): nextInt(101)=5, nextInt(26)=8, nextInt(26)=6, nextInt(3)=1
      expect(result.deltas[ResourceType.algae], 5);
      expect(result.deltas[ResourceType.coral], 8);
      expect(result.deltas[ResourceType.ore], 6);
      expect(result.deltas[ResourceType.pearl], 1);
    });

    test('resourceBonus amounts stay within configured ranges', () {
      for (var seed = 0; seed < 50; seed++) {
        final game = createCollectGame(content: CellContentType.resourceBonus);
        final result = CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(game) as CollectTreasureResult;
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
        final game = createCollectGame(content: CellContentType.ruins);
        final result = CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(game) as CollectTreasureResult;
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

    test('ruins min and max are reachable', () {
      final maxes = <ResourceType, int>{};
      final mins = <ResourceType, int>{};
      for (var seed = 0; seed < 200; seed++) {
        final game = createCollectGame(content: CellContentType.ruins);
        final result = CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(game) as CollectTreasureResult;
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

    test('marks cell as collected after execute', () {
      final game = createCollectGame(content: CellContentType.ruins);
      CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      ).execute(game);
      expect(game.gameMap!.cellAt(1, 1).isCollected, isTrue);
    });

    test('collecting already-collected cell fails', () {
      final game = createCollectGame(content: CellContentType.resourceBonus);
      CollectTreasureAction(targetX: 1, targetY: 1).execute(game);
      final result =
          CollectTreasureAction(targetX: 1, targetY: 1).execute(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Déjà collecté');
    });
  });
}
