import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/tech/tech_option.dart';

GameMap _buildMap({int width = 10, int height = 10}) {
  final cells = List.generate(
    width * height,
    (_) => MapCell(terrain: TerrainType.plain),
  );
  return GameMap(width: width, height: height, cells: cells, seed: 42);
}

Game _game({
  required GameMap gameMap,
  required int explorerLevel,
  List<TechOption> options = const [],
  bool unlocked = true,
}) {
  final player = Player(
    name: 'Test',
    baseX: 5,
    baseY: 5,
    pendingExplorations: [
      ExplorationOrder(
          target: GridPosition(x: gameMap.width ~/ 2, y: gameMap.height ~/ 2)),
    ],
  );
  player.techBranches[TechBranch.explorer] = TechBranchState(
    branch: TechBranch.explorer,
    unlocked: unlocked,
    researchLevel: explorerLevel,
    choices: [for (final o in options) o.index],
  );
  return Game.singlePlayer(player)..levels = {1: gameMap};
}

int _revealed(Game game) =>
    ExplorationResolver.resolve(game).first.newCellsRevealed;

void main() {
  group('explorer level impact', () {
    test('level 0 reveals 3x3 area (9 cells)', () {
      final game = _game(gameMap: _buildMap(), explorerLevel: 0);
      expect(_revealed(game), 9);
    });

    test('level 1 (first tier) reveals 5x5 area (25 cells)', () {
      final game = _game(gameMap: _buildMap(), explorerLevel: 1);
      expect(_revealed(game), 25);
    });

    test('level 4 without Sonar reveals 7x7 area (49 cells)', () {
      final game = _game(
        gameMap: _buildMap(width: 20, height: 20),
        explorerLevel: 4,
        options: [TechOption.b, TechOption.a],
      );
      expect(_revealed(game), 49);
    });

    test('level 4 with Sonar profond reveals 9x9 area (81 cells)', () {
      final game = _game(
        gameMap: _buildMap(width: 20, height: 20),
        explorerLevel: 4,
        options: [TechOption.a, TechOption.b],
      );
      expect(_revealed(game), 81);
    });

    test('a locked branch reveals 3x3 whatever its level', () {
      final game =
          _game(gameMap: _buildMap(), explorerLevel: 5, unlocked: false);
      expect(_revealed(game), 9);
    });
  });
}
