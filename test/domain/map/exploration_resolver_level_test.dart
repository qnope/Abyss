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

GameMap _buildMap({int width = 10, int height = 10}) {
  final cells = List.generate(
    width * height,
    (_) => MapCell(terrain: TerrainType.plain),
  );
  return GameMap(
    width: width,
    height: height,
    cells: cells,
    playerBaseX: 5,
    playerBaseY: 5,
    seed: 42,
  );
}

Game _game({
  required GameMap gameMap,
  required int explorerLevel,
  required List<ExplorationOrder> pendingExplorations,
}) {
  return Game(
    player: Player(name: 'Test'),
    gameMap: gameMap,
    techBranches: {
      ...Game.defaultTechBranches(),
      TechBranch.explorer: TechBranchState(
        branch: TechBranch.explorer,
        researchLevel: explorerLevel,
      ),
    },
    pendingExplorations: pendingExplorations,
  );
}

void main() {
  group('explorer level impact', () {
    test('level 0 reveals 2x2 area (4 cells)', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 5, y: 5)),
        ],
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.first.newCellsRevealed, 4);
    });

    test('level 1 reveals 3x3 area (9 cells)', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        explorerLevel: 1,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 5, y: 5)),
        ],
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.first.newCellsRevealed, 9);
    });
  });
}
