import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'run_concurrently.dart';

/// Bitmaps of SVG assets, rasterized once per asset.
///
/// Detailed SVGs hold hundreds of shapes: replaying them every frame is
/// costly, especially on the web where pictures are not raster-cached.
/// Drawing a shared bitmap instead costs a single image draw. Every SVG is
/// rasterized at [pixels] and drawn downscaled with mipmaps, so any icon
/// size reuses the same bitmap.
abstract final class SvgRasterCache {
  /// Side of every bitmap: sharp for map sprites and the largest icons.
  static const pixels = 256;

  static final _pending = <String, Future<ui.Image>>{};
  static final _ready = <String, ui.Image>{};

  /// Paths of every SVG rasterized so far.
  static Iterable<String> get readyPaths => _ready.keys;

  /// The bitmap if it is already rasterized, without waiting.
  static ui.Image? peek(String path) => _ready[path];

  /// Rasterizes [path] on first use only.
  static Future<ui.Image> load(String path) {
    return _pending[path] ??= _rasterize(path).then(
      (image) => _ready[path] = image,
      onError: (Object error) {
        _pending.remove(path);
        throw error;
      },
    );
  }

  /// SVGs rasterized at the same time while preloading: enough to parse
  /// on several cores, few enough to keep the screen shown meanwhile
  /// responsive.
  static const preloadWorkers = 3;

  /// Rasterizes every SVG asset of the app, so no screen ever waits for
  /// one. Meant to run once at startup.
  static Future<void> preloadAll([AssetBundle? bundle]) async {
    final manifest = await AssetManifest.loadFromAssetBundle(
      bundle ?? rootBundle,
    );
    final paths = manifest.listAssets().where((p) => p.endsWith('.svg'));
    await runConcurrently(paths, preloadWorkers, load);
  }

  static Future<ui.Image> _rasterize(String path) async {
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
