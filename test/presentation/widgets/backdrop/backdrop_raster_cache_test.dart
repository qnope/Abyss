import 'dart:ui';

import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_raster_cache.dart';
import 'package:flutter_test/flutter_test.dart';

const _asset = AbyssBackdrop.defaultAsset;
const _focus = AbyssBackdrop.colonyFocus;

void main() {
  group('BackdropRasterCache', () {
    testWidgets('rasterizes at the requested pixel size', (tester) async {
      await tester.runAsync(() async {
        final image = await BackdropRasterCache.load(
          _asset,
          _focus,
          const Size(256, 512),
        );
        expect(image.width, 256);
        expect(image.height, 512);
        image.dispose();
      });
    });

    testWidgets('shares one bitmap per size, handed out as clones', (
      tester,
    ) async {
      await tester.runAsync(() async {
        const size = Size(512, 256);
        final first = await BackdropRasterCache.load(_asset, _focus, size);
        final ready = BackdropRasterCache.cloneReady(_asset, _focus, size);
        expect(ready, isNotNull);
        expect(ready!.isCloneOf(first), isTrue);
        first.dispose();
        ready.dispose();
        final again = BackdropRasterCache.cloneReady(_asset, _focus, size);
        expect(again, isNotNull, reason: 'clones never free the cache');
        again!.dispose();
      });
    });

    testWidgets('keeps only the latest sizes', (tester) async {
      await tester.runAsync(() async {
        final sizes = [
          for (var i = 0; i <= BackdropRasterCache.maxEntries; i++)
            Size(100.0 * (i + 1), 300),
        ];
        for (final size in sizes) {
          (await BackdropRasterCache.load(_asset, _focus, size)).dispose();
        }
        expect(
          BackdropRasterCache.cloneReady(_asset, _focus, sizes.first),
          isNull,
        );
        final latest = BackdropRasterCache.cloneReady(
          _asset,
          _focus,
          sizes.last,
        );
        expect(latest, isNotNull);
        latest!.dispose();
      });
    });

    test('nothing is ready before a load', () {
      expect(
        BackdropRasterCache.cloneReady(_asset, _focus, const Size(9, 9)),
        isNull,
      );
    });
  });
}
