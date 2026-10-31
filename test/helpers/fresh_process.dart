import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_raster_cache.dart';
import 'package:abyss/presentation/widgets/base/base_sprites.dart';
import 'package:abyss/presentation/widgets/common/background_tasks.dart';
import 'package:abyss/presentation/widgets/common/kept_rasters.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:abyss/presentation/widgets/map/map_creature_sheets.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fresh_channels.dart';
import 'fresh_hive.dart';

/// Puts the process back as a fresh `flutter test` process starts a test
/// file: no bitmap, sprite or picture cached by the app (nor a load of
/// one under way, perhaps never to end in a test's faked time gone), no
/// SVG or image decoded, no asset cached, no platform mock left, and Hive
/// with no box open nor app adapter registered.
///
/// Meant to run before each test file sharing a process with others,
/// from a `setUpAll`; safe outside a test's body.
Future<void> resetProcessState() async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  _resetAppCaches();
  svg.cache.clear();
  binding.imageCache
    ..clear()
    ..clearLiveImages();
  rootBundle.clear();
  resetPlatformChannels();
  await resetHive();
}

void _resetAppCaches() {
  BackgroundTasks.debugReset();
  KeptRasters.debugReset();
  ArmySquadsPainter.banners.debugReset();
  MapCreatureSheets.debugReset();
  ArmySprites.debugReset();
  BaseSprites.debugReset();
  MapSprites.debugReset();
  BackdropRasterCache.debugReset();
  SvgRasterCache.debugReset();
}
