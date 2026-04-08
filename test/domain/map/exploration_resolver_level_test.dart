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
  return GameMap(width: width, height: height, cells: cells, seed: 42);
}

Game _game({
  required GameMap gameMap,
  required int explorerLevel,
  required List<ExplorationOrder> pendingExplorations,
}) {
  final player = Player(
    name: 'Test',
    baseX: 5,
    baseY: 5,
    pendingExplorations: pendingExplorations,
  );
  player.techBranches[TechBranch.explorer] = TechBranchState(
    branch: TechBranch.explorer,
    researchLevel: explorerLevel,
  );
  return Game.singlePlayer(player)..gameMap = gameMap;
}

void main() {
  group('explorer level impact', () {
    test('level 0 reveals 3x3 area (9 cells)', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 5, y: 5)),
        ],
      );

      final results = ExplorationResolver.resolve(game);

      // Level 0 now resolves to a 3x3 square centered on the target.
      expect(results.first.newCellsRevealed, 9);
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

      // Level 1 still resolves to a 3x3 square in the new progression table.
      expect(results.first.newCellsRevealed, 9);
    });

    test('level 4 reveals 7x7 area (49 cells)', () {
      final map = _buildMap(width: 20, height: 20);
      final game = _game(
        gameMap: map,
        explorerLevel: 4,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 10, y: 10)),
        ],
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.first.newCellsRevealed, 49);
    });
  });
}
