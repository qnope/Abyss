import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_cost_calculator.dart';
import 'package:abyss/domain/building/building_type.dart';
void main() {
  late BuildingCostCalculator calculator;

  setUp(() {
    calculator = BuildingCostCalculator();
  });

  group('prerequisites', () {
    test('HQ has no prerequisites', () {
      final prereqs = calculator.prerequisites(
        BuildingType.headquarters,
        1,
      );
      expect(prereqs, isEmpty);
    });

    test('algaeFarm level 1 requires HQ 1', () {
      final prereqs = calculator.prerequisites(BuildingType.algaeFarm, 1);
      expect(prereqs[BuildingType.headquarters], 1);
    });

    test('algaeFarm level 3 requires HQ 4', () {
      final prereqs = calculator.prerequisites(BuildingType.algaeFarm, 3);
      expect(prereqs[BuildingType.headquarters], 4);
    });

    test('algaeFarm level 5 requires HQ 10', () {
      final prereqs = calculator.prerequisites(BuildingType.algaeFarm, 5);
      expect(prereqs[BuildingType.headquarters], 10);
    });

    test('coralMine level 2 requires HQ 2', () {
      final prereqs = calculator.prerequisites(BuildingType.coralMine, 2);
      expect(prereqs[BuildingType.headquarters], 2);
    });

    test('solarPanel level 4 requires HQ 6', () {
      final prereqs = calculator.prerequisites(
        BuildingType.solarPanel,
        4,
      );
      expect(prereqs[BuildingType.headquarters], 6);
    });

    test('laboratory level 1 requires HQ 2', () {
      final prereqs = calculator.prerequisites(BuildingType.laboratory, 1);
      expect(prereqs[BuildingType.headquarters], 2);
    });

    test('laboratory level 5 requires HQ 10', () {
      final prereqs = calculator.prerequisites(BuildingType.laboratory, 5);
      expect(prereqs[BuildingType.headquarters], 10);
    });

    test('barracks level 1 requires HQ 3', () {
      final prereqs = calculator.prerequisites(BuildingType.barracks, 1);
      expect(prereqs[BuildingType.headquarters], 3);
    });

    test('barracks level 5 requires HQ 10', () {
      final prereqs = calculator.prerequisites(BuildingType.barracks, 5);
      expect(prereqs[BuildingType.headquarters], 10);
    });
  });
}
