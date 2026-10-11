import 'cell_content_type.dart';
import 'map_cell.dart';

/// Lays the volcano on a 2x2 footprint. The top-left cell (the anchor) is
/// the `volcanicKernel` and carries all the state; the three others are
/// `volcanicKernelPart`s.
class VolcanicKernelPlacer {
  static const side = 2;

  /// The footprint cells for an anchor, anchor first.
  static List<(int, int)> footprint(int anchorX, int anchorY) => [
        for (var dy = 0; dy < side; dy++)
          for (var dx = 0; dx < side; dx++) (anchorX + dx, anchorY + dy),
      ];

  static void place({
    required List<MapCell> cells,
    required int width,
    required int height,
  }) {
    final anchorX = width ~/ 2;
    final anchorY = height ~/ 2;
    for (final (x, y) in footprint(anchorX, anchorY)) {
      final isAnchor = x == anchorX && y == anchorY;
      final index = y * width + x;
      cells[index] = cells[index].copyWith(
        content: isAnchor
            ? CellContentType.volcanicKernel
            : CellContentType.volcanicKernelPart,
        lair: null,
        transitionBase: null,
      );
    }
  }
}
