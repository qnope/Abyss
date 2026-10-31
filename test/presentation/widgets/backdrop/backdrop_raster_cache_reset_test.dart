import 'dart:ui';

import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_raster_cache.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/stalled_loads.dart';
import '../../../helpers/test_svg_helper.dart';

const _asset = AbyssBackdrop.defaultAsset;
const _focus = AbyssBackdrop.colonyFocus;
const _size = Size(64, 32);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<Image> load() => BackdropRasterCache.load(_asset, _focus, _size);

  testWidgets('disposes every bitmap rasterized', (tester) async {
    (await loadsWithin(tester, load))?.dispose();
    final ready = BackdropRasterCache.cloneReady(_asset, _focus, _size);
    expect(ready, isNotNull);

    BackdropRasterCache.debugReset();

    expect(ready!.debugDisposed, isFalse, reason: 'a clone stays its own');
    expect(BackdropRasterCache.cloneReady(_asset, _focus, _size), isNull);
    ready.dispose();
  });

  testWidgets('forgets the loads that never end', (tester) async {
    (await loadsWithin(tester, load))?.dispose();
    BackdropRasterCache.debugReset();
    startForever(load);
    await expectStalled(tester, load);

    BackdropRasterCache.debugReset();

    final image = await loadsWithin(tester, load);
    expect(image?.width, _size.width);
    image?.dispose();
  });
}
