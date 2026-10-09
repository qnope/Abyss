import 'grid_position.dart';

/// Flat boolean grid over a [width] x [height] map: which cells are marked.
///
/// Built once from a set of positions so that, on a hot path, membership
/// and neighbourhood tests cost an index computation and allocate nothing.
class CellMask {
  final int width;
  final int height;
  final List<bool> _cells;

  /// Marks every position of [marked] that lies on the grid.
  CellMask(this.width, this.height, Iterable<GridPosition> marked)
      : _cells = List<bool>.filled(width * height, false) {
    for (final GridPosition p in marked) {
      if (_onGrid(p.x, p.y)) _cells[p.y * width + p.x] = true;
    }
  }

  /// Whether ([x], [y]) is marked; a cell off the grid never is.
  bool contains(int x, int y) => _onGrid(x, y) && _cells[y * width + x];

  /// Whether ([x], [y]) or one of its eight neighbours is marked.
  bool touches(int x, int y) {
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (contains(x + dx, y + dy)) return true;
      }
    }
    return false;
  }

  bool _onGrid(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;
}
