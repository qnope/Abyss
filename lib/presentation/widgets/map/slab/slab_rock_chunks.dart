import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../common/background_tasks.dart';
import '../../common/painted_raster.dart';
import 'iso_slab.dart';
import 'iso_slab_painter.dart';
import 'slab_rock_chunk.dart';
import 'slab_strip.dart';

/// The rock of a slab's faces (strata, stones, algae, specks) drawn from
/// bitmaps of stretches of each face seen straight on (see [SlabStrip]),
/// a handful of image draws at any zoom instead of hundreds of paths.
///
/// A stretch is rasterized in the background (see [PaintedRaster]) at
/// the resolution asked, only once seen; until it is ready, the nearest
/// resolution kept stands in, the coarsest (whole faces, always kept)
/// last. Bitmaps no longer drawn go once they pass [budget] pixels.
class SlabRockChunks {
  /// Widest bitmap of a stretch, in pixels.
  static const chunkPixels = 1024;

  /// The finest resolution, in pixels per logical pixel.
  static const finest = 8.0;

  final List<SlabStrip> strips;

  /// Pixels the bitmaps of finer resolutions than the coarsest keep, when
  /// no longer drawn.
  final int budget;

  /// Called once a bitmap is ready, to paint again.
  final VoidCallback onReady;

  final _chunks = <(int, double, int), SlabRockChunk>{};
  int _frame = 0;
  double? _pixels;
  Rect? _visible;
  bool _again = false, _trickled = false, _more = false;

  SlabRockChunks(IsoSlab slab, {required this.onReady, this.budget = 8 << 20})
      : strips = [for (final face in slab.faces) SlabStrip(face)];

  /// The resolution of the bitmaps for [pixels] per logical pixel: the
  /// power of two above, unless a fifth of a step under; from [coarsest]
  /// up to [finest].
  static double resolutionFor(double pixels, {double coarsest = 0}) {
    if (!(pixels > 0)) return math.max(coarsest, 1 / 64);
    final step = (math.log(pixels) / math.ln2 - 0.2).ceil();
    return math.pow(2, step).toDouble().clamp(coarsest, finest);
  }

  /// The bitmaps kept: their face, resolution and stretch, and whether
  /// they are ready.
  @visibleForTesting
  Iterable<(int, double, Rect, bool)> get kept => _chunks.entries.map((e) =>
      (e.key.$1, e.key.$2, e.value.area, e.value.raster.image != null));

  /// Draws the rock [visible] (a box of the map) sees, unless [hidden],
  /// as sharp as [pixels] per logical pixel ask (see [resolutionFor])
  /// once ready, whole faces at [coarsest] standing in meanwhile.
  ///
  /// Asks for no sharper bitmap while [pixels] change from a painting to
  /// the next (a pinch, which rasterizing would hold on the web), what is
  /// kept standing in; once the view holds still, also for those of the
  /// rock around the screen, one at a time (a gesture then waits on one
  /// at most), ready before a pan reaches it. Calls [onReady] back to go
  /// on.
  void paint(Canvas canvas, Rect visible, double pixels,
      {required double coarsest, bool hidden = false}) {
    _frame++;
    final resolution = resolutionFor(pixels, coarsest: coarsest);
    final steady = _pixels == null || _pixels == pixels;
    final still = steady && (_visible == null || _visible == visible);
    _pixels = pixels;
    _visible = visible;
    if (!still) _paintAgain();
    _trickled = _more = false;
    final around = visible.inflate(visible.shortestSide / 2);
    for (final (face, strip) in strips.indexed) {
      _ask(face, coarsest, strip.area.left, strip.area.right);
      final span = hidden ? null : strip.spanOn(visible);
      if (span != null && steady) _ask(face, resolution, span.$1, span.$2);
      final near = still ? strip.spanOn(around) : null;
      if (near != null) {
        _ask(face, resolution, near.$1, near.$2, trickle: true);
      }
      if (span == null) continue;
      SlabRockChunk.drawSpan(canvas, strip, span, resolution, _frame, [
        for (final MapEntry(:key, :value) in _chunks.entries)
          if (key.$1 == face) (key.$2, value),
      ]);
    }
    if (_more) _paintAgain();
    SlabRockChunk.evict(_chunks, _frame, budget, keep: coarsest);
  }

  /// Calls [onReady] back once, after this frame.
  void _paintAgain() {
    if (_again) return;
    _again = true;
    BackgroundTasks.run(() {
      _again = false;
      onReady();
    });
  }

  /// Asks for the bitmaps of [face] at [resolution] from [from] to [to];
  /// to [trickle], for one new bitmap a painting, the next one asked once
  /// it is made.
  void _ask(int face, double resolution, double from, double to,
      {bool trickle = false}) {
    final strip = strips[face];
    final width = chunkPixels / resolution, area = strip.area;
    final first = ((from - area.left) / width).floor();
    final last = ((to - area.left) / width).ceil();
    for (var i = math.max(0, first); i < last; i++) {
      final left = area.left + i * width;
      if (left >= area.right) break;
      final key = (face, resolution, i);
      if (trickle && !_chunks.containsKey(key)) {
        if (_trickled) {
          _more = true;
          continue;
        }
        _trickled = true;
      }
      final chunk = _chunks[key] ??= SlabRockChunk(
          Rect.fromLTRB(left, area.top,
              math.min(left + width, area.right), area.bottom),
          PaintedRaster(onReady: onReady));
      chunk
        ..used = _frame
        ..raster.prepare(0, chunk.area, resolution, (canvas) {
          canvas.transform(strip.inverse);
          IsoSlabPainter.paintRock(canvas, strip.face);
        });
    }
  }

  void dispose() {
    for (final chunk in _chunks.values) {
      chunk.raster.dispose();
    }
    _chunks.clear();
  }
}
