import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/extensions/resource_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';

import '../../helpers/l10n_fixtures.dart';

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
      expect(ResourceType.algae.displayName(fr), 'Algues');
      expect(ResourceType.coral.displayName(fr), 'Corail');
      expect(ResourceType.ore.displayName(fr), 'Minerai');
      expect(ResourceType.energy.displayName(fr), 'Énergie');
      expect(ResourceType.pearl.displayName(fr), 'Perles');
    });

    test('translates the names', () {
      expect(ResourceType.ore.displayName(en), 'Ore');
      expect(ResourceType.energy.displayName(es), 'Energía');
    });
  });

  group('ResourceTypeInfo.flavorText', () {
    test('every resource has a distinct, non-empty sentence', () {
      final texts = ResourceType.values.map((t) => t.flavorText(fr)).toList();
      expect(texts, everyElement(endsWith('.')));
      expect(texts.toSet(), hasLength(ResourceType.values.length));
      for (final l10n in [en, es]) {
        expect(ResourceType.pearl.flavorText(l10n), endsWith('.'));
      }
    });

    test('describes what each resource is used for', () {
      expect(ResourceType.algae.flavorText(fr), contains('nourrir'));
      expect(ResourceType.coral.flavorText(fr), contains('bâtir'));
      expect(ResourceType.ore.flavorText(fr), contains('forger'));
      expect(ResourceType.energy.flavorText(fr), contains('alimenter'));
      expect(ResourceType.pearl.flavorText(fr), contains('rares'));
    });
  });

  group('ResourceGainsLabel.gainLabel', () {
    test('lists each gain in lower case, in the order given', () {
      expect(
        {ResourceType.coral: 30, ResourceType.ore: 20}.gainLabel(fr),
        '+30 corail, +20 minerai',
      );
    });

    test('lists the gains in English and Spanish', () {
      const gains = {ResourceType.algae: 5, ResourceType.ore: 2};
      expect(gains.gainLabel(en), '+5 algae, +2 ore');
      expect(gains.gainLabel(es), '+5 algas, +2 mineral');
    });

    test('leaves out what was not gained', () {
      expect(
        {ResourceType.coral: 0, ResourceType.pearl: 2}.gainLabel(fr),
        '+2 perles',
      );
    });

    test('is empty without any gain', () {
      expect(const <ResourceType, int>{}.gainLabel(fr), isEmpty);
    });
  });
}
