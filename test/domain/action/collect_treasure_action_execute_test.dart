import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
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
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      // Random(42): nextInt(51)=7, nextInt(21)=15, nextInt(21)=12
      expect(game.resources[ResourceType.algae]!.amount, 100 + 57);
      expect(game.resources[ResourceType.coral]!.amount, 80 + 45);
      expect(game.resources[ResourceType.ore]!.amount, 50 + 42);
    });

    test('resourceBonus does not give pearls', () {
      final game = createCollectGame(content: CellContentType.resourceBonus);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      action.execute(game);
      expect(game.resources[ResourceType.pearl]!.amount, 5);
    });

    test('resourceBonus amounts stay within configured ranges', () {
      for (var seed = 0; seed < 50; seed++) {
        final game = createCollectGame(content: CellContentType.resourceBonus);
        final before = {
          ResourceType.algae: game.resources[ResourceType.algae]!.amount,
          ResourceType.coral: game.resources[ResourceType.coral]!.amount,
          ResourceType.ore: game.resources[ResourceType.ore]!.amount,
        };
        CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(game);
        final algaeGain =
            game.resources[ResourceType.algae]!.amount - before[ResourceType.algae]!;
        final coralGain =
            game.resources[ResourceType.coral]!.amount - before[ResourceType.coral]!;
        final oreGain =
            game.resources[ResourceType.ore]!.amount - before[ResourceType.ore]!;
        expect(algaeGain, inInclusiveRange(50, 100), reason: 'seed=$seed');
        expect(coralGain, inInclusiveRange(30, 50), reason: 'seed=$seed');
        expect(oreGain, inInclusiveRange(30, 50), reason: 'seed=$seed');
      }
    });

    test('resourceBonus caps resources at maxStorage', () {
      final game = createCollectGame(content: CellContentType.resourceBonus);
      game.resources[ResourceType.algae]!.amount = 4990;
      game.resources[ResourceType.coral]!.amount = 4990;
      game.resources[ResourceType.ore]!.amount = 4990;
      CollectTreasureAction(targetX: 1, targetY: 1).execute(game);
      expect(game.resources[ResourceType.algae]!.amount, 5000);
      expect(game.resources[ResourceType.coral]!.amount, 5000);
      expect(game.resources[ResourceType.ore]!.amount, 5000);
    });

    test('marks cell as collected after resourceBonus', () {
      final game = createCollectGame(content: CellContentType.resourceBonus);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      action.execute(game);
      final cell = game.gameMap!.cellAt(1, 1);
      expect(cell.isCollected, isTrue);
    });

    test('ruins adds coral, ore and pearl', () {
      final game = createCollectGame(content: CellContentType.ruins);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      // Random(42): nextInt(3)=1, nextInt(3)=0, nextInt(3)=0
      expect(game.resources[ResourceType.coral]!.amount, 81);
      expect(game.resources[ResourceType.ore]!.amount, 50);
      expect(game.resources[ResourceType.pearl]!.amount, 5);
    });

    test('ruins amounts stay between 0 and 2', () {
      for (var seed = 0; seed < 50; seed++) {
        final game = createCollectGame(content: CellContentType.ruins);
        final beforeCoral = game.resources[ResourceType.coral]!.amount;
        final beforeOre = game.resources[ResourceType.ore]!.amount;
        final beforePearl = game.resources[ResourceType.pearl]!.amount;
        CollectTreasureAction(
          targetX: 1,
          targetY: 1,
          random: Random(seed),
        ).execute(game);
        final coralGain =
            game.resources[ResourceType.coral]!.amount - beforeCoral;
        final oreGain = game.resources[ResourceType.ore]!.amount - beforeOre;
        final pearlGain =
            game.resources[ResourceType.pearl]!.amount - beforePearl;
        expect(coralGain, inInclusiveRange(0, 2), reason: 'seed=$seed');
        expect(oreGain, inInclusiveRange(0, 2), reason: 'seed=$seed');
        expect(pearlGain, inInclusiveRange(0, 2), reason: 'seed=$seed');
      }
    });

    test('marks cell as collected after ruins', () {
      final game = createCollectGame(content: CellContentType.ruins);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      action.execute(game);
      final cell = game.gameMap!.cellAt(1, 1);
      expect(cell.isCollected, isTrue);
    });

    test('collecting already-collected cell fails', () {
      final game = createCollectGame(content: CellContentType.resourceBonus);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      action.execute(game);
      final second = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = second.execute(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Déjà collecté');
    });
  });
}
