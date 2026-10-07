import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/unit/unit_icon.dart';
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

    test('greyscale mode applies a tint', () {
      const icon = UnitIcon(type: UnitType.scout, greyscale: true);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.color, isNotNull);
    });

    test('non-greyscale has no tint', () {
      const icon = UnitIcon(type: UnitType.scout);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.color, isNull);
    });
  });
}

class _FakeContext extends Fake implements BuildContext {}
