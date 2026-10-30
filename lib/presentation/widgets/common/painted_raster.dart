import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'background_tasks.dart';

/// A drawing rasterized once into a bitmap, kept until another is asked.
///
/// Engines without a raster cache (CanvasKit on the web, Impeller) replay
/// every picture at every frame: a costly drawing that rarely changes (a
/// blur, gradients filling the screen) costs a single image draw once
/// rasterized. The owner (a state, a render object) disposes it.
///
/// Given [onReady], it rasterizes in the background, after the frame
/// asking (see [BackgroundTasks]; on the web, rasterizing holds the
/// frame): meanwhile its
/// drawing is replayed live, then the owner is called back to paint
/// again, from the bitmap.
class PaintedRaster {
  /// Longest side of a bitmap, in pixels: within any GPU's textures.
  static const maxSide = 4096;

  /// Called once a bitmap rasterized in the background is kept; given
  /// to a new owner along with the raster (see KeptRasters).
  VoidCallback? onReady;

  Object? _key;
  ui.Image? _image;
  Rect _area = Rect.zero;

  /// What the bitmap under way is for, and the ticket of that request.
  Object? _pending;
  Object? _ticket;

  /// The drawing of the bitmap under way, and its pixels per logical one.
  ui.Picture? _live;
  Offset _liveScale = const Offset(1, 1);

  PaintedRaster({this.onReady});

  /// The bitmap kept, if any.
  ui.Image? get image => _image;

  /// The bitmap of what [draw] paints over [area], at [resolution] pixels
  /// per logical pixel (less if a side would pass [maxSide]): the one
  /// kept while [key], [area] and [resolution] hold, else rasterized
  /// anew, the one kept disposed. None for an empty area, nor while it is
  /// rasterized in the background (see [onReady]).
  ui.Image? prepare(
    Object key,
    Rect area,
    double resolution,
    void Function(Canvas canvas) draw,
  ) {
    final wanted = (key, area, resolution);
    if (wanted == _key) return _image;
    if (wanted == _pending) return null;
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
    if (onReady == null) {
      _keep(picture.toImageSync(width, height), wanted, area);
      picture.dispose();
      return _image;
    }
    final ticket = _ticket = Object();
    _pending = wanted;
    _live = picture;
    _liveScale = Offset(width / area.width, height / area.height);
    _area = area;
    BackgroundTasks.run(() {
      if (ticket != _ticket) return picture.dispose();
      picture.toImage(width, height).then((image) {
        if (ticket != _ticket) return image.dispose();
        _keep(image, wanted, area);
        onReady?.call();
      }, onError: (Object error) {
        // Asked again at the next painting.
        if (ticket == _ticket) _pending = _ticket = null;
      }).whenComplete(picture.dispose);
    });
    return null;
  }

  void _keep(ui.Image image, Object key, Rect area) {
    _image = image;
    _key = key;
    _area = area;
    _pending = _ticket = _live = null;
  }

  /// Draws the bitmap kept where its drawing lay, shifted by [offset],
  /// sampled with [filterQuality] (with mipmaps from medium, for a bitmap
  /// shown much smaller than it is); while it is under way, its drawing.
  void drawOn(
    Canvas canvas, {
    Offset offset = Offset.zero,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    final image = _image, live = _live;
    if (image == null) {
      if (live == null) return;
      final at = _area.topLeft + offset;
      final scale = _liveScale;
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..scale(1 / scale.dx, 1 / scale.dy)
        ..clipRect(Offset.zero & Size(_area.width * scale.dx,
            _area.height * scale.dy))
        ..drawPicture(live)
        ..restore();
      return;
    }
    final source = Rect.fromLTWH(
        0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, source, _area.shift(offset),
        Paint()..filterQuality = filterQuality);
  }

  /// Disposes the bitmap kept, if any, and drops the one under way.
  void dispose() {
    _image?.dispose();
    _image = _key = _pending = _ticket = _live = null;
    _area = Rect.zero;
  }
}
