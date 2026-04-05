import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';

GridPosition _pos(int x, int y) => GridPosition(x: x, y: y);

List<GridPosition> _reveal(int tx, int ty, int level,
    {int size = 20}) {
  return RevealAreaCalculator.cellsToReveal(
    targetX: tx,
    targetY: ty,
    explorerLevel: level,
    mapWidth: size,
    mapHeight: size,
  );
}

void main() {
  group('cellsToReveal - even squares (target at bottom-left)', () {
    test('level 0 (2x2) at (5,5) reveals 4 cells', () {
      final positions = _reveal(5, 5, 0);
      expect(positions.length, 4);
      expect(
        positions,
        containsAll([_pos(5, 4), _pos(6, 4), _pos(5, 5), _pos(6, 5)]),
      );
      expect(positions, contains(_pos(5, 5)));
    });

    test('level 2 (4x4) at (10,10) reveals 16 cells', () {
      final positions = _reveal(10, 10, 2);
      expect(positions.length, 16);
      for (var x = 10; x <= 13; x++) {
        for (var y = 7; y <= 10; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(10, 10)));
    });
  });

  group('cellsToReveal - odd squares (target at center)', () {
    test('level 1 (3x3) at (5,5) reveals 9 cells', () {
      final positions = _reveal(5, 5, 1);
      expect(positions.length, 9);
      for (var x = 4; x <= 6; x++) {
        for (var y = 4; y <= 6; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(5, 5)));
    });

    test('level 3 (5x5) at (10,10) reveals 25 cells', () {
      final positions = _reveal(10, 10, 3);
      expect(positions.length, 25);
      for (var x = 8; x <= 12; x++) {
        for (var y = 8; y <= 12; y++) {
          expect(positions, contains(_pos(x, y)));
        }
      }
      expect(positions, contains(_pos(10, 10)));
    });
  });

  group('cellsToReveal - boundary handling', () {
    test('corner (0,0) level 0 clamps to 2 cells', () {
      final positions = _reveal(0, 0, 0);
      expect(positions.length, 2);
      expect(positions, containsAll([_pos(0, 0), _pos(1, 0)]));
      expect(positions, contains(_pos(0, 0)));
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

    test('far corner (19,19) level 0 reveals 2 cells', () {
      final positions = _reveal(19, 19, 0);
      expect(positions.length, 2);
      expect(
        positions,
        containsAll([_pos(19, 18), _pos(19, 19)]),
      );
      expect(positions, contains(_pos(19, 19)));
    });
  });

  group('cellsToReveal - total cell count on open map', () {
    const center = 10;
    final expected = {0: 4, 1: 9, 2: 16, 3: 25, 4: 49, 5: 81};

    for (final entry in expected.entries) {
      test('level ${entry.key} reveals ${entry.value} cells', () {
        final positions = _reveal(center, center, entry.key);
        expect(positions.length, entry.value);
        expect(positions, contains(_pos(center, center)));
      });
    }
  });
}
