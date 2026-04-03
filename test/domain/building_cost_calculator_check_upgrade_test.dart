import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_cost_calculator.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';

Resource _resource(ResourceType type, int amount) =>
    Resource(type: type, amount: amount);

void main() {
  late BuildingCostCalculator calculator;

  setUp(() {
    calculator = BuildingCostCalculator();
  });

  group('checkUpgrade', () {
    test('can upgrade when resources sufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
          ResourceType.ore: _resource(ResourceType.ore, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 0),
        },
      );

      expect(result.canUpgrade, isTrue);
      expect(result.isMaxLevel, isFalse);
      expect(result.missingResources, isEmpty);
      expect(result.missingPrerequisites, isEmpty);
    });

    test('cannot upgrade when coral insufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 10),
          ResourceType.ore: _resource(ResourceType.ore, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 0),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingResources[ResourceType.coral], 20);
    });

    test('cannot upgrade when ore insufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
          ResourceType.ore: _resource(ResourceType.ore, 5),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 0),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingResources[ResourceType.ore], 15);
    });

    test('cannot upgrade at max level (isMaxLevel=true)', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 10,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 10000),
          ResourceType.ore: _resource(ResourceType.ore, 10000),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 10),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.isMaxLevel, isTrue);
    });

    test('canUpgrade false when both resources insufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.headquarters,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 0),
          ResourceType.ore: _resource(ResourceType.ore, 0),
        },
        allBuildings: <BuildingType, Building>{},
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingResources[ResourceType.coral], 30);
      expect(result.missingResources[ResourceType.ore], 20);
    });

    test('cannot upgrade algaeFarm when HQ prerequisite not met', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.algaeFarm,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 0),
          BuildingType.algaeFarm:
              Building(type: BuildingType.algaeFarm, level: 0),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingPrerequisites[BuildingType.headquarters], 1);
    });

    test('can upgrade algaeFarm when HQ and resources sufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.algaeFarm,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 1),
          BuildingType.algaeFarm:
              Building(type: BuildingType.algaeFarm, level: 0),
        },
      );

      expect(result.canUpgrade, isTrue);
    });
  });
}
