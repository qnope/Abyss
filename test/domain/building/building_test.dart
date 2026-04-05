import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';

void main() {
  group('Building', () {
    test('creates with required type', () {
      final b = Building(type: BuildingType.headquarters);
      expect(b.type, BuildingType.headquarters);
    });

    test('default level is 0', () {
      final b = Building(type: BuildingType.headquarters);
      expect(b.level, 0);
    });

    test('level is mutable', () {
      final b = Building(type: BuildingType.headquarters);
      b.level = 3;
      expect(b.level, 3);
    });

    test('accepts custom level', () {
      final b = Building(type: BuildingType.headquarters, level: 5);
      expect(b.level, 5);
    });
  });
}
