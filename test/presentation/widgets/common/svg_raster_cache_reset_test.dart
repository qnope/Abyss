import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/stalled_loads.dart';
import '../../../helpers/test_svg_helper.dart';

const _path = 'assets/icons/resources/pearl.svg';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('forgets every bitmap rasterized', (tester) async {
    await loadsWithin(tester, () => SvgRasterCache.load(_path));
    await loadsWithin(tester, () => SvgRasterCache.loadGrey(_path));
    expect(SvgRasterCache.peek(_path), isNotNull);
    expect(SvgRasterCache.peekGrey(_path), isNotNull);

    SvgRasterCache.debugReset();

    expect(SvgRasterCache.peek(_path), isNull);
    expect(SvgRasterCache.peekGrey(_path), isNull);
    expect(SvgRasterCache.readyPaths, isEmpty);
  });

  testWidgets('forgets the loads that never end', (tester) async {
    await loadsWithin(tester, () => SvgRasterCache.load(_path));
    SvgRasterCache.debugReset();
    startForever(() => SvgRasterCache.loadGrey(_path));
    await expectStalled(tester, () => SvgRasterCache.loadGrey(_path));

    SvgRasterCache.debugReset();

    final image = await loadsWithin(tester, () => SvgRasterCache.load(_path));
    expect(image?.width, SvgRasterCache.pixels);
    expect(await loadsWithin(tester, () => SvgRasterCache.loadGrey(_path)),
        isNotNull);
  });
}
