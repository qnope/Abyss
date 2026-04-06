import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import 'collect_treasure_action_helper.dart';

void main() {
  group('CollectTreasureAction execute', () {
    test('adds bonus resources to player stock', () {
      final game = createCollectGame(
        content: CellContentType.resourceBonus,
        bonusResourceType: ResourceType.coral,
        bonusAmount: 30,
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      expect(game.resources[ResourceType.coral]!.amount, 110);
    });

    test('caps resources at maxStorage', () {
      final game = createCollectGame(
        content: CellContentType.resourceBonus,
        bonusResourceType: ResourceType.coral,
        bonusAmount: 30,
      );
      game.resources[ResourceType.coral]!.amount = 4990;
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      action.execute(game);
      expect(game.resources[ResourceType.coral]!.amount, 5000);
    });

    test('marks cell as collected after resourceBonus', () {
      final game = createCollectGame(
        content: CellContentType.resourceBonus,
        bonusResourceType: ResourceType.coral,
        bonusAmount: 30,
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      action.execute(game);
      final cell = game.gameMap!.cellAt(1, 1);
      expect(cell.isCollected, isTrue);
    });

    test('ruins adds random resources and pearls', () {
      final game = createCollectGame(content: CellContentType.ruins);
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(42),
      );
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      // Random(42): nextInt(4)=3 → energy, 20+nextInt(61)=65, 1+nextInt(5)=5
      expect(game.resources[ResourceType.energy]!.amount, 125);
      expect(game.resources[ResourceType.pearl]!.amount, 10);
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
      final game = createCollectGame(
        content: CellContentType.resourceBonus,
        bonusResourceType: ResourceType.coral,
        bonusAmount: 30,
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      action.execute(game);
      final second = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = second.execute(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Déjà collecté');
    });
  });
}
