import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/production_calculator.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  group('BuildingTypeInfo', () {
    test('laboratory displayName is Laboratoire', () {
      expect(BuildingType.laboratory.displayName(fr), 'Laboratoire');
    });

    test('barracks displayName is Caserne', () {
      expect(BuildingType.barracks.displayName(fr), 'Caserne');
    });

    test('names the buildings in English and Spanish', () {
      expect(BuildingType.headquarters.displayName(en), 'Headquarters');
      expect(BuildingType.algaeFarm.displayName(es), 'Granja de algas');
      expect(BuildingType.pressureCapsule.displayName(es),
          'Cápsula Presurizada');
    });

    test('the pressure capsule keeps its accent in French', () {
      expect(BuildingType.pressureCapsule.displayName(fr),
          'Capsule Pressurisée');
    });

    test('every building has a name and a description in each language', () {
      for (final l10n in [fr, en, es]) {
        for (final type in BuildingType.values) {
          expect(type.displayName(l10n), isNotEmpty);
          expect(type.description(l10n), isNotEmpty);
        }
      }
    });

    test('the headquarters description gives its income per turn', () {
      final coral = ProductionCalculator.headquartersIncome[ResourceType.coral];
      final ore = ProductionCalculator.headquartersIncome[ResourceType.ore];
      expect(BuildingType.headquarters.description(fr),
          contains('il fournit $coral corail et $ore minerai par tour'));
      expect(BuildingType.headquarters.description(en),
          contains('$coral coral and $ore ore per turn'));
    });

    test('laboratory iconPath', () {
      expect(
        BuildingType.laboratory.iconPath,
        'assets/icons/buildings/laboratory.svg',
      );
    });

    test('barracks iconPath', () {
      expect(
        BuildingType.barracks.iconPath,
        'assets/icons/buildings/barracks.svg',
      );
    });
  });

  group('BuildingTypeInfo - volcanicKernel', () {
    test('color is AbyssColors.warning', () {
      expect(BuildingType.volcanicKernel.color, AbyssColors.warning);
    });

    test('displayName is Noyau Volcanique', () {
      expect(BuildingType.volcanicKernel.displayName(fr), 'Noyau Volcanique');
      expect(BuildingType.volcanicKernel.displayName(en), 'Volcanic Core');
    });

    test('description speaks of the burning heart, with its accents', () {
      expect(BuildingType.volcanicKernel.description(fr),
          startsWith('Le cœur brûlant des abysses.'));
    });

    test('iconPath is not empty', () {
      expect(BuildingType.volcanicKernel.iconPath, isNotEmpty);
    });
  });

  group('BuildingTypeInfo - coralCitadel', () {
    test('displayName is Citadelle corallienne', () {
      expect(
          BuildingType.coralCitadel.displayName(fr), 'Citadelle corallienne');
      expect(BuildingType.coralCitadel.displayName(es), 'Ciudadela de coral');
    });

    test('iconPath points to coral_citadel.svg', () {
      expect(
        BuildingType.coralCitadel.iconPath,
        'assets/icons/buildings/coral_citadel.svg',
      );
    });

    test('description is non-empty and mentions défense', () {
      final description = BuildingType.coralCitadel.description(fr);
      expect(description, isNotEmpty);
      expect(description, contains('défense'));
    });

    test('color is AbyssColors.coralPink', () {
      expect(BuildingType.coralCitadel.color, AbyssColors.coralPink);
    });
  });
}
