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
  Set<GridPosition> revealed = const {},
  Map<GridPosition, CellContentType> contents = const {},
}) {
  final cells = List.generate(width * height, (i) {
    final x = i % width;
    final y = i ~/ width;
    final pos = GridPosition(x: x, y: y);
    return MapCell(
      terrain: TerrainType.plain,
      isRevealed: revealed.contains(pos),
      content: contents[pos] ?? CellContentType.empty,
    );
  });
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
  GameMap? gameMap,
  int explorerLevel = 0,
  List<ExplorationOrder>? pendingExplorations,
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
  group('single exploration', () {
    test('reveals cells correctly', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 3, y: 3)),
        ],
      );

      ExplorationResolver.resolve(game);

      // Level 0 => 2x2, target at bottom-left
      // Reveals (3,2), (4,2), (3,3), (4,3)
      expect(map.cellAt(3, 2).isRevealed, isTrue);
      expect(map.cellAt(4, 2).isRevealed, isTrue);
      expect(map.cellAt(3, 3).isRevealed, isTrue);
      expect(map.cellAt(4, 3).isRevealed, isTrue);
    });

    test('returns correct result', () {
      final map = _buildMap();
      final target = GridPosition(x: 3, y: 3);
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [ExplorationOrder(target: target)],
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.length, 1);
      expect(results.first.target, target);
      expect(results.first.newCellsRevealed, 4);
    });

    test('clears pending list', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 3, y: 3)),
        ],
      );

      ExplorationResolver.resolve(game);

      expect(game.pendingExplorations, isEmpty);
    });
  });

  group('boundary handling', () {
    test('exploration near map edge does not crash', () {
      final map = _buildMap(width: 10, height: 10);
      final game = _game(
        gameMap: map,
        explorerLevel: 0,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 9, y: 0)),
        ],
      );

      final results = ExplorationResolver.resolve(game);

      expect(results.length, 1);
      // (9,0) bottom-left of 2x2: (9,-1),(10,-1),(9,0),(10,0)
      // Only (9,0) is in bounds
      expect(results.first.newCellsRevealed, 1);
      expect(map.cellAt(9, 0).isRevealed, isTrue);
    });
  });
}
