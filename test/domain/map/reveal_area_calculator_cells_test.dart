import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';

GridPosition _pos(int x, int y) => GridPosition(x: x, y: y);

List<GridPosition> _reveal(int tx, int ty, int level, {int size = 20}) {
  return RevealAreaCalculator.cellsToReveal(
    targetX: tx,
    targetY: ty,
    explorerLevel: level,
    mapWidth: size,
    mapHeight: size,
  );
}

void _assertCentered(List<GridPosition> positions, GridPosition target) {
  final left = positions.where((p) => p.x < target.x).length;
  final right = positions.where((p) => p.x > target.x).length;
  final above = positions.where((p) => p.y < target.y).length;
  final below = positions.where((p) => p.y > target.y).length;
  expect(left, right, reason: 'left/right must match around target');
  expect(above, below, reason: 'above/below must match around target');
}

void main() {
  group('cellsToReveal - odd squares (target at center)', () {
    test('level 0 (3x3) at (5,5) reveals 9 cells, range (4,4)..(6,6)', () {
      final positions = _reveal(5, 5, 0);
      expect(positions.length, 9);
      for (var x = 4; x <= 6; x++) {
        for (var y = 4; y <= 6; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(5, 5)));
    });

    test('level 2 (5x5) at (10,10) reveals 25 cells, range (8,8)..(12,12)',
        () {
      final positions = _reveal(10, 10, 2);
      expect(positions.length, 25);
      for (var x = 8; x <= 12; x++) {
        for (var y = 8; y <= 12; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(10, 10)));
    });

    test('level 4 (7x7) at (10,10) reveals 49 cells, range (7,7)..(13,13)',
        () {
      final positions = _reveal(10, 10, 4);
      expect(positions.length, 49);
      for (var x = 7; x <= 13; x++) {
        for (var y = 7; y <= 13; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(10, 10)));
    });

    test('level 5 (9x9) at (10,10) reveals 81 cells, range (6,6)..(14,14)',
        () {
      final positions = _reveal(10, 10, 5);
      expect(positions.length, 81);
      for (var x = 6; x <= 14; x++) {
        for (var y = 6; y <= 14; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(10, 10)));
    });
  });

  group('cellsToReveal - strict centering', () {
    for (final level in const [0, 2, 4, 5]) {
      test('level $level is strictly centered on target', () {
        final target = _pos(10, 10);
        final positions = _reveal(target.x, target.y, level);
        _assertCentered(positions, target);
      });
    }
  });

  group('cellsToReveal - boundary handling', () {
    test('corner (0,0) level 0 reveals 4 cells', () {
      final positions = _reveal(0, 0, 0);
      expect(positions.length, 4);
      expect(
        positions,
        containsAll([_pos(0, 0), _pos(1, 0), _pos(0, 1), _pos(1, 1)]),
      );
    });

    test('right edge (19,10) level 1 reveals 6 cells', () {
      final positions = _reveal(19, 10, 1);
      expect(positions.length, 6);
      for (var x = 18; x <= 19; x++) {
        for (var y = 9; y <= 11; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(19, 10)));
    });

    test('far corner (19,19) level 0 reveals 4 cells', () {
      final positions = _reveal(19, 19, 0);
      expect(positions.length, 4);
      expect(
        positions,
        containsAll([_pos(18, 18), _pos(19, 18), _pos(18, 19), _pos(19, 19)]),
      );
    });
  });

  group('cellsToReveal - total cell count on open map', () {
    const center = 10;
    final expected = {0: 9, 1: 9, 2: 25, 3: 25, 4: 49, 5: 81};

    for (final entry in expected.entries) {
      test('level ${entry.key} reveals ${entry.value} cells', () {
        final positions = _reveal(center, center, entry.key);
        expect(positions.length, entry.value);
        expect(positions, contains(_pos(center, center)));
      });
    }
  });
}
