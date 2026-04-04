import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/production_calculator.dart';
import 'package:abyss/domain/resource_type.dart';

void main() {
  Map<BuildingType, Building> _allBuildingsAtLevel(int level) {
    return {
      for (final type in BuildingType.values)
        type: Building(type: type, level: level),
    };
  }

  group('ProductionCalculator.fromBuildings', () {
    test('all buildings at level 0 returns empty map', () {
      final buildings = _allBuildingsAtLevel(0);
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, isEmpty);
    });

    test('algaeFarm at level 3 produces 15 algae', () {
      final buildings = {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 3,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.algae: 15});
    });

    test('coralMine at level 2 produces 8 coral', () {
      final buildings = {
        BuildingType.coralMine: Building(
          type: BuildingType.coralMine,
          level: 2,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.coral: 8});
    });

    test('oreExtractor at level 1 produces 3 ore', () {
      final buildings = {
        BuildingType.oreExtractor: Building(
          type: BuildingType.oreExtractor,
          level: 1,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.ore: 3});
    });

    test('solarPanel at level 4 produces 12 energy', () {
      final buildings = {
        BuildingType.solarPanel: Building(
          type: BuildingType.solarPanel,
          level: 4,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.energy: 12});
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
        ResourceType.algae: 10,
        ResourceType.coral: 12,
        ResourceType.ore: 3,
        ResourceType.energy: 6,
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
      final buildings = _allBuildingsAtLevel(3);
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production.containsKey(ResourceType.pearl), isFalse);
    });
  });
}
