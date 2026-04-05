import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_eligibility_checker.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';

/// Builds a 7x7 map with base at (3,3).
/// Cells within Chebyshev distance 1 from (3,3) are revealed (3x3 area).
GameMap _makeTestMap() {
  final cells = List.generate(49, (_) {
    return MapCell(terrain: TerrainType.plain);
  });
  final map = GameMap(
    width: 7,
    height: 7,
    cells: cells,
    playerBaseX: 3,
    playerBaseY: 3,
    seed: 0,
  );
  for (var dy = -1; dy <= 1; dy++) {
    for (var dx = -1; dx <= 1; dx++) {
      final x = 3 + dx;
      final y = 3 + dy;
      map.setCell(
        x,
        y,
        MapCell(terrain: TerrainType.plain, isRevealed: true),
      );
    }
  }
  return map;
}

void main() {
  group('revealed cells', () {
    test('revealed cell is eligible', () {
      final map = _makeTestMap();
      expect(CellEligibilityChecker.isEligible(map, 2, 2), isTrue);
    });

    test('revealed cell at map edge is eligible', () {
      final map = _makeTestMap();
      map.setCell(
        0,
        3,
        MapCell(terrain: TerrainType.plain, isRevealed: true),
      );
      expect(CellEligibilityChecker.isEligible(map, 0, 3), isTrue);
    });
  });

  group('base cell', () {
    test('base cell is not eligible', () {
      final map = _makeTestMap();
      expect(CellEligibilityChecker.isEligible(map, 3, 3), isFalse);
    });
  });

  group('unrevealed cells adjacent to revealed', () {
    test('unrevealed cell adjacent to revealed is eligible', () {
      final map = _makeTestMap();
      // (1,2) is unrevealed, neighbor (2,2) is revealed
      expect(map.cellAt(1, 2).isRevealed, isFalse);
      expect(map.cellAt(2, 2).isRevealed, isTrue);
      expect(CellEligibilityChecker.isEligible(map, 1, 2), isTrue);
    });

    test('unrevealed cell diagonally adjacent is eligible', () {
      final map = _makeTestMap();
      // (1,1) is unrevealed, diagonal neighbor (2,2) is revealed
      expect(map.cellAt(1, 1).isRevealed, isFalse);
      expect(map.cellAt(2, 2).isRevealed, isTrue);
      expect(CellEligibilityChecker.isEligible(map, 1, 1), isTrue);
    });
  });

  group('unrevealed cells not adjacent to revealed', () {
    test('unrevealed cell far from revealed is not eligible', () {
      final map = _makeTestMap();
      // (0,0) has neighbors (1,0), (0,1), (1,1) — none revealed
      expect(map.cellAt(0, 0).isRevealed, isFalse);
      expect(CellEligibilityChecker.isEligible(map, 0, 0), isFalse);
    });
  });

  group('boundary conditions', () {
    test('corner cell (0,0) does not crash', () {
      final map = _makeTestMap();
      expect(
        () => CellEligibilityChecker.isEligible(map, 0, 0),
        returnsNormally,
      );
    });

    test('edge cell (0,3) does not crash', () {
      final map = _makeTestMap();
      expect(
        () => CellEligibilityChecker.isEligible(map, 0, 3),
        returnsNormally,
      );
    });
  });
}
