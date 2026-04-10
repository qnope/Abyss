import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';

GameMap _buildMap({
  int width = 10,
  int height = 10,
  Map<GridPosition, CellContentType> contents = const {},
}) {
  final cells = List.generate(width * height, (i) {
    final x = i % width;
    final y = i ~/ width;
    final pos = GridPosition(x: x, y: y);
    return MapCell(
      terrain: TerrainType.plain,
      content: contents[pos] ?? CellContentType.empty,
    );
  });
  return GameMap(width: width, height: height, cells: cells, seed: 42);
}

Game _game({
  required GameMap gameMap,
  int explorerLevel = 0,
  required List<ExplorationOrder> pendingExplorations,
  Set<GridPosition> revealed = const {},
}) {
  final player = Player(
    name: 'Test',
    baseX: 5,
    baseY: 5,
    pendingExplorations: pendingExplorations,
    revealedCellsPerLevel: {1: revealed.toList()},
  );
  player.techBranches[TechBranch.explorer] = TechBranchState(
    branch: TechBranch.explorer,
    researchLevel: explorerLevel,
  );
  return Game.singlePlayer(player)..gameMap = gameMap;
}

void main() {
  group('multiple explorations', () {
    test('two orders resolved independently', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 2, y: 2)),
          ExplorationOrder(target: GridPosition(x: 7, y: 7)),
        ],
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.length, 2);
      expect(results[0].newCellsRevealed, 9);
      expect(results[1].newCellsRevealed, 9);
    });
  });

  group('idempotency', () {
    test('re-revealing already revealed cells yields zero new', () {
      // Pre-reveal the full 3x3 square centered on target (3,3).
      final revealed = {
        GridPosition(x: 2, y: 2),
        GridPosition(x: 3, y: 2),
        GridPosition(x: 4, y: 2),
        GridPosition(x: 2, y: 3),
        GridPosition(x: 3, y: 3),
        GridPosition(x: 4, y: 3),
        GridPosition(x: 2, y: 4),
        GridPosition(x: 3, y: 4),
        GridPosition(x: 4, y: 4),
      };
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 3, y: 3)),
        ],
        revealed: revealed,
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.first.newCellsRevealed, 0);
    });
  });

  group('notable content', () {
    test('finds notable content in reveal area', () {
      final contents = {
        GridPosition(x: 5, y: 4): CellContentType.ruins,
      };
      final map = _buildMap(contents: contents);
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 5, y: 5)),
        ],
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.first.notableContent, contains(CellContentType.ruins));
    });
  });
}
