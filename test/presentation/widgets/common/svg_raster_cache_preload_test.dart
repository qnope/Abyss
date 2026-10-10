import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SvgRasterCache.preloads', () {
    test('preloads square icons and save illustrations', () {
      expect(SvgRasterCache.preloads('assets/icons/units/scout.svg'), isTrue);
      expect(
        SvgRasterCache.preloads('assets/illustrations/saves/depth_deep.svg'),
        isTrue,
      );
    });

    test('skips the menu backdrop, rasterized at screen size instead', () {
      expect(
        SvgRasterCache.preloads('assets/illustrations/menu/abyss_backdrop.svg'),
        isFalse,
      );
    });

    test('skips assets that are not SVG', () {
      expect(SvgRasterCache.preloads('assets/fonts/Rajdhani.ttf'), isFalse);
    });
  });
}
