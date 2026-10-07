import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bitmaps of SVG assets, rasterized once per (asset, pixel size).
///
/// Detailed SVGs hold hundreds of shapes: replaying them every frame is
/// costly, especially on the web where pictures are not raster-cached.
/// Drawing a shared bitmap instead costs a single image draw.
abstract final class SvgRasterCache {
  static const _bucket = 32;

  static final _pending = <(String, int), Future<ui.Image>>{};
  static final _ready = <(String, int), ui.Image>{};

  /// Pixel size to rasterize a [logicalSize] icon at, rounded up to a
  /// bucket so close sizes share the same bitmap.
  static int pixelsFor(double logicalSize, double devicePixelRatio) {
    final pixels = (logicalSize * devicePixelRatio).ceil();
    return ((pixels + _bucket - 1) ~/ _bucket).clamp(1, 1 << 10) * _bucket;
  }

  /// The bitmap if it is already rasterized, without waiting.
  static ui.Image? peek(String path, int pixels) => _ready[(path, pixels)];

  /// Rasterizes [path] into a [pixels] x [pixels] bitmap on first use only.
  static Future<ui.Image> load(String path, int pixels) {
    final key = (path, pixels);
    return _pending[key] ??= _rasterize(path, pixels).then(
      (image) => _ready[key] = image,
      onError: (Object error) {
        _pending.remove(key);
        throw error;
      },
    );
  }

  static Future<ui.Image> _rasterize(String path, int pixels) async {
    final info = await vg.loadPicture(SvgAssetLoader(path), null);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixels / info.size.width, pixels / info.size.height);
    canvas.drawPicture(info.picture);
    info.picture.dispose();
    final picture = recorder.endRecording();
    return picture.toImage(pixels, pixels).whenComplete(picture.dispose);
  }
}
