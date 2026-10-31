import 'package:abyss/presentation/widgets/base/base_sprites.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/stalled_loads.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  void resetAll() {
    SvgRasterCache.debugReset();
    MapSprites.debugReset();
    BaseSprites.debugReset();
  }

  testWidgets('forgets the sprites loaded', (tester) async {
    final sprites = await loadsWithin(tester, BaseSprites.load);
    expect(BaseSprites.ready, same(sprites));

    BaseSprites.debugReset();

    expect(BaseSprites.ready, isNot(same(sprites)),
        reason: 'gathered anew from the bitmaps still rasterized');
    resetAll();
    expect(BaseSprites.ready, isNull);
  });

  testWidgets('forgets a load that never ends', (tester) async {
    await loadsWithin(tester, BaseSprites.load);
    resetAll();
    startForever(BaseSprites.load);
    await expectStalled(tester, BaseSprites.load);

    resetAll();

    expect(await loadsWithin(tester, BaseSprites.load), isNotNull);
  });
}
