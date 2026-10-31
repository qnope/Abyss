import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'painted_raster.dart';

/// The bitmap of a painting gone, with what it showed: the [painter] and
/// the [painting] it was rasterized for.
class KeptRaster {
  final PaintedRaster raster;
  final CustomPainter painter;
  final int painting;

  const KeptRaster(this.raster, this.painter, this.painting);
}

/// The latest bitmap of each name, kept once what painted it is gone,
/// until a new painting takes it back (see RasterPaint.keepAs): shown
/// again unchanged, as on coming back to a tab, it is not rasterized
/// again. One bitmap at most per name.
abstract final class KeptRasters {
  static final _kept = <Object, KeptRaster>{};

  /// The bitmap kept as [name], if any, now the caller's.
  static KeptRaster? take(Object name) => _kept.remove(name);

  /// Keeps [kept] as [name], disposing the one kept before.
  static void keep(Object name, KeptRaster kept) {
    kept.raster.onReady = null;
    _kept.remove(name)?.raster.dispose();
    _kept[name] = kept;
  }

  /// Disposes every bitmap kept, as at startup.
  @visibleForTesting
  static void debugReset() {
    for (final kept in _kept.values) {
      kept.raster.dispose();
    }
    _kept.clear();
  }
}
