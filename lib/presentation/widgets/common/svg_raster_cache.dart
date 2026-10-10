import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'greyscale_bitmap.dart';
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
  static final _pendingGrey = <String, Future<ui.Image>>{};
  static final _readyGrey = <String, ui.Image>{};

  /// Paths of every SVG rasterized so far.
  static Iterable<String> get readyPaths => _ready.keys;

  /// The bitmap if it is already rasterized, without waiting.
  static ui.Image? peek(String path) => _ready[path];

  /// Rasterizes [path] on first use only.
  static Future<ui.Image> load(String path) =>
      _memoize(_pending, _ready, path, () => _rasterize(path));

  /// The greyscale bitmap if it is already derived, without waiting.
  static ui.Image? peekGrey(String path) => _readyGrey[path];

  /// Derives a greyscale copy of [path]'s bitmap on first use only, so
  /// locked items show their real illustration greyed at the cost of a
  /// single plain image draw.
  static Future<ui.Image> loadGrey(String path) => _memoize(
    _pendingGrey,
    _readyGrey,
    path,
    () => load(path).then(greyscaleBitmap),
  );

  /// SVGs rasterized at the same time while preloading: enough to parse
  /// on several cores, few enough to keep the screen shown meanwhile
  /// responsive.
  static const preloadWorkers = 3;

  /// Folders of SVGs that are not square icons: full-screen art is
  /// rasterized at screen size by its own cache instead.
  static const notPreloaded = ['assets/illustrations/menu/'];

  /// Whether [preloadAll] rasterizes the asset at [path].
  static bool preloads(String path) =>
      path.endsWith('.svg') && !notPreloaded.any(path.startsWith);

  /// Rasterizes every square SVG asset of the app, so no screen ever
  /// waits for one. Meant to run once at startup.
  static Future<void> preloadAll([AssetBundle? bundle]) async {
    final manifest = await AssetManifest.loadFromAssetBundle(
      bundle ?? rootBundle,
    );
    final paths = manifest.listAssets().where(preloads);
    await runConcurrently(paths, preloadWorkers, load);
  }

  /// Derives the greyscale bitmap of every path in [paths] ahead of time.
  static Future<void> preloadGrey(Iterable<String> paths) =>
      runConcurrently(paths, preloadWorkers, loadGrey);

  /// Runs [compute] once per [path]; a failure is forgotten so the next
  /// call retries.
  static Future<ui.Image> _memoize(
    Map<String, Future<ui.Image>> pending,
    Map<String, ui.Image> ready,
    String path,
    Future<ui.Image> Function() compute,
  ) {
    return pending[path] ??= compute().then(
      (image) => ready[path] = image,
      onError: (Object error) {
        pending.remove(path);
        throw error;
      },
    );
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
