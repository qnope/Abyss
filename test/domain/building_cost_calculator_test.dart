import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_cost_calculator.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';

void main() {
  late BuildingCostCalculator calculator;

  setUp(() {
    calculator = BuildingCostCalculator();
  });

  group('upgradeCost', () {
    test('HQ level 0->1: coral=30, ore=20', () {
      final cost = calculator.upgradeCost(
        BuildingType.headquarters,
        0,
      );
      expect(cost[ResourceType.coral], 30);
      expect(cost[ResourceType.ore], 20);
    });

    test('HQ level 1->2: coral=60, ore=40', () {
      final cost = calculator.upgradeCost(
        BuildingType.headquarters,
        1,
      );
      expect(cost[ResourceType.coral], 60);
      expect(cost[ResourceType.ore], 40);
    });

    test('HQ level 5->6: coral=780, ore=520', () {
      final cost = calculator.upgradeCost(
        BuildingType.headquarters,
        5,
      );
      expect(cost[ResourceType.coral], 780);
      expect(cost[ResourceType.ore], 520);
    });

    test('HQ level 9->10: coral=2460, ore=1640', () {
      final cost = calculator.upgradeCost(
        BuildingType.headquarters,
        9,
      );
      expect(cost[ResourceType.coral], 2460);
      expect(cost[ResourceType.ore], 1640);
    });

    test('HQ at max level (10): returns empty map', () {
      final cost = calculator.upgradeCost(
        BuildingType.headquarters,
        10,
      );
      expect(cost, isEmpty);
    });
  });

  group('maxLevel', () {
    test('HQ is 10', () {
      expect(calculator.maxLevel(BuildingType.headquarters), 10);
    });
  });

  group('prerequisites', () {
    test('HQ has no prerequisites', () {
      final prereqs = calculator.prerequisites(
        BuildingType.headquarters,
        1,
      );
      expect(prereqs, isEmpty);
    });
  });

  group('checkUpgrade', () {
    test('can upgrade when resources sufficient', () {
      final resources = {
        ResourceType.coral: Resource(
          type: ResourceType.coral,
          amount: 100,
        ),
        ResourceType.ore: Resource(
          type: ResourceType.ore,
          amount: 100,
        ),
      };
      final buildings = [
        Building(type: BuildingType.headquarters, level: 0),
      ];

      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: resources,
        allBuildings: buildings,
      );

      expect(result.canUpgrade, isTrue);
      expect(result.isMaxLevel, isFalse);
      expect(result.missingResources, isEmpty);
      expect(result.missingPrerequisites, isEmpty);
    });

    test('cannot upgrade when coral insufficient', () {
      final resources = {
        ResourceType.coral: Resource(
          type: ResourceType.coral,
          amount: 10,
        ),
        ResourceType.ore: Resource(
          type: ResourceType.ore,
          amount: 100,
        ),
      };
      final buildings = [
        Building(type: BuildingType.headquarters, level: 0),
      ];

      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: resources,
        allBuildings: buildings,
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingResources[ResourceType.coral], 20);
    });

    test('cannot upgrade when ore insufficient', () {
      final resources = {
        ResourceType.coral: Resource(
          type: ResourceType.coral,
          amount: 100,
        ),
        ResourceType.ore: Resource(
          type: ResourceType.ore,
          amount: 5,
        ),
      };
      final buildings = [
        Building(type: BuildingType.headquarters, level: 0),
      ];

      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: resources,
        allBuildings: buildings,
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingResources[ResourceType.ore], 15);
    });

    test('cannot upgrade at max level (isMaxLevel=true)', () {
      final resources = {
        ResourceType.coral: Resource(
          type: ResourceType.coral,
          amount: 10000,
        ),
        ResourceType.ore: Resource(
          type: ResourceType.ore,
          amount: 10000,
        ),
      };
      final buildings = [
        Building(type: BuildingType.headquarters, level: 10),
      ];

      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 10,
        resources: resources,
        allBuildings: buildings,
      );

      expect(result.canUpgrade, isFalse);
      expect(result.isMaxLevel, isTrue);
    });

    test('canUpgrade false when both resources insufficient',
        () {
      final resources = {
        ResourceType.coral: Resource(
          type: ResourceType.coral,
          amount: 0,
        ),
        ResourceType.ore: Resource(
          type: ResourceType.ore,
          amount: 0,
        ),
      };
      final buildings = <Building>[];

      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: resources,
        allBuildings: buildings,
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingResources[ResourceType.coral], 30);
      expect(result.missingResources[ResourceType.ore], 20);
    });
  });
}
