import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';
import 'package:abyss/domain/map/terrain_type.dart';

GameMap _buildMap({int width = 10, int height = 10}) {
  final cells = List.generate(width * height, (_) {
    return MapCell(terrain: TerrainType.plain);
  });
  return GameMap(width: width, height: height, cells: cells, seed: 42);
}

Player _player({
  required String id,
  List<ExplorationOrder>? pendingExplorations,
  List<GridPosition>? revealedCellsList,
}) {
  return Player(
    id: id,
    name: id,
    baseX: 5,
    baseY: 5,
    pendingExplorations: pendingExplorations,
    revealedCellsList: revealedCellsList,
  );
}

void main() {
  group('single player exploration', () {
    test('reveals expected cells on the player', () {
      final map = _buildMap();
      final target = GridPosition(x: 3, y: 3);
      final player = _player(
        id: 'solo',
        pendingExplorations: [ExplorationOrder(target: target)],
      );
      final game = Game.singlePlayer(player)..gameMap = map;

      final results = ExplorationResolver.resolve(game);

      final expected = RevealAreaCalculator.cellsToReveal(
        targetX: 3,
        targetY: 3,
        explorerLevel: 0,
        mapWidth: map.width,
        mapHeight: map.height,
      ).toSet();
      expect(player.revealedCells.containsAll(expected), isTrue);
      expect(player.pendingExplorations, isEmpty);
      expect(results.single.target, target);
      expect(results.single.newCellsRevealed, expected.length);
    });

    test('already revealed cells are not recounted', () {
      final map = _buildMap();
      final alreadyRevealed = GridPosition(x: 3, y: 3);
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 3, y: 3)),
        ],
        revealedCellsList: [alreadyRevealed],
      );
      final game = Game.singlePlayer(player)..gameMap = map;

      final results = ExplorationResolver.resolve(game);

      // Level 0 reveals a 2x2 area, one of which is pre-seeded.
      expect(results.single.newCellsRevealed, 3);
    });

    test('boundary exploration near edge counts only in-bounds cells', () {
      final map = _buildMap();
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 9, y: 0)),
        ],
      );
      final game = Game.singlePlayer(player)..gameMap = map;

      final results = ExplorationResolver.resolve(game);

      expect(results.single.newCellsRevealed, 1);
      expect(player.revealedCells.contains(GridPosition(x: 9, y: 0)), isTrue);
    });
  });

  group('multi-player exploration', () {
    test('players only reveal their own cells', () {
      final map = _buildMap();
      final alice = _player(
        id: 'alice',
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 2, y: 2)),
        ],
      );
      final bob = _player(
        id: 'bob',
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 7, y: 7)),
        ],
      );
      final game = Game(
        humanPlayerId: alice.id,
        players: {alice.id: alice, bob.id: bob},
      )..gameMap = map;

      ExplorationResolver.resolve(game);

      expect(alice.revealedCells.contains(GridPosition(x: 2, y: 2)), isTrue);
      expect(alice.revealedCells.contains(GridPosition(x: 7, y: 7)), isFalse);
      expect(bob.revealedCells.contains(GridPosition(x: 7, y: 7)), isTrue);
      expect(bob.revealedCells.contains(GridPosition(x: 2, y: 2)), isFalse);
      expect(alice.pendingExplorations, isEmpty);
      expect(bob.pendingExplorations, isEmpty);
    });

    test('player without pending orders is untouched', () {
      final map = _buildMap();
      final alice = _player(
        id: 'alice',
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 2, y: 2)),
        ],
      );
      final bob = _player(id: 'bob');
      final game = Game(
        humanPlayerId: alice.id,
        players: {alice.id: alice, bob.id: bob},
      )..gameMap = map;

      ExplorationResolver.resolve(game);

      expect(bob.revealedCells, isEmpty);
      expect(bob.pendingExplorations, isEmpty);
    });
  });
}
