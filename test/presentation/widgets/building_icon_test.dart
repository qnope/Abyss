import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/presentation/widgets/building_icon.dart';

void main() {
  group('BuildingIcon', () {
    test('renders an SvgPicture', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final widget = icon.build(_FakeContext());
      expect(widget, isA<SvgPicture>());
    });

    test('uses correct asset path for headquarters', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(
        svg.bytesLoader.toString(),
        contains('assets/icons/buildings/headquarters.svg'),
      );
    });

    test('default size is 24', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.width, 24);
      expect(svg.height, 24);
    });

    test('custom size is applied', () {
      const icon = BuildingIcon(
        type: BuildingType.headquarters,
        size: 64,
      );
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.width, 64);
      expect(svg.height, 64);
    });

    test('greyscale mode applies a ColorFilter', () {
      const icon = BuildingIcon(
        type: BuildingType.headquarters,
        greyscale: true,
      );
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.colorFilter, isNotNull);
    });

    test('non-greyscale has no ColorFilter', () {
      const icon = BuildingIcon(type: BuildingType.headquarters);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.colorFilter, isNull);
    });
  });
}

class _FakeContext extends Fake implements BuildContext {}
