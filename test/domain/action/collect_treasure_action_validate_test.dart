import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';

import 'collect_treasure_action_helper.dart';

void main() {
  group('CollectTreasureAction validate', () {
    test('fails when map is null', () {
      final player = buildCollectTestPlayer();
      final game = Game(
        humanPlayerId: player.id,
        players: {player.id: player},
        gameMap: null,
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game, player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non générée');
    });

    test('fails when cell is not revealed', () {
      final scenario = createCollectScenario();
      // Build a fresh player without pre-revealed cells.
      final player = Player(id: 'test', name: 'Test', baseX: 2, baseY: 2);
      final game = Game(
        humanPlayerId: player.id,
        players: {player.id: player},
        gameMap: scenario.game.gameMap,
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game, player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Case non révélée');
    });

    test('fails when cell is already collected by someone else', () {
      final scenario = createCollectScenario(
        content: CellContentType.resourceBonus,
        collectedBy: 'other-player',
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Déjà collecté');
    });

    test('fails when cell is already collected by caller (double collect)',
        () {
      final scenario = createCollectScenario(
        content: CellContentType.resourceBonus,
        collectedBy: 'test-uuid',
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Déjà collecté');
    });

    test('fails when cell is empty', () {
      final scenario = createCollectScenario(content: CellContentType.empty);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Rien à collecter');
    });

    test('fails when cell is monsterLair', () {
      final scenario =
          createCollectScenario(content: CellContentType.monsterLair);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Rien à collecter');
    });

    test('succeeds for resourceBonus', () {
      final scenario =
          createCollectScenario(content: CellContentType.resourceBonus);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
    });

    test('succeeds for ruins', () {
      final scenario = createCollectScenario(content: CellContentType.ruins);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
    });
  });
}
