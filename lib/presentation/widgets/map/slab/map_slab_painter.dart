import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../viewport_cover.dart';
import 'iso_slab.dart';
import 'iso_slab_painter.dart';
import 'slab_rock_chunks.dart';

/// Paints the rock [slab] a map stands on, in projection coordinates, as
/// the map seen through [transform] (from its box, the projection's
/// origin at [origin]) in a [viewport] shows it: its body and lips drawn
/// live, its rock from the bitmaps of [chunks], sharp at the zoom.
///
/// Paints nothing while the part of the box the slab never reaches
/// ([clear]) covers the screen, though the bitmaps of whole faces, and
/// of the rock around the screen, are asked for, ready once it shows.
class MapSlabPainter extends CustomPainter {
  /// How far past the screen's edges the slab must lie to be left out:
  /// more than a blow shakes the map, and its lit lips.
  static const margin = 8.0;

  final IsoSlab slab;
  final SlabRockChunks chunks;
  final ValueListenable<Matrix4> transform;
  final Size viewport;
  final Offset origin;
  final List<Offset> clear;

  /// Pixels per logical pixel of the device.
  final double ratio;

  /// The resolution of the bitmaps of whole faces.
  final double coarsest;

  MapSlabPainter({
    required this.slab,
    required this.chunks,
    required this.transform,
    required this.viewport,
    required this.origin,
    required this.clear,
    required this.ratio,
    required this.coarsest,
    Listenable? repaint,
  }) : super(repaint: repaint ?? transform);

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = transform.value;
    final scale = matrix.storage[0];
    if (scale <= 0) return;
    final shift = Offset(matrix.storage[12], matrix.storage[13]);
    final visible = Rect.fromPoints(-shift / scale,
            (viewport.bottomRight(Offset.zero) - shift) / scale)
        .shift(-origin)
        .inflate(margin);
    final hidden = coversViewport(clear, matrix, viewport, margin: margin);
    if (!hidden) IsoSlabPainter.paintBody(canvas, slab);
    chunks.paint(canvas, visible, scale * ratio,
        coarsest: coarsest, hidden: hidden);
    if (!hidden) IsoSlabPainter.paintLips(canvas, slab);
  }

  @override
  bool shouldRepaint(MapSlabPainter oldDelegate) =>
      oldDelegate.slab != slab ||
      oldDelegate.chunks != chunks ||
      oldDelegate.transform != transform ||
      oldDelegate.viewport != viewport ||
      oldDelegate.origin != origin ||
      oldDelegate.ratio != ratio ||
      oldDelegate.coarsest != coarsest;
}
