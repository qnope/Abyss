import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_mask.dart';
import 'package:abyss/domain/map/grid_position.dart';

GridPosition _pos(int x, int y) => GridPosition(x: x, y: y);

void main() {
  group('CellMask', () {
    final CellMask mask = CellMask(4, 3, <GridPosition>[_pos(1, 1), _pos(3, 2)]);

    test('contains the marked cells only', () {
      expect(mask.width, 4);
      expect(mask.height, 3);
      expect(mask.contains(1, 1), isTrue);
      expect(mask.contains(3, 2), isTrue);
      expect(mask.contains(0, 0), isFalse);
      expect(mask.contains(2, 1), isFalse);
    });

    test('never contains a cell off the grid', () {
      expect(mask.contains(-1, 1), isFalse);
      expect(mask.contains(4, 1), isFalse);
      expect(mask.contains(1, -1), isFalse);
      expect(mask.contains(1, 3), isFalse);
    });

    test('touches covers a marked cell and its eight neighbours', () {
      expect(mask.touches(1, 1), isTrue);
      expect(mask.touches(0, 0), isTrue);
      expect(mask.touches(2, 2), isTrue);
      expect(mask.touches(3, 1), isTrue);
      expect(mask.touches(3, 0), isFalse);
    });

    test('touches looks past the edges without failing', () {
      expect(mask.touches(0, 2), isTrue);
      expect(mask.touches(3, 0), isFalse);
      expect(mask.touches(-1, -1), isFalse);
      expect(mask.touches(4, 3), isTrue);
    });

    test('ignores marks off the grid', () {
      final CellMask small = CellMask(2, 2, <GridPosition>[_pos(5, 5)]);
      expect(small.contains(1, 1), isFalse);
      expect(small.touches(1, 1), isFalse);
    });
  });
}
