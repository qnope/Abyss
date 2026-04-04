import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/production_calculator.dart';
import 'package:abyss/domain/resource_type.dart';

void main() {
  Map<BuildingType, Building> allBuildingsAtLevel(int level) {
    return {
      for (final type in BuildingType.values)
        type: Building(type: type, level: level),
    };
  }

  group('ProductionCalculator.fromBuildings', () {
    test('all buildings at level 0 returns empty map', () {
      final buildings = allBuildingsAtLevel(0);
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, isEmpty);
    });

    test('algaeFarm at level 3 produces 290 algae', () {
      final buildings = {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 3,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.algae: 290});
    });

    test('coralMine at level 2 produces 100 coral', () {
      final buildings = {
        BuildingType.coralMine: Building(
          type: BuildingType.coralMine,
          level: 2,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.coral: 100});
    });

    test('oreExtractor at level 1 produces 30 ore', () {
      final buildings = {
        BuildingType.oreExtractor: Building(
          type: BuildingType.oreExtractor,
          level: 1,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.ore: 30});
    });

    test('solarPanel at level 4 produces 66 energy', () {
      final buildings = {
        BuildingType.solarPanel: Building(
          type: BuildingType.solarPanel,
          level: 4,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.energy: 66});
    });

    test('multiple buildings cumulate correctly', () {
      final buildings = {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 2,
        ),
        BuildingType.coralMine: Building(
          type: BuildingType.coralMine,
          level: 3,
        ),
        BuildingType.oreExtractor: Building(
          type: BuildingType.oreExtractor,
          level: 1,
        ),
        BuildingType.solarPanel: Building(
          type: BuildingType.solarPanel,
          level: 2,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {
        ResourceType.algae: 140,
        ResourceType.coral: 200,
        ResourceType.ore: 30,
        ResourceType.energy: 18,
      });
    });

    test('headquarters produces nothing regardless of level', () {
      final buildings = {
        BuildingType.headquarters: Building(
          type: BuildingType.headquarters,
          level: 5,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, isEmpty);
    });

    test('pearl is never in the result', () {
      final buildings = allBuildingsAtLevel(3);
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production.containsKey(ResourceType.pearl), isFalse);
    });
  });
}
