import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';

void main() {
  group('BuildingType', () {
    test('headquarters exists', () {
      expect(BuildingType.headquarters, isNotNull);
    });

    test('enum has exactly 7 values', () {
      expect(BuildingType.values.length, 7);
    });

    test('laboratory exists', () {
      expect(BuildingType.laboratory, isNotNull);
    });

    test('barracks exists', () {
      expect(BuildingType.barracks, isNotNull);
    });
  });
}
