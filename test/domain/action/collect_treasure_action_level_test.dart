import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/collect_treasure_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import 'collect_treasure_action_helper.dart';

Game _deepGame(int level) {
  final player = buildCollectTestPlayer();
  player.revealedCellsPerLevel[level] = [GridPosition(x: 1, y: 1)];
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {
      1: buildCollectTestMap(content: CellContentType.empty),
      level: buildCollectTestMap(content: CellContentType.ruins),
    },
  );
}

void main() {
  group('CollectTreasureAction on deeper levels', () {
    for (final level in [2, 3]) {
      test('collects ruins on level $level', () {
        final game = _deepGame(level);
        final action = CollectTreasureAction(
          targetX: 1, targetY: 1, level: level, random: Random(1),
        );
        final result = action.execute(game, game.humanPlayer)
            as CollectTreasureResult;
        expect(result.isSuccess, isTrue);
        expect(game.levels[level]!.cellAt(1, 1).collectedBy,
            game.humanPlayer.id);
        expect(game.levels[1]!.cellAt(1, 1).collectedBy, isNull);
      });

      test('ruin pearls on level $level stay within 0..${level + 1} '
          'times the multiplier', () {
        const m = CollectTreasureAction.rewardMultiplier;
        final seen = <int>{};
        for (var seed = 0; seed < 200; seed++) {
          final game = _deepGame(level);
          final result = CollectTreasureAction(
            targetX: 1, targetY: 1, level: level, random: Random(seed),
          ).execute(game, game.humanPlayer) as CollectTreasureResult;
          seen.add(result.deltas[ResourceType.pearl]!);
        }
        expect(seen, {for (var i = 0; i <= level + 1; i++) i * m});
      });
    }

    test('fails when the cell is not revealed on that level', () {
      final game = _deepGame(2);
      game.humanPlayer.revealedCellsPerLevel[2] = [];
      final result = CollectTreasureAction(
        targetX: 1, targetY: 1, level: 2,
      ).validate(game, game.humanPlayer);
      expect(result.isSuccess, isFalse);
    });
  });
}
