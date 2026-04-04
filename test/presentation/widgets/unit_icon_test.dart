import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abyss/domain/unit_type.dart';
import 'package:abyss/presentation/widgets/unit_icon.dart';

void main() {
  group('UnitIcon', () {
    test('renders an SvgPicture', () {
      const icon = UnitIcon(type: UnitType.scout);
      final widget = icon.build(_FakeContext());
      expect(widget, isA<SvgPicture>());
    });

    test('uses correct asset path for scout', () {
      const icon = UnitIcon(type: UnitType.scout);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(
        svg.bytesLoader.toString(),
        contains('assets/icons/units/scout.svg'),
      );
    });

    test('uses correct asset path for domeBreaker', () {
      const icon = UnitIcon(type: UnitType.domeBreaker);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(
        svg.bytesLoader.toString(),
        contains('assets/icons/units/dome_breaker.svg'),
      );
    });

    test('default size is 40', () {
      const icon = UnitIcon(type: UnitType.scout);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.width, 40);
      expect(svg.height, 40);
    });

    test('custom size is applied', () {
      const icon = UnitIcon(type: UnitType.scout, size: 64);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.width, 64);
      expect(svg.height, 64);
    });

    test('greyscale mode applies a ColorFilter', () {
      const icon = UnitIcon(type: UnitType.scout, greyscale: true);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.colorFilter, isNotNull);
    });

    test('non-greyscale has no ColorFilter', () {
      const icon = UnitIcon(type: UnitType.scout);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.colorFilter, isNull);
    });
  });
}

class _FakeContext extends Fake implements BuildContext {}
