import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/presentation/widgets/resource_icon.dart';

void main() {
  group('ResourceIcon', () {
    test('asset path matches type name for each resource', () {
      const expected = {
        ResourceType.algae: 'assets/icons/resources/algae.svg',
        ResourceType.coral: 'assets/icons/resources/coral.svg',
        ResourceType.ore: 'assets/icons/resources/ore.svg',
        ResourceType.energy: 'assets/icons/resources/energy.svg',
        ResourceType.pearl: 'assets/icons/resources/pearl.svg',
      };
      for (final type in ResourceType.values) {
        final icon = ResourceIcon(type: type);
        final svg = icon.build(_FakeContext()) as SvgPicture;
        expect(
          svg.bytesLoader.toString(),
          contains(expected[type]),
        );
      }
    });

    test('default size is 24', () {
      const icon = ResourceIcon(type: ResourceType.algae);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.width, 24);
      expect(svg.height, 24);
    });

    test('custom size is applied', () {
      const icon = ResourceIcon(type: ResourceType.coral, size: 48);
      final svg = icon.build(_FakeContext()) as SvgPicture;
      expect(svg.width, 48);
      expect(svg.height, 48);
    });

    test('all five resource types exist', () {
      expect(ResourceType.values.length, 5);
      expect(ResourceType.values, contains(ResourceType.algae));
      expect(ResourceType.values, contains(ResourceType.coral));
      expect(ResourceType.values, contains(ResourceType.ore));
      expect(ResourceType.values, contains(ResourceType.energy));
      expect(ResourceType.values, contains(ResourceType.pearl));
    });
  });
}

class _FakeContext extends Fake implements BuildContext {}
