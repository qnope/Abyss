import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';

import 'collect_treasure_action_helper.dart';

void main() {
  group('CollectTreasureAction validate', () {
    test('fails when map is null', () {
      final game = Game(player: Player(name: 'Test'), gameMap: null);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non générée');
    });

    test('fails when cell is not revealed', () {
      final cells = <MapCell>[];
      for (var y = 0; y < 5; y++) {
        for (var x = 0; x < 5; x++) {
          cells.add(MapCell(
            terrain: TerrainType.plain,
            isRevealed: x != 1 || y != 1,
            content: (x == 1 && y == 1)
                ? CellContentType.resourceBonus
                : CellContentType.empty,
          ));
        }
      }
      final map = GameMap(
        width: 5,
        height: 5,
        cells: cells,
        playerBaseX: 2,
        playerBaseY: 2,
        seed: 42,
      );
      final game = Game(player: Player(name: 'Test'), gameMap: map);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Case non révélée');
    });

    test('fails when cell is already collected', () {
      final game = createCollectGame(
        content: CellContentType.resourceBonus,
        isCollected: true,
      );
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Déjà collecté');
    });

    test('fails when cell is empty', () {
      final game = createCollectGame(content: CellContentType.empty);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Rien à collecter');
    });

    test('fails when cell is monsterLair', () {
      final game = createCollectGame(content: CellContentType.monsterLair);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Rien à collecter');
    });

    test('succeeds for resourceBonus', () {
      final game = createCollectGame(content: CellContentType.resourceBonus);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isTrue);
    });

    test('succeeds for ruins', () {
      final game = createCollectGame(content: CellContentType.ruins);
      final action = CollectTreasureAction(targetX: 1, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isTrue);
    });
  });
}
