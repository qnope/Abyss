import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _path = 'assets/icons/resources/pearl.svg';

void main() {
  group('SvgRasterCache', () {
    testWidgets('rasterizes an asset once and shares it', (tester) async {
      await tester.runAsync(() async {
        final image = await SvgRasterCache.load(_path);
        expect(image.width, SvgRasterCache.pixels);
        expect(image.height, SvgRasterCache.pixels);
        expect(await SvgRasterCache.load(_path), same(image));
        expect(SvgRasterCache.peek(_path), same(image));
      });
    });

    testWidgets('preloads every SVG asset', (tester) async {
      await tester.runAsync(SvgRasterCache.preloadAll);
      for (final path in [
        'assets/icons/buildings/laboratory.svg',
        'assets/icons/units/scout.svg',
        'assets/icons/terrain/plain.svg',
      ]) {
        expect(SvgRasterCache.peek(path), isNotNull, reason: path);
      }
    });
  });

  group('RasterSvg', () {
    testWidgets('draws the cached bitmap at the requested size', (
      tester,
    ) async {
      await tester.runAsync(() => SvgRasterCache.load(_path));
      await tester.pumpWidget(
        const Center(child: RasterSvg(assetPath: _path, size: 24)),
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

    testWidgets('draws the greyscale bitmap when greyscale', (tester) async {
      await tester.runAsync(() => SvgRasterCache.loadGrey(_path));
      await tester.pumpWidget(
        const Center(child: RasterSvg(assetPath: _path, greyscale: true)),
      );
      final raw = tester.widget<RawImage>(find.byType(RawImage));
      expect(raw.image, same(SvgRasterCache.peekGrey(_path)));
      expect(raw.image, isNot(same(SvgRasterCache.peek(_path))));
    });

    testWidgets('draws the colour bitmap by default', (tester) async {
      await tester.runAsync(() => SvgRasterCache.loadGrey(_path));
      await tester.pumpWidget(const Center(child: RasterSvg(assetPath: _path)));
      final raw = tester.widget<RawImage>(find.byType(RawImage));
      expect(raw.image, same(SvgRasterCache.peek(_path)));
    });

    testWidgets('switches bitmap when greyscale toggles', (tester) async {
      await tester.runAsync(() => SvgRasterCache.loadGrey(_path));
      RawImage raw() => tester.widget<RawImage>(find.byType(RawImage));
      await tester.pumpWidget(const Center(child: RasterSvg(assetPath: _path)));
      expect(raw().image, same(SvgRasterCache.peek(_path)));
      await tester.pumpWidget(
        const Center(child: RasterSvg(assetPath: _path, greyscale: true)),
      );
      expect(raw().image, same(SvgRasterCache.peekGrey(_path)));
      await tester.pumpWidget(const Center(child: RasterSvg(assetPath: _path)));
      expect(raw().image, same(SvgRasterCache.peek(_path)));
    });

    testWidgets('passes the opacity to the image', (tester) async {
      await tester.pumpWidget(
        const Center(child: RasterSvg(assetPath: _path, opacity: 0.85)),
      );
      final raw = tester.widget<RawImage>(find.byType(RawImage));
      expect(raw.opacity?.value, 0.85);
    });

    testWidgets('draws fully opaque without opacity', (tester) async {
      await tester.pumpWidget(const Center(child: RasterSvg(assetPath: _path)));
      final raw = tester.widget<RawImage>(find.byType(RawImage));
      expect(raw.opacity, isNull);
    });
  });
}
