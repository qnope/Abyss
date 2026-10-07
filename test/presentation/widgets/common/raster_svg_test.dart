import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _path = 'assets/icons/resources/pearl.svg';

void main() {
  group('SvgRasterCache', () {
    test('rounds pixel sizes up to shared buckets', () {
      expect(SvgRasterCache.pixelsFor(24, 1), 32);
      expect(SvgRasterCache.pixelsFor(24, 3), 96);
      expect(SvgRasterCache.pixelsFor(64, 4), 256);
      expect(SvgRasterCache.pixelsFor(0, 1), 32);
    });

    testWidgets('rasterizes an asset once and shares it', (tester) async {
      await tester.runAsync(() async {
        final image = await SvgRasterCache.load(_path, 64);
        expect(image.width, 64);
        expect(image.height, 64);
        expect(await SvgRasterCache.load(_path, 64), same(image));
        expect(SvgRasterCache.peek(_path, 64), same(image));
      });
    });
  });

  group('RasterSvg', () {
    testWidgets('draws the cached bitmap at the requested size', (
      tester,
    ) async {
      await tester.runAsync(() => SvgRasterCache.load(_path, 32));
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(devicePixelRatio: 1),
          child: Center(child: RasterSvg(assetPath: _path, size: 24)),
        ),
      );
      final raw = tester.widget<RawImage>(find.byType(RawImage));
      expect(raw.image, isNotNull);
      expect(tester.getSize(find.byType(RasterSvg)), const Size(24, 24));
    });

    testWidgets('passes the tint to the image', (tester) async {
      await tester.pumpWidget(
        const Center(
          child: RasterSvg(
            assetPath: _path,
            color: Colors.grey,
            colorBlendMode: BlendMode.saturation,
          ),
        ),
      );
      final raw = tester.widget<RawImage>(find.byType(RawImage));
      expect(raw.color, Colors.grey);
      expect(raw.colorBlendMode, BlendMode.saturation);
    });
  });
}
