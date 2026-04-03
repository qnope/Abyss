import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building_type.dart';

void main() {
  group('BuildingType', () {
    test('headquarters exists', () {
      expect(BuildingType.headquarters, isNotNull);
    });

    test('enum has exactly 5 values', () {
      expect(BuildingType.values.length, 5);
    });
  });
}
