import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

GameMap _buildMap() {
  final cells = List.generate(
    100,
    (_) => MapCell(terrain: TerrainType.plain),
  );
  return GameMap(width: 10, height: 10, cells: cells, seed: 42);
}

Player _player({
  int scoutsOnLevel = 5,
  required int level,
  List<GridPosition>? revealed,
}) {
  return Player(
    id: 'p1',
    name: 'Test',
    baseX: 5,
    baseY: 5,
    unitsPerLevel: {
      level: {
        for (final t in UnitType.values)
          t: Unit(
            type: t,
            count: t == UnitType.scout ? scoutsOnLevel : 0,
          ),
      },
    },
    revealedCellsPerLevel: {
      level: revealed ?? [GridPosition(x: 3, y: 3)],
    },
  );
}

void main() {
  group('ExploreAction level 1', () {
    test('succeeds with scouts on level 1', () {
      final player = _player(level: 1);
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap()};
      final action = ExploreAction(targetX: 3, targetY: 4);
      expect(action.validate(game, player).isSuccess, isTrue);
    });

    test('decrements scouts on level 1', () {
      final player = _player(level: 1);
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap()};
      final action = ExploreAction(targetX: 3, targetY: 4);
      action.execute(game, player);
      expect(player.unitsOnLevel(1)[UnitType.scout]!.count, 4);
    });

    test('fails without map for level', () {
      final player = _player(level: 1);
      final game = Game.singlePlayer(player)..levels = {};
      final action = ExploreAction(targetX: 3, targetY: 3);
      final result = action.validate(game, player);
      expect(result.isSuccess, isFalse);
    });

    test('fails without scouts', () {
      final player = _player(level: 1, scoutsOnLevel: 0);
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap()};
      final action = ExploreAction(targetX: 3, targetY: 4);
      final result = action.validate(game, player);
      expect(result.isSuccess, isFalse);
    });
  });

  group('ExploreAction level 2', () {
    test('succeeds with scouts on level 2', () {
      final player = _player(level: 2);
      final game = Game.singlePlayer(player)
        ..levels = {2: _buildMap()};
      final action = ExploreAction(
        targetX: 3, targetY: 4, level: 2,
      );
      expect(action.validate(game, player).isSuccess, isTrue);
    });

    test('decrements scouts on level 2', () {
      final player = _player(level: 2);
      final game = Game.singlePlayer(player)
        ..levels = {2: _buildMap()};
      final action = ExploreAction(
        targetX: 3, targetY: 4, level: 2,
      );
      action.execute(game, player);
      expect(player.unitsOnLevel(2)[UnitType.scout]!.count, 4);
    });

    test('adds exploration order with correct level', () {
      final player = _player(level: 2);
      final game = Game.singlePlayer(player)
        ..levels = {2: _buildMap()};
      final action = ExploreAction(
        targetX: 3, targetY: 4, level: 2,
      );
      action.execute(game, player);
      expect(player.pendingExplorations, hasLength(1));
      expect(player.pendingExplorations.first.level, 2);
    });

    test('fails when map missing for level 2', () {
      final player = _player(level: 2);
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap()};
      final action = ExploreAction(
        targetX: 3, targetY: 3, level: 2,
      );
      final result = action.validate(game, player);
      expect(result.isSuccess, isFalse);
    });

    test('fails without scouts on level 2', () {
      final player = _player(level: 2, scoutsOnLevel: 0);
      final game = Game.singlePlayer(player)
        ..levels = {2: _buildMap()};
      final action = ExploreAction(
        targetX: 3, targetY: 4, level: 2,
      );
      final result = action.validate(game, player);
      expect(result.isSuccess, isFalse);
    });
  });
}
