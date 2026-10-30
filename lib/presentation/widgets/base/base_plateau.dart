import 'dart:ui';

import '../../../domain/map/terrain_type.dart';
import '../backdrop/trench/trench_backdrop.dart';
import '../map/map_floor_tiles.dart';
import '../map/map_scatter.dart';
import '../map/map_sprites.dart';
import '../map/slab/iso_slab_painter.dart';
import 'base_fit.dart';
import 'base_spire.dart';

/// Lays an island of the abyss on a [canvas] of [size], under what stands
/// on it: the trench behind over the whole canvas, then, moved to
/// projection coordinates by [fit], the spire under a plateau of [cells]
/// by [cells] cells, what hangs along it ([onSpire], given how far down
/// the view ends), the slab of rock of [slabSalt] and the floor in the
/// map's diamond tiles (one mesh, see [MapFloorTiles]), plain diamonds
/// while [sprites] load.
///
/// Leaves the canvas in projection coordinates: the caller saves it
/// before and restores it once it has drawn the rest of its island.
void paintBasePlateau(
  Canvas canvas,
  Size size,
  BaseFit fit, {
  required int cells,
  required int slabSalt,
  MapSprites? sprites,
  void Function(double bottom)? onSpire,
}) {
  const TrenchWaterPainter().paint(canvas, size);
  const TrenchRidgesPainter().paint(canvas, size);
  fit.apply(canvas);
  final below = fit.toProjection(Offset(0, size.height)).dy;
  const depth = BaseFit.slabDepth;
  paintBaseSpire(canvas, cells, depth, bottom: below);
  onSpire?.call(below);
  IsoSlabPainter(columns: cells, rows: cells, depth: depth, salt: slabSalt)
      .paint(canvas, size);
  final floor = MapFloorTiles(sprites);
  for (var y = 0; y < cells; y++) {
    for (var x = 0; x < cells; x++) {
      final cell = (x, y);
      floor.add(canvas, cell, floorTileOf(TerrainType.plain, cell));
    }
  }
  floor.flush(canvas);
}
