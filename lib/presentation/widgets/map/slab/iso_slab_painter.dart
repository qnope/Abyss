import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../../theme/abyss_slab_theme.dart';
import '../map_projection.dart';
import 'iso_slab.dart';
import 'slab_rock.dart';

/// Paints the rock slab an isometric map [columns] by [rows] cells stands
/// on (see [IsoSlab]), in projection coordinates: the abyss darkening
/// under it, both faces shaded from their lips down, their strata,
/// stones and algae, the specks glowing in the rock, then the lit lips.
///
/// Meant to be painted once into a still, cached layer: the game's map
/// paints it in its still floor, a base can paint it on its own. A few
/// batched draws per face, no oval nor rect.
class IsoSlabPainter extends CustomPainter {
  final int columns;
  final int rows;
  final double depth;
  final int salt;

  const IsoSlabPainter({
    required this.columns,
    required this.rows,
    this.depth = MapProjection.slabDepth,
    this.salt = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final slab =
        IsoSlab(columns: columns, rows: rows, depth: depth, salt: salt);
    if (slab.faces.isEmpty) return;
    final unit = slab.faces.first.unit;
    _underShadow(canvas, slab);
    for (final face in slab.faces) {
      final (from, to) = face.shading;
      canvas.drawPath(
        face.outline,
        Paint()
          ..shader = ui.Gradient.linear(from, to,
              face.lit ? AbyssSlabTheme.litFace : AbyssSlabTheme.shadedFace,
              AbyssSlabTheme.faceStops),
      );
    }
    for (final face in slab.faces) {
      SlabRock.strata(canvas, face, unit);
      SlabRock.stones(canvas, face, unit);
      SlabRock.strands(canvas, face);
    }
    SlabRock.specks(canvas, slab, unit);
    for (final face in slab.faces) {
      canvas.drawLine(face.start, face.end, Paint()
        ..color = face.lit ? AbyssSlabTheme.litLip : AbyssSlabTheme.shadedLip
        ..strokeWidth = 1.4 * unit);
    }
  }

  /// The dark of the abyss under the foot of the slab, a flattened disc.
  void _underShadow(Canvas canvas, IsoSlab slab) {
    final radius = 0.55 * (slab.right.dx - slab.left.dx);
    canvas
      ..save()
      ..translate(slab.bottom.dx, slab.bottom.dy + 1.1 * depth)
      ..scale(1, 0.7 * depth / radius)
      ..drawCircle(Offset.zero, radius, Paint()
        ..shader = ui.Gradient.radial(Offset.zero, radius, const [
          AbyssSlabTheme.underShadow,
          Color(0x0002050A),
        ]))
      ..restore();
  }

  @override
  bool shouldRepaint(IsoSlabPainter oldDelegate) =>
      oldDelegate.columns != columns ||
      oldDelegate.rows != rows ||
      oldDelegate.depth != depth ||
      oldDelegate.salt != salt;
}
