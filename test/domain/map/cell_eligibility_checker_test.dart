import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_eligibility_checker.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';

/// Builds a 7x7 map with base at (3,3).
/// Cells within Chebyshev distance 1 from (3,3) are revealed (3x3 area).
({GameMap map, Player player}) _makeTestMap() {
  final cells = List.generate(49, (_) {
    return MapCell(terrain: TerrainType.plain);
  });
  final map = GameMap(width: 7, height: 7, cells: cells, seed: 0);
  final revealed = <GridPosition>[];
  for (var dy = -1; dy <= 1; dy++) {
    for (var dx = -1; dx <= 1; dx++) {
      revealed.add(GridPosition(x: 3 + dx, y: 3 + dy));
    }
  }
  final player = Player(
    name: 'Test',
    baseX: 3,
    baseY: 3,
    revealedCellsPerLevel: {1: revealed},
  );
  return (map: map, player: player);
}

void main() {
  group('revealed cells', () {
    test('revealed cell is eligible', () {
      final t = _makeTestMap();
      expect(
        CellEligibilityChecker.isEligible(t.map, t.player, 2, 2),
        isTrue,
      );
    });

    test('revealed cell at map edge is eligible', () {
      final t = _makeTestMap();
      t.player.addRevealedCell(1, GridPosition(x: 0, y: 3));
      expect(
        CellEligibilityChecker.isEligible(t.map, t.player, 0, 3),
        isTrue,
      );
    });
  });

  group('base cell', () {
    test('base cell is not eligible', () {
      final t = _makeTestMap();
      expect(
        CellEligibilityChecker.isEligible(t.map, t.player, 3, 3),
        isFalse,
      );
    });
  });

  group('unrevealed cells adjacent to revealed', () {
    test('unrevealed cell adjacent to revealed is eligible', () {
      final t = _makeTestMap();
      expect(
        t.player.revealedCells.contains(GridPosition(x: 1, y: 2)),
        isFalse,
      );
      expect(
        t.player.revealedCells.contains(GridPosition(x: 2, y: 2)),
        isTrue,
      );
      expect(
        CellEligibilityChecker.isEligible(t.map, t.player, 1, 2),
        isTrue,
      );
    });

    test('unrevealed cell diagonally adjacent is eligible', () {
      final t = _makeTestMap();
      expect(
        t.player.revealedCells.contains(GridPosition(x: 1, y: 1)),
        isFalse,
      );
      expect(
        t.player.revealedCells.contains(GridPosition(x: 2, y: 2)),
        isTrue,
      );
      expect(
        CellEligibilityChecker.isEligible(t.map, t.player, 1, 1),
        isTrue,
      );
    });
  });

  group('unrevealed cells not adjacent to revealed', () {
    test('unrevealed cell far from revealed is not eligible', () {
      final t = _makeTestMap();
      expect(
        t.player.revealedCells.contains(GridPosition(x: 0, y: 0)),
        isFalse,
      );
      expect(
        CellEligibilityChecker.isEligible(t.map, t.player, 0, 0),
        isFalse,
      );
    });
  });

  group('boundary conditions', () {
    test('corner cell (0,0) does not crash', () {
      final t = _makeTestMap();
      expect(
        () => CellEligibilityChecker.isEligible(t.map, t.player, 0, 0),
        returnsNormally,
      );
    });

    test('edge cell (0,3) does not crash', () {
      final t = _makeTestMap();
      expect(
        () => CellEligibilityChecker.isEligible(t.map, t.player, 0, 3),
        returnsNormally,
      );
    });
  });
}
