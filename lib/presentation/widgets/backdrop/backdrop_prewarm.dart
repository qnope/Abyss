import 'dart:ui' as ui;

import 'abyss_backdrop.dart';
import 'backdrop_geometry.dart';
import 'backdrop_raster_cache.dart';

/// Starts rasterizing the menu backdrop for the whole of [view], before
/// any screen asks for it: the home screen then shows the art sooner.
///
/// Completes once the bitmap is cached. Does nothing while the view has
/// no size yet; never fails, the backdrop being decoration only.
Future<void> prewarmBackdrop(ui.FlutterView view) async {
  final bucket = rasterBucket(view.physicalSize);
  if (bucket.isEmpty) return;
  try {
    final image = await BackdropRasterCache.load(
      AbyssBackdrop.defaultAsset,
      AbyssBackdrop.colonyFocus,
      bucket,
    );
    image.dispose();
  } catch (_) {
    // The backdrop rasterizes again, or shows its gradient, when needed.
  }
}
