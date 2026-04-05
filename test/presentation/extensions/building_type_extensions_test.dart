import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';

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
}
