import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/production_calculator.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';

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

    test('solarPanel at level 4 produces 198 energy', () {
      final buildings = {
        BuildingType.solarPanel: Building(
          type: BuildingType.solarPanel,
          level: 4,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.energy: 198});
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
        ResourceType.energy: 54,
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

  group('with tech branches', () {
    final buildings = {
      BuildingType.algaeFarm: Building(
        type: BuildingType.algaeFarm,
        level: 1,
      ),
    };
    // algaeFarm level 1 = 30*1 + 20 = 50

    test('no tech branches (null) returns same as before', () {
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.algae: 50});
    });

    test('resources branch level 1 applies 1.2x multiplier', () {
      final branches = {
        TechBranch.resources: TechBranchState(
          branch: TechBranch.resources,
          unlocked: true,
          researchLevel: 1,
        ),
      };
      final production = ProductionCalculator.fromBuildings(
        buildings,
        techBranches: branches,
      );
      // 50 * 1.2 = 60
      expect(production, {ResourceType.algae: 60});
    });

    test('resources branch level 5 applies 2.0x multiplier', () {
      final branches = {
        TechBranch.resources: TechBranchState(
          branch: TechBranch.resources,
          unlocked: true,
          researchLevel: 5,
        ),
      };
      final production = ProductionCalculator.fromBuildings(
        buildings,
        techBranches: branches,
      );
      // 50 * 2.0 = 100
      expect(production, {ResourceType.algae: 100});
    });

    test('military branch level 3 has no effect on production', () {
      final branches = {
        TechBranch.military: TechBranchState(
          branch: TechBranch.military,
          unlocked: true,
          researchLevel: 3,
        ),
      };
      final production = ProductionCalculator.fromBuildings(
        buildings,
        techBranches: branches,
      );
      expect(production, {ResourceType.algae: 50});
    });

    test('unlocked but level 0 has no effect', () {
      final branches = {
        TechBranch.resources: TechBranchState(
          branch: TechBranch.resources,
          unlocked: true,
          researchLevel: 0,
        ),
      };
      final production = ProductionCalculator.fromBuildings(
        buildings,
        techBranches: branches,
      );
      expect(production, {ResourceType.algae: 50});
    });
  });
}
