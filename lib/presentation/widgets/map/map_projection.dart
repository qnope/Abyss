import 'dart:typed_data';
import 'dart:ui';

import 'map_cell_at.dart';
import 'map_cell_size.dart';

/// Projects the flat map (cells of [cellSize]) onto a 2:1 isometric
/// screen and back: screen = (x − y, (x + y) / 2).
///
/// The game keeps reasoning on the flat map; only drawing and touch go
/// through here. The top vertex of cell (0, 0) is the projection's
/// origin, so the left part of the map has negative x: [originOf] says
/// where that origin lands in the map's positive box.
abstract final class MapProjection {
  /// Width of the diamond of a cell, in logical pixels.
  static const tileWidth = 2 * cellSize;

  /// Height of the diamond of a cell, in logical pixels.
  static const tileHeight = cellSize;

  /// Side of a standing content sprite, as a share of [tileWidth].
  static const standingWidthRatio = 0.9;

  /// How far below the centre of its cell a standing content sprite
  /// reaches, as a share of [tileHeight], so it looks planted.
  static const standingDropRatio = 0.22;

  /// Space above the top vertex reached by the first row's standing
  /// contents.
  static const headroom = tileWidth;

  /// Space under the map reserved for its thickness: the rock slab it
  /// stands on, deep enough to read once zoomed out on the whole map.
  static const slabDepth = 4 * tileHeight;

  /// The screen point of the [flat] map point.
  static Offset toScreen(Offset flat) =>
      Offset(flat.dx - flat.dy, (flat.dx + flat.dy) / 2);

  /// The flat map point of the [screen] point, inverse of [toScreen].
  static Offset toFlat(Offset screen) =>
      Offset(screen.dy + screen.dx / 2, screen.dy - screen.dx / 2);

  /// The middle of [cell], or of the [span] by [span] block from it.
  static Offset centreOf((int, int) cell, {int span = 1}) {
    final (x, y) = cell;
    return Offset((x - y) * cellSize, (x + y + span) * cellSize / 2);
  }

  /// The diamond of [cell], shrunk by [inset] flat pixels on each side.
  static Path diamondOf((int, int) cell, {double inset = 0}) {
    final (x, y) = cell;
    final cx = (x - y) * cellSize, cy = (x + y + 1) * cellSize / 2;
    final halfWidth = cellSize - 2 * inset, halfHeight = cellSize / 2 - inset;
    return Path()
      ..moveTo(cx, cy - halfHeight)
      ..lineTo(cx + halfWidth, cy)
      ..lineTo(cx, cy + halfHeight)
      ..lineTo(cx - halfWidth, cy)
      ..close();
  }

  /// The transform laying the flat map onto the screen, as [toScreen]
  /// does: a flat cell square becomes its diamond.
  static final Float64List isometric = Float64List.fromList([
    1, 0.5, 0, 0, //
    -1, 0.5, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 1,
  ]);

  /// The box bounding the diamond of [cell].
  static Rect tileRectOf((int, int) cell) {
    final (x, y) = cell;
    return Rect.fromLTWH(
      (x - y - 1) * cellSize,
      (x + y) * cellSize / 2,
      tileWidth,
      tileHeight,
    );
  }

  /// The box bounding the diamonds of the [span] by [span] block from
  /// [cell]: where a content lies on the floor.
  static Rect floorOf((int, int) cell, {int span = 1}) => Rect.fromCenter(
        center: centreOf(cell, span: span),
        width: tileWidth * span,
        height: tileHeight * span,
      );

  /// The [flat] box stood up on screen: same size, centred on the
  /// projection of its centre.
  static Rect upright(Rect flat) {
    final centre = toScreen(flat.center);
    return Rect.fromLTWH(
      centre.dx - flat.width / 2,
      centre.dy - flat.height / 2,
      flat.width,
      flat.height,
    );
  }

  /// Where a content standing on [cell], or on the [span] by [span]
  /// block from it, is drawn.
  static Rect standingOf((int, int) cell, {int span = 1}) {
    final centre = centreOf(cell, span: span);
    final side = standingWidthRatio * tileWidth * span;
    final bottom = centre.dy + standingDropRatio * tileHeight * span;
    return Rect.fromLTWH(centre.dx - side / 2, bottom - side, side, side);
  }

  /// Where the projection's origin lands in the box of a map of [rows].
  static Offset originOf(int rows) => Offset(rows * cellSize, headroom);

  /// The box holding a projected map of [columns] by [rows] cells, with
  /// the headroom above it and the slab under it.
  static Size sizeOf(int columns, int rows) => Size(
    (columns + rows) * cellSize,
    headroom + (columns + rows) * cellSize / 2 + slabDepth,
  );

  /// The cell whose diamond holds the [screen] projection point, or
  /// `null` outside a map of [columns] by [rows] cells.
  static (int, int)? cellAt(
    Offset screen, {
    required int columns,
    required int rows,
  }) => mapCellAt(toFlat(screen), width: columns, height: rows);
}
