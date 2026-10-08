import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/extensions/resource_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';

void main() {
  group('ResourceTypeColor.color', () {
    test('maps each resource to its theme color', () {
      expect(ResourceType.algae.color, AbyssColors.algaeGreen);
      expect(ResourceType.coral.color, AbyssColors.coralPink);
      expect(ResourceType.ore.color, AbyssColors.oreBlue);
      expect(ResourceType.energy.color, AbyssColors.energyYellow);
      expect(ResourceType.pearl.color, AbyssColors.pearlWhite);
    });

    test('every resource has a distinct color', () {
      final colors = ResourceType.values.map((t) => t.color).toSet();
      expect(colors, hasLength(ResourceType.values.length));
    });
  });

  group('ResourceTypeInfo.displayName', () {
    test('uses French labels', () {
      expect(ResourceType.algae.displayName, 'Algues');
      expect(ResourceType.coral.displayName, 'Corail');
      expect(ResourceType.ore.displayName, 'Minerai');
      expect(ResourceType.energy.displayName, 'Énergie');
      expect(ResourceType.pearl.displayName, 'Perles');
    });
  });

  group('ResourceTypeInfo.flavorText', () {
    test('every resource has a distinct, non-empty sentence', () {
      final texts = ResourceType.values.map((t) => t.flavorText).toList();
      expect(texts, everyElement(endsWith('.')));
      expect(texts.toSet(), hasLength(ResourceType.values.length));
    });

    test('describes what each resource is used for', () {
      expect(ResourceType.algae.flavorText, contains('nourrir'));
      expect(ResourceType.coral.flavorText, contains('bâtir'));
      expect(ResourceType.ore.flavorText, contains('forger'));
      expect(ResourceType.energy.flavorText, contains('alimenter'));
      expect(ResourceType.pearl.flavorText, contains('rares'));
    });
  });
}
