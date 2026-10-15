import 'dart:ui';

import 'map_content_drawer.dart';

/// The cell under [point], in map coordinates, of a map [width] by
/// [height] cells, or `null` outside the map.
(int, int)? mapCellAt(Offset point, {required int width, required int height}) {
  final x = point.dx ~/ cellSize, y = point.dy ~/ cellSize;
  if (point.dx < 0 || point.dy < 0 || x >= width || y >= height) return null;
  return (x, y);
}
