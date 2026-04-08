import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';

GameMap _buildMap({int width = 10, int height = 10}) {
  final cells = List.generate(
    width * height,
    (_) => MapCell(terrain: TerrainType.plain),
  );
  return GameMap(width: width, height: height, cells: cells, seed: 42);
}

Game _game({
  GameMap? gameMap,
  int explorerLevel = 0,
  List<ExplorationOrder>? pendingExplorations,
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
  late TurnResolver resolver;
  setUp(() => resolver = TurnResolver());

  group('TurnResolver exploration integration', () {
    test('explorations included in TurnResult', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 5, y: 5)),
        ],
      );

      final result = resolver.resolve(game);

      expect(result.explorations.length, 1);
      // Level 0 reveals a 3x3 square (9 cells) centered on the target.
      expect(result.explorations.first.newCellsRevealed, 9);
    });

    test('pending explorations cleared after turn', () {
      final map = _buildMap();
      final game = _game(
        gameMap: map,
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 5, y: 5)),
        ],
      );

      resolver.resolve(game);

      expect(game.humanPlayer.pendingExplorations, isEmpty);
    });

    test('no explorations when list is empty', () {
      final game = _game(gameMap: _buildMap());

      final result = resolver.resolve(game);

      expect(result.explorations, isEmpty);
    });

    test('no explorations when map is null', () {
      final game = _game(
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 5, y: 5)),
        ],
      );

      final result = resolver.resolve(game);

      expect(result.explorations, isEmpty);
    });
  });
}
