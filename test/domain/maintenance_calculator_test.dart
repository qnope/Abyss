import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/maintenance_calculator.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/unit.dart';
import 'package:abyss/domain/unit_type.dart';

Map<UnitType, Unit> _units({
  int scout = 0,
  int harpoonist = 0,
  int guardian = 0,
  int domeBreaker = 0,
  int siphoner = 0,
  int saboteur = 0,
}) => {
  UnitType.scout: Unit(type: UnitType.scout, count: scout),
  UnitType.harpoonist: Unit(type: UnitType.harpoonist, count: harpoonist),
  UnitType.guardian: Unit(type: UnitType.guardian, count: guardian),
  UnitType.domeBreaker: Unit(type: UnitType.domeBreaker, count: domeBreaker),
  UnitType.siphoner: Unit(type: UnitType.siphoner, count: siphoner),
  UnitType.saboteur: Unit(type: UnitType.saboteur, count: saboteur),
};

void main() {
  group('MaintenanceCalculator', () {
    test('no units returns empty map', () {
      expect(MaintenanceCalculator.fromUnits(_units()), isEmpty);
    });

    test('single unit type with count 5', () {
      final result = MaintenanceCalculator.fromUnits(_units(scout: 5));
      expect(result, {ResourceType.algae: 5});
    });

    test('single unit type with count 10', () {
      final result = MaintenanceCalculator.fromUnits(_units(harpoonist: 10));
      expect(result, {ResourceType.algae: 20});
    });

    test('multiple unit types sum correctly', () {
      final result = MaintenanceCalculator.fromUnits(
        _units(scout: 5, guardian: 3),
      );
      expect(result, {ResourceType.algae: 14});
    });

    test('units with zero count are ignored', () {
      final result = MaintenanceCalculator.fromUnits(
        _units(scout: 0, harpoonist: 5),
      );
      expect(result, {ResourceType.algae: 10});
    });
  });
}
