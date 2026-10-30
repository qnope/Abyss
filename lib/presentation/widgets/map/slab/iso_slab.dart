import 'dart:ui';

import '../map_cell_size.dart';
import '../map_projection.dart';
import 'slab_face.dart';

export 'slab_face.dart';

/// The thickness of an isometric map [columns] by [rows] cells, laid out
/// by [MapProjection]: two rock faces [depth] deep under its front edges,
/// the lit one from its left vertex to its bottom vertex, the shaded one
/// from there to its right vertex.
///
/// Pure and deterministic: the same size and [salt] give the same rock.
/// Knows nothing of the game's map, so a base laid out on the same
/// projection stands on one too.
class IsoSlab {
  final int columns;
  final int rows;
  final double depth;

  /// The lit face then the shaded one; none on an empty map.
  final List<SlabFace> faces;

  IsoSlab._(this.columns, this.rows, this.depth, this.faces);

  factory IsoSlab({
    required int columns,
    required int rows,
    double depth = MapProjection.slabDepth,
    int salt = 0,
  }) {
    if (columns <= 0 || rows <= 0) return IsoSlab._(columns, rows, depth, []);
    Offset vertex(int x, int y) =>
        MapProjection.toScreen(Offset(x * cellSize, y * cellSize));
    final left = vertex(0, rows), bottom = vertex(columns, rows);
    final right = vertex(columns, 0);
    return IsoSlab._(columns, rows, depth, [
      SlabFace.scatter(start: left, end: bottom, tiles: columns,
          depth: depth, lit: true, salt: salt),
      SlabFace.scatter(start: bottom, end: right, tiles: rows,
          depth: depth, lit: false, salt: salt),
    ]);
  }

  /// The left, bottom and right vertices of the map: where the lips meet.
  Offset get left => faces.first.start;
  Offset get bottom => faces.first.end;
  Offset get right => faces.last.end;
}
