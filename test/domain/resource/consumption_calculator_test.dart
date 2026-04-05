import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/consumption_calculator.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  Map<BuildingType, Building> buildingMap(
    Map<BuildingType, int> levels,
  ) {
    return {
      for (final entry in levels.entries)
        entry.key: Building(type: entry.key, level: entry.value),
    };
  }

  Map<UnitType, Unit> unitMap(Map<UnitType, int> counts) {
    return {
      for (final entry in counts.entries)
        entry.key: Unit(type: entry.key, count: entry.value),
    };
  }

  group('buildingEnergyConsumption', () {
    test('headquarters level 3 consumes 9 energy', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.headquarters, 3,
        ),
        9,
      );
    });

    test('algaeFarm level 5 consumes 10 energy', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.algaeFarm, 5,
        ),
        10,
      );
    });

    test('coralMine level 2 consumes 4 energy', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.coralMine, 2,
        ),
        4,
      );
    });

    test('oreExtractor level 4 consumes 12 energy', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.oreExtractor, 4,
        ),
        12,
      );
    });

    test('solarPanel level 5 consumes 5 energy', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.solarPanel, 5,
        ),
        5,
      );
    });

    test('laboratory level 1 consumes 4 energy', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.laboratory, 1,
        ),
        4,
      );
    });

    test('barracks level 3 consumes 9 energy', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.barracks, 3,
        ),
        9,
      );
    });

    test('level 0 returns 0', () {
      expect(
        ConsumptionCalculator.buildingEnergyConsumption(
          BuildingType.headquarters, 0,
        ),
        0,
      );
    });
  });

  group('totalBuildingConsumption', () {
    test('sums all active buildings', () {
      final buildings = buildingMap({
        BuildingType.headquarters: 2,
        BuildingType.algaeFarm: 1,
      });
      expect(ConsumptionCalculator.totalBuildingConsumption(buildings), 8);
    });

    test('level 0 buildings are excluded', () {
      final buildings = buildingMap({
        BuildingType.headquarters: 0,
        BuildingType.algaeFarm: 0,
      });
      expect(ConsumptionCalculator.totalBuildingConsumption(buildings), 0);
    });

    test('excluded buildings are not counted', () {
      final buildings = buildingMap({
        BuildingType.headquarters: 2,
        BuildingType.algaeFarm: 1,
      });
      expect(
        ConsumptionCalculator.totalBuildingConsumption(
          buildings,
          excluded: {BuildingType.algaeFarm},
        ),
        6,
      );
    });

    test('empty map returns 0', () {
      expect(
        ConsumptionCalculator.totalBuildingConsumption({}),
        0,
      );
    });
  });

  group('unitAlgaeConsumption', () {
    test('scout consumes 1 algae', () {
      expect(ConsumptionCalculator.unitAlgaeConsumption(UnitType.scout), 1);
    });

    test('harpoonist consumes 2 algae', () {
      expect(
        ConsumptionCalculator.unitAlgaeConsumption(UnitType.harpoonist),
        2,
      );
    });

    test('guardian consumes 3 algae', () {
      expect(
        ConsumptionCalculator.unitAlgaeConsumption(UnitType.guardian),
        3,
      );
    });

    test('domeBreaker consumes 3 algae', () {
      expect(
        ConsumptionCalculator.unitAlgaeConsumption(UnitType.domeBreaker),
        3,
      );
    });

    test('siphoner consumes 2 algae', () {
      expect(
        ConsumptionCalculator.unitAlgaeConsumption(UnitType.siphoner),
        2,
      );
    });

    test('saboteur consumes 2 algae', () {
      expect(
        ConsumptionCalculator.unitAlgaeConsumption(UnitType.saboteur),
        2,
      );
    });
  });

  group('totalUnitConsumption', () {
    test('sums across unit types', () {
      final units = unitMap({
        UnitType.scout: 10,
        UnitType.guardian: 5,
      });
      expect(ConsumptionCalculator.totalUnitConsumption(units), 25);
    });

    test('zero count units contribute nothing', () {
      final units = unitMap({
        UnitType.scout: 0,
        UnitType.harpoonist: 0,
      });
      expect(ConsumptionCalculator.totalUnitConsumption(units), 0);
    });

    test('empty map returns 0', () {
      expect(ConsumptionCalculator.totalUnitConsumption({}), 0);
    });
  });
}
