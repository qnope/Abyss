import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../common/painted_raster.dart';
import '../../common/span_cover.dart';
import 'slab_strip.dart';

/// The bitmap of a stretch of a slab's face, over [area] of its strip
/// (see [SlabStrip]), as [SlabRockChunks] keeps it.
class SlabRockChunk {
  final Rect area;
  final PaintedRaster raster;

  /// The last painting that asked or drew it.
  int used = 0;

  SlabRockChunk(this.area, this.raster);

  /// Draws the [span] of [strip] on its face from the bitmaps of its
  /// [chunks] (by resolution) that are ready: those nearest [resolution]
  /// first, the others in the gaps they leave; at painting [frame].
  static void drawSpan(Canvas canvas, SlabStrip strip, (double, double) span,
      double resolution, int frame, List<(double, SlabRockChunk)> chunks) {
    final ready = <double, List<SpanPiece<SlabRockChunk>>>{};
    for (final (r, chunk) in chunks) {
      if (chunk.raster.image == null) continue;
      (ready[r] ??= [])
          .add((source: chunk, from: chunk.area.left, to: chunk.area.right));
    }
    double distance(double r) => (math.log(r / resolution)).abs();
    final order = ready.keys.toList()
      ..sort((a, b) => distance(a).compareTo(distance(b)));
    final pieces =
        coverSpan(span.$1, span.$2, [for (final r in order) ready[r]!]);
    if (pieces.isEmpty) return;
    canvas
      ..save()
      ..transform(strip.matrix);
    for (final (:source, :from, :to) in pieces) {
      source.drawOn(canvas, from, to, frame);
    }
    canvas.restore();
  }

  /// Drops the [chunks] under way not asked at painting [frame], then
  /// the oldest drawn past [budget] pixels, those at [keep] kept.
  static void evict(Map<(int, double, int), SlabRockChunk> chunks,
      int frame, int budget, {required double keep}) {
    final old = chunks.entries
        .where((e) => e.key.$2 != keep && e.value.used != frame)
        .toList()
      ..sort((a, b) => b.value.used.compareTo(a.value.used));
    var pixels = 0;
    for (final MapEntry(:key, :value) in old) {
      final image = value.raster.image;
      pixels += image == null ? 0 : image.width * image.height;
      if (image != null && pixels <= budget) continue;
      value.raster.dispose();
      chunks.remove(key);
    }
  }

  /// Draws the bitmap from [from] to [to] along the strip, unsmoothed at
  /// its edges so that stretches side by side leave no seam.
  void drawOn(Canvas canvas, double from, double to, int frame) {
    final image = raster.image!;
    used = frame;
    final scale = image.width / area.width;
    canvas.drawImageRect(
      image,
      Rect.fromLTRB((from - area.left) * scale, 0,
          (to - area.left) * scale, image.height.toDouble()),
      Rect.fromLTRB(from, area.top, to, area.bottom),
      Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.medium,
    );
  }
}
