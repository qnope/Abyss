import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/production_calculator.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';

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

    test('algaeFarm at level 3 produces 230 algae', () {
      final buildings = {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 3,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.algae: 230});
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

    test('solarPanel at level 4 produces 126 energy', () {
      final buildings = {
        BuildingType.solarPanel: Building(
          type: BuildingType.solarPanel,
          level: 4,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.energy: 126});
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
        ResourceType.coral: 160,
        ResourceType.ore: 30,
        ResourceType.energy: 54,
      });
    });

    test('a built headquarters gives the same flat income at any level', () {
      for (final level in [1, 5, 10]) {
        final buildings = {
          BuildingType.headquarters: Building(
            type: BuildingType.headquarters,
            level: level,
          ),
        };
        final production = ProductionCalculator.fromBuildings(buildings);
        expect(production, {ResourceType.coral: 15, ResourceType.ore: 10});
      }
    });

    test('headquarters income adds to the buildings production', () {
      final buildings = {
        BuildingType.headquarters: Building(
          type: BuildingType.headquarters,
          level: 2,
        ),
        BuildingType.coralMine: Building(
          type: BuildingType.coralMine,
          level: 1,
        ),
      };
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.coral: 55, ResourceType.ore: 10});
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
    // algaeFarm level 1 = 90*1 - 40 = 50

    test('no tech branches (null) returns same as before', () {
      final production = ProductionCalculator.fromBuildings(buildings);
      expect(production, {ResourceType.algae: 50});
    });

    test('resources branch level 1 (one tier) applies +20%', () {
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

    test('level 5 with Culture intensive applies +95% on algae', () {
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
      // 3 tiers (+60%) + Culture intensive (+35%), option A by default:
      // 50 * 1.95 = 97
      expect(production, {ResourceType.algae: 97});
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
