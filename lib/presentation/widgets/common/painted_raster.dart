import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// A drawing rasterized once into a bitmap, kept until another is asked.
///
/// Engines without a raster cache (CanvasKit on the web, Impeller) replay
/// every picture at every frame: a costly drawing that rarely changes (a
/// blur, gradients filling the screen) costs a single image draw once
/// rasterized. The owner (a state, a render object) disposes it.
class PaintedRaster {
  /// Longest side of a bitmap, in pixels: within any GPU's textures.
  static const maxSide = 4096;

  Object? _key;
  ui.Image? _image;
  Rect _area = Rect.zero;

  /// The bitmap kept, if any.
  ui.Image? get image => _image;

  /// The bitmap of what [draw] paints over [area], at [resolution] pixels
  /// per logical pixel (less if a side would pass [maxSide]): the one
  /// kept while [key], [area] and [resolution] hold, else rasterized
  /// anew, the one kept disposed. None for an empty area.
  ui.Image? prepare(
    Object key,
    Rect area,
    double resolution,
    void Function(Canvas canvas) draw,
  ) {
    final wanted = (key, area, resolution);
    if (wanted == _key) return _image;
    dispose();
    if (area.isEmpty || resolution <= 0) return null;
    final scale = math.min(resolution,
        maxSide / math.max(area.width, area.height));
    final width = math.max(1, (area.width * scale).round());
    final height = math.max(1, (area.height * scale).round());
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(width / area.width, height / area.height)
      ..translate(-area.left, -area.top);
    draw(canvas);
    final picture = recorder.endRecording();
    _image = picture.toImageSync(width, height);
    picture.dispose();
    _key = wanted;
    _area = area;
    return _image;
  }

  /// Draws the bitmap kept where its drawing lay, shifted by [offset],
  /// sampled with [filterQuality] (with mipmaps from medium, for a bitmap
  /// shown much smaller than it is).
  void drawOn(
    Canvas canvas, {
    Offset offset = Offset.zero,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    final image = _image;
    if (image == null) return;
    final source = Rect.fromLTWH(
        0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, source, _area.shift(offset),
        Paint()..filterQuality = filterQuality);
  }

  /// Disposes the bitmap kept, if any.
  void dispose() {
    _image?.dispose();
    _image = _key = null;
    _area = Rect.zero;
  }
}
