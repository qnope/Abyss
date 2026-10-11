import '../game/game.dart';
import 'cell_content_type.dart';
import 'game_map.dart';
import 'grid_position.dart';
import 'volcanic_kernel_placer.dart';

/// Reads and repairs the 2x2 volcano: the anchor (top-left, the
/// `volcanicKernel`) carries the state, the other cells are parts.
abstract final class VolcanoFootprint {
  /// The anchor of the volcano covering ([x], [y]), or null if that cell
  /// is not part of a volcano.
  static GridPosition? anchorOf(GameMap map, int x, int y) {
    final content = map.cellAt(x, y).content;
    if (content == CellContentType.volcanicKernel) {
      return GridPosition(x: x, y: y);
    }
    if (content != CellContentType.volcanicKernelPart) return null;
    for (var dy = 0; dy < VolcanicKernelPlacer.side; dy++) {
      for (var dx = 0; dx < VolcanicKernelPlacer.side; dx++) {
        final ax = x - dx, ay = y - dy;
        if (ax < 0 || ay < 0) continue;
        if (map.cellAt(ax, ay).content == CellContentType.volcanicKernel) {
          return GridPosition(x: ax, y: ay);
        }
      }
    }
    return null;
  }

  /// Gives a volcano saved as a single cell its three parts.
  static void completeLegacy(GameMap map) {
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        if (map.cellAt(x, y).content != CellContentType.volcanicKernel) {
          continue;
        }
        for (final (px, py) in VolcanicKernelPlacer.footprint(x, y).skip(1)) {
          if (px >= map.width || py >= map.height) continue;
          map.setCell(
            px,
            py,
            map.cellAt(px, py).copyWith(
                  content: CellContentType.volcanicKernelPart,
                  lair: null,
                  transitionBase: null,
                ),
          );
        }
      }
    }
  }

  /// Applies [completeLegacy] to every level of [game]; run on load.
  static void migrate(Game game) => game.levels.values.forEach(completeLegacy);
}
