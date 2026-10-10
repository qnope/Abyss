import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/building/building_icon.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';

void main() {
  group('BuildingIcon', () {
    test('renders a RasterSvg', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final widget = icon.build(_FakeContext());
      expect(widget, isA<RasterSvg>());
    });

    test('uses correct asset path for headquarters', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(
        svg.assetPath,
        contains('assets/icons/buildings/headquarters.svg'),
      );
    });

    test('default size is 24', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.size, 24);
    });

    test('custom size is applied', () {
      const icon = BuildingIcon(
        type: BuildingType.headquarters,
        size: 64,
      );
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.size, 64);
    });

    test('greyscale mode draws the greyscale illustration', () {
      const icon = BuildingIcon(type: BuildingType.headquarters, greyscale: true);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.greyscale, isTrue);
      expect(svg.opacity, 1);
    });

    test('faded greyscale icon is drawn translucent', () {
      const icon = BuildingIcon(type: BuildingType.headquarters, greyscale: true, faded: true);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.greyscale, isTrue);
      expect(svg.opacity, AbyssColors.unavailableOpacity);
    });

    test('default icon is in colour and opaque', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final svg = icon.build(_FakeContext()) as RasterSvg;
      expect(svg.greyscale, isFalse);
      expect(svg.opacity, 1);
    });
  });
}

class _FakeContext extends Fake implements BuildContext {}
