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
  final cells = List.generate(
    width * height,
    (_) => MapCell(terrain: TerrainType.plain),
  );
  return GameMap(width: width, height: height, cells: cells, seed: 42);
}

Player _player({
  required String id,
  List<ExplorationOrder>? pendingExplorations,
  Map<int, List<GridPosition>>? revealedCellsPerLevel,
}) {
  return Player(
    id: id,
    name: id,
    baseX: 5,
    baseY: 5,
    pendingExplorations: pendingExplorations,
    revealedCellsPerLevel: revealedCellsPerLevel,
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
      final game = Game.singlePlayer(player)..levels = {1: map};

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
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 3, y: 3)),
        ],
        revealedCellsPerLevel: {1: [GridPosition(x: 3, y: 3)]},
      );
      final game = Game.singlePlayer(player)..levels = {1: map};

      final results = ExplorationResolver.resolve(game);

      // Level 0 reveals a 3x3 area (9 cells), one of which is pre-seeded.
      expect(results.single.newCellsRevealed, 8);
    });

    test('boundary exploration near edge counts only in-bounds cells', () {
      final map = _buildMap();
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(target: GridPosition(x: 9, y: 0)),
        ],
      );
      final game = Game.singlePlayer(player)..levels = {1: map};

      final results = ExplorationResolver.resolve(game);

      // Target (9,0) level 0 (3x3) keeps only the in-bounds quadrant
      // (8,0),(9,0),(8,1),(9,1); x=10 and y=-1 are out of bounds.
      expect(results.single.newCellsRevealed, 4);
      expect(player.revealedCells, {
        GridPosition(x: 8, y: 0), GridPosition(x: 9, y: 0),
        GridPosition(x: 8, y: 1), GridPosition(x: 9, y: 1),
      });
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
      )..levels = {1: map};

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
      )..levels = {1: map};

      ExplorationResolver.resolve(game);

      expect(bob.revealedCells, isEmpty);
      expect(bob.pendingExplorations, isEmpty);
    });
  });

  group('level 2 exploration', () {
    test('reveals cells on level 2 map', () {
      final map2 = _buildMap();
      final target = GridPosition(x: 4, y: 4);
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(target: target, level: 2),
        ],
      );
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap(), 2: map2};

      final results = ExplorationResolver.resolve(game);

      final revealed2 = player.revealedCellsSetOnLevel(2);
      expect(revealed2.contains(target), isTrue);
      expect(results.single.newCellsRevealed, greaterThan(0));
      expect(player.pendingExplorations, isEmpty);
    });

    test('does not reveal cells on level 1 when exploring level 2', () {
      final target = GridPosition(x: 4, y: 4);
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(target: target, level: 2),
        ],
      );
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap(), 2: _buildMap()};

      ExplorationResolver.resolve(game);

      expect(player.revealedCellsSetOnLevel(1), isEmpty);
      expect(player.revealedCellsSetOnLevel(2), isNotEmpty);
    });

    test('skips order when target level map is missing', () {
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(
            target: GridPosition(x: 4, y: 4), level: 2,
          ),
        ],
      );
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap()};

      final results = ExplorationResolver.resolve(game);

      expect(results, isEmpty);
      expect(player.pendingExplorations, isEmpty);
    });

    test('mixed level explorations resolve independently', () {
      final player = _player(
        id: 'solo',
        pendingExplorations: [
          ExplorationOrder(
            target: GridPosition(x: 2, y: 2), level: 1,
          ),
          ExplorationOrder(
            target: GridPosition(x: 7, y: 7), level: 2,
          ),
        ],
      );
      final game = Game.singlePlayer(player)
        ..levels = {1: _buildMap(), 2: _buildMap()};

      final results = ExplorationResolver.resolve(game);

      expect(results, hasLength(2));
      expect(
        player.revealedCellsSetOnLevel(1)
            .contains(GridPosition(x: 2, y: 2)),
        isTrue,
      );
      expect(
        player.revealedCellsSetOnLevel(2)
            .contains(GridPosition(x: 7, y: 7)),
        isTrue,
      );
    });
  });
}
