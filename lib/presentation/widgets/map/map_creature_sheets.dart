import 'dart:ui' as ui;

import '../ambience/creature_sheet.dart';
import '../common/run_concurrently.dart';
import '../common/svg_raster_cache.dart';
import 'living_creatures.dart';
import 'map_sprites.dart';

/// The undulating sheets of the map's living creatures, built once from
/// their sprites and shared by every map of the app.
abstract final class MapCreatureSheets {
  static final _pending = <String, Future<CreatureSheet>>{};
  static final _ready = <String, CreatureSheet>{};

  /// The sheet of the creature drawn with [sprite], if already built.
  static CreatureSheet? peek(String sprite) => _ready[sprite];

  /// Builds the sheet of every living creature of [sprites] not built
  /// yet, a few at a time so the map shown meanwhile stays smooth.
  static Future<void> preload(MapSprites sprites) => runConcurrently(
        livingCreatureSprites,
        SvgRasterCache.preloadWorkers,
        (path) => _load(path, sprites),
      );

  /// Builds the sheet of [path] on first use only; a failure is
  /// forgotten so the next call retries.
  static Future<CreatureSheet> _load(String path, MapSprites sprites) {
    return _pending[path] ??= _bitmapOf(path, sprites)
        .then(CreatureSheet.build)
        .then(
      (sheet) => _ready[path] = sheet,
      onError: (Object error) {
        _pending.remove(path);
        throw error;
      },
    );
  }

  /// The bitmap of [path]: a map sprite, or (for the kraken, which has
  /// no lair) the app's own bitmap of it.
  static Future<ui.Image> _bitmapOf(String path, MapSprites sprites) async =>
      sprites.svg(path) ?? await SvgRasterCache.load(path);
}
