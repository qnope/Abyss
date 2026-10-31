import 'package:abyss/presentation/widgets/army/army_sprites.dart';
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
    ArmySprites.debugReset();
  }

  testWidgets('forgets the sprites loaded', (tester) async {
    final sprites = await loadsWithin(tester, ArmySprites.load);
    expect(ArmySprites.ready, same(sprites));

    ArmySprites.debugReset();

    expect(ArmySprites.ready, isNot(same(sprites)),
        reason: 'gathered anew from the bitmaps still rasterized');
    resetAll();
    expect(ArmySprites.ready, isNull);
  });

  testWidgets('forgets a load that never ends', (tester) async {
    await loadsWithin(tester, ArmySprites.load);
    resetAll();
    startForever(ArmySprites.load);
    await expectStalled(tester, ArmySprites.load);

    resetAll();

    expect(await loadsWithin(tester, ArmySprites.load), isNotNull);
  });
}
