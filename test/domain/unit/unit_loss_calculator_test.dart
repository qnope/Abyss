import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_loss_calculator.dart';
import 'package:abyss/domain/unit/unit_type.dart';

Map<UnitType, Unit> _units(Map<UnitType, int> counts) {
  return {
    for (final entry in counts.entries)
      entry.key: Unit(type: entry.key, count: entry.value),
  };
}

void main() {
  group('calculateLosses', () {
    test('no deficit returns empty map', () {
      final units = _units({UnitType.scout: 10});
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 100,
        algaeStock: 0,
      );
      expect(result, isEmpty);
    });

    test('exact balance returns empty map', () {
      // 10 scouts = 10 algae, 5 harpoonists = 10 algae => total 20
      final units = _units({
        UnitType.scout: 10,
        UnitType.harpoonist: 5,
      });
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 15,
        algaeStock: 5,
      );
      expect(result, isEmpty);
    });

    test('proportional losses across types', () {
      // 10 scouts (10 algae) + 10 guardians (30 algae) = 40 total
      // available = 20, deficit = 20, ratio = 0.5
      // scouts lose ceil(10 * 0.5) = 5
      // guardians lose ceil(10 * 0.5) = 5
      final units = _units({
        UnitType.scout: 10,
        UnitType.guardian: 10,
      });
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 20,
        algaeStock: 0,
      );
      expect(result, {UnitType.scout: 5, UnitType.guardian: 5});
    });

    test('losses rounded up (ceil)', () {
      // 3 scouts = 3 algae. available = 2, deficit = 1
      // ratio = 1/3 ≈ 0.333. ceil(3 * 0.333) = 1
      final units = _units({UnitType.scout: 3});
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 2,
        algaeStock: 0,
      );
      expect(result, {UnitType.scout: 1});
    });

    test('losses cannot exceed unit count', () {
      // ratio = 1.0, available = 0
      final units = _units({UnitType.scout: 5, UnitType.guardian: 3});
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 0,
        algaeStock: 0,
      );
      expect(result, {UnitType.scout: 5, UnitType.guardian: 3});
    });

    test('zero count units not in result', () {
      final units = _units({
        UnitType.scout: 10,
        UnitType.harpoonist: 0,
      });
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 5,
        algaeStock: 0,
      );
      expect(result.containsKey(UnitType.harpoonist), isFalse);
      expect(result, {UnitType.scout: 5});
    });

    test('single unit type', () {
      // 5 harpoonists = 10 algae. available = 8, deficit = 2
      // ratio = 2/10 = 0.2. ceil(5 * 0.2) = 1
      final units = _units({UnitType.harpoonist: 5});
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 8,
        algaeStock: 0,
      );
      expect(result, {UnitType.harpoonist: 1});
    });

    test('stock covers deficit', () {
      // 5 scouts + 10 harpoonists = 5 + 20 = 25 algae
      // production=10, stock=30 => available=40 >= 25
      final units = _units({
        UnitType.scout: 5,
        UnitType.harpoonist: 10,
      });
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 10,
        algaeStock: 30,
      );
      expect(result, isEmpty);
    });

    test('stock not enough', () {
      // 10 scouts(1 each=10) + 5 harpoonists(2 each=10) = 20 algae
      // production=10, stock=5 => available=15, deficit=5
      // ratio = 5/20 = 0.25
      // scouts: ceil(10 * 0.25) = 3
      // harpoonists: ceil(5 * 0.25) = 2
      final units = _units({
        UnitType.scout: 10,
        UnitType.harpoonist: 5,
      });
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 10,
        algaeStock: 5,
      );
      expect(result, {UnitType.scout: 3, UnitType.harpoonist: 2});
    });

    test('100% deficit kills all units', () {
      final units = _units({
        UnitType.scout: 3,
        UnitType.guardian: 2,
        UnitType.abyssAdmiral: 4,
      });
      final result = UnitLossCalculator.calculateLosses(
        units: units,
        algaeProduction: 0,
        algaeStock: 0,
      );
      expect(result, {
        UnitType.scout: 3,
        UnitType.guardian: 2,
        UnitType.abyssAdmiral: 4,
      });
    });
  });

  group('calculateLossesAllLevels', () {
    test('no deficit returns empty', () {
      final result = UnitLossCalculator.calculateLossesAllLevels(
        unitsPerLevel: {1: _units({UnitType.scout: 5})},
        algaeProduction: 100,
        algaeStock: 0,
      );
      expect(result, isEmpty);
    });

    test('counts units on all levels for consumption', () {
      // Lv1: 10 scouts=10, Lv2: 10 scouts=10 => total 20
      // available=10 => deficit=10, ratio=0.5
      // Each level loses ceil(10*0.5)=5
      // Aggregated: scout=10
      final result = UnitLossCalculator.calculateLossesAllLevels(
        unitsPerLevel: {
          1: _units({UnitType.scout: 10}),
          2: _units({UnitType.scout: 10}),
        },
        algaeProduction: 10,
        algaeStock: 0,
      );
      expect(result, {UnitType.scout: 10});
    });

    test('does not mutate units', () {
      final lv1 = _units({UnitType.scout: 10});
      final lv2 = _units({UnitType.scout: 10});
      UnitLossCalculator.calculateLossesAllLevels(
        unitsPerLevel: {1: lv1, 2: lv2},
        algaeProduction: 0,
        algaeStock: 0,
      );
      expect(lv1[UnitType.scout]!.count, 10);
      expect(lv2[UnitType.scout]!.count, 10);
    });
  });

  group('applyLossesAllLevels', () {
    test('no deficit does nothing', () {
      final lv1 = _units({UnitType.scout: 5});
      final result = UnitLossCalculator.applyLossesAllLevels(
        unitsPerLevel: {1: lv1},
        algaeProduction: 100,
        algaeStock: 0,
      );
      expect(result, isEmpty);
      expect(lv1[UnitType.scout]!.count, 5);
    });

    test('mutates units on all levels', () {
      // Lv1: 10 scouts=10, Lv2: 10 scouts=10 => total 20
      // available=10 => deficit=10, ratio=0.5
      final lv1 = _units({UnitType.scout: 10});
      final lv2 = _units({UnitType.scout: 10});
      UnitLossCalculator.applyLossesAllLevels(
        unitsPerLevel: {1: lv1, 2: lv2},
        algaeProduction: 10,
        algaeStock: 0,
      );
      expect(lv1[UnitType.scout]!.count, 5);
      expect(lv2[UnitType.scout]!.count, 5);
    });

    test('returns aggregated losses', () {
      final lv1 = _units({UnitType.scout: 6});
      final lv2 = _units({UnitType.scout: 4});
      // total consumption = 10, available = 0, ratio = 1.0
      final result = UnitLossCalculator.applyLossesAllLevels(
        unitsPerLevel: {1: lv1, 2: lv2},
        algaeProduction: 0,
        algaeStock: 0,
      );
      expect(result, {UnitType.scout: 10});
      expect(lv1[UnitType.scout]!.count, 0);
      expect(lv2[UnitType.scout]!.count, 0);
    });
  });
}
