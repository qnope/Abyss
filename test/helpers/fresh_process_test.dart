import 'dart:async';
import 'dart:ui' as ui;

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_raster_cache.dart';
import 'package:abyss/presentation/widgets/base/base_sprites.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:abyss/presentation/widgets/map/living_creatures.dart';
import 'package:abyss/presentation/widgets/map/map_creature_sheets.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fresh_process.dart';
import 'path_provider_mock.dart';
import 'stalled_loads.dart';
import 'test_svg_helper.dart';

const _icon = 'assets/icons/resources/pearl.svg';
const _backdrop = AbyssBackdrop.defaultAsset;
const _focus = AbyssBackdrop.colonyFocus;
const _size = Size(64, 32);

void main() {
  setUpAll(resetProcessState);
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;

  testWidgets('forgets every bitmap the app keeps', (tester) async {
    mockSvgAssets();
    final sprites = await loadsWithin(tester, ArmySprites.load);
    await loadsWithin(tester, BaseSprites.load);
    await loadsWithin(tester, () => MapCreatureSheets.preload(sprites!.map));
    await loadsWithin(tester, () => SvgRasterCache.load(_icon));
    (await loadsWithin(
            tester, () => BackdropRasterCache.load(_backdrop, _focus, _size)))
        ?.dispose();
    ArmySquadsPainter.banners
        .replay(Canvas(ui.PictureRecorder()), (UnitType.scout, false), (_) {});
    SvgRasterCache.debugReset();
    startForever(() => SvgRasterCache.load(_icon));

    await tester.runAsync(resetProcessState);

    expect(SvgRasterCache.readyPaths, isEmpty);
    expect(MapSprites.ready, isNull);
    expect(ArmySprites.ready, isNull);
    expect(BaseSprites.ready, isNull);
    expect(MapCreatureSheets.peek(livingCreatureSprites.first), isNull);
    expect(BackdropRasterCache.cloneReady(_backdrop, _focus, _size), isNull);
    expect(ArmySquadsPainter.banners.length, 0);
    mockSvgAssets();
    expect(await loadsWithin(tester, ArmySprites.load), isNotNull,
        reason: 'no load left stalled');
    clearSvgMocks();
  });

  test('forgets the SVGs and images decoded', () async {
    mockSvgAssets();
    await vg.loadPicture(const SvgAssetLoader(_icon), null);
    expect(svg.cache.count, greaterThan(0));
    imageCache.putIfAbsent(
        'pending', () => OneFrameImageStreamCompleter(Completer<ImageInfo>().future));
    expect(imageCache.pendingImageCount, 1);

    await resetProcessState();

    expect(svg.cache.count, 0);
    expect(imageCache.pendingImageCount, 0);
  });

  test('answers assets from the bundle again, as at start', () async {
    final real = await rootBundle.loadString(_icon);
    mockSvgAssets();
    rootBundle.evict(_icon);
    expect(await rootBundle.loadString(_icon), isNot(real));

    await resetProcessState();

    expect(await rootBundle.loadString(_icon), real);
  });

  test('takes off the platform mocks tests leave', () async {
    mockDocumentsDirectory('/nowhere');
    messenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async => null);

    await resetProcessState();

    expect(messenger.checkMockMessageHandler(
        'plugins.flutter.io/path_provider', null), isTrue);
    expect(messenger.checkMockMessageHandler(
        SystemChannels.platform.name, null), isTrue);
  });
}
