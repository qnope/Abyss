import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/unit/unit_icon.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';

void main() {
  group('UnitIcon', () {
    test('renders a RasterSvg', () {
      const icon = UnitIcon(type: UnitType.scout);
      final widget = icon.build(_FakeContext());
      expect(widget, isA<RasterSvg>());
    });

    test('uses correct asset path for scout', () {
      const icon = UnitIcon(type: UnitType.scout);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(
        svg.assetPath,
        contains('assets/icons/units/scout.svg'),
      );
    });

    test('uses correct asset path for domeBreaker', () {
      const icon = UnitIcon(type: UnitType.domeBreaker);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(
        svg.assetPath,
        contains('assets/icons/units/dome_breaker.svg'),
      );
    });

    test('default size is 40', () {
      const icon = UnitIcon(type: UnitType.scout);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.size, 40);
    });

    test('custom size is applied', () {
      const icon = UnitIcon(type: UnitType.scout, size: 64);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.size, 64);
    });

    test('greyscale mode draws the greyscale illustration', () {
      const icon = UnitIcon(type: UnitType.scout, greyscale: true);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.greyscale, isTrue);
      expect(svg.opacity, 1);
    });

    test('faded greyscale icon is drawn translucent', () {
      const icon = UnitIcon(type: UnitType.scout, greyscale: true, faded: true);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.greyscale, isTrue);
      expect(svg.opacity, AbyssColors.unavailableOpacity);
    });

    test('default icon is in colour and opaque', () {
      const icon = UnitIcon(type: UnitType.scout);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.greyscale, isFalse);
      expect(svg.opacity, 1);
    });
  });
}

class _FakeContext extends Fake implements BuildContext {}
