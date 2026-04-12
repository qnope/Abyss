import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';

void main() {
  group('BuildingTypeInfo', () {
    test('laboratory displayName is Laboratoire', () {
      expect(BuildingType.laboratory.displayName, 'Laboratoire');
    });

    test('barracks displayName is Caserne', () {
      expect(BuildingType.barracks.displayName, 'Caserne');
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
      expect(BuildingType.volcanicKernel.displayName, 'Noyau Volcanique');
    });

    test('iconPath is not empty', () {
      expect(BuildingType.volcanicKernel.iconPath, isNotEmpty);
    });
  });

  group('BuildingTypeInfo - coralCitadel', () {
    test('displayName is Citadelle corallienne', () {
      expect(BuildingType.coralCitadel.displayName, 'Citadelle corallienne');
    });

    test('iconPath points to coral_citadel.svg', () {
      expect(
        BuildingType.coralCitadel.iconPath,
        'assets/icons/buildings/coral_citadel.svg',
      );
    });

    test('description is non-empty and mentions défense', () {
      final description = BuildingType.coralCitadel.description;
      expect(description, isNotEmpty);
      expect(description, contains('défense'));
    });

    test('color is AbyssColors.coralPink', () {
      expect(BuildingType.coralCitadel.color, AbyssColors.coralPink);
    });
  });
}
