import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_cost_calculator.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';

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

    test('cannot upgrade laboratory when HQ prerequisite not met', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.laboratory,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
          ResourceType.ore: _resource(ResourceType.ore, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 1),
          BuildingType.laboratory:
              Building(type: BuildingType.laboratory, level: 0),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingPrerequisites[BuildingType.headquarters], 2);
    });

    test('can upgrade laboratory when HQ and resources sufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.laboratory,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
          ResourceType.ore: _resource(ResourceType.ore, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 2),
          BuildingType.laboratory:
              Building(type: BuildingType.laboratory, level: 0),
        },
      );

      expect(result.canUpgrade, isTrue);
    });

    test('cannot upgrade barracks when HQ prerequisite not met', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.barracks,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
          ResourceType.ore: _resource(ResourceType.ore, 100),
          ResourceType.energy: _resource(ResourceType.energy, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 2),
          BuildingType.barracks:
              Building(type: BuildingType.barracks, level: 0),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingPrerequisites[BuildingType.headquarters], 3);
    });

    test('can upgrade barracks when HQ and resources sufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.barracks,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 100),
          ResourceType.ore: _resource(ResourceType.ore, 100),
          ResourceType.energy: _resource(ResourceType.energy, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 3),
          BuildingType.barracks:
              Building(type: BuildingType.barracks, level: 0),
        },
      );

      expect(result.canUpgrade, isTrue);
    });

    test('cannot upgrade coralCitadel when pearls insufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.coralCitadel,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 1000),
          ResourceType.ore: _resource(ResourceType.ore, 1000),
          ResourceType.energy: _resource(ResourceType.energy, 1000),
          ResourceType.pearl: _resource(ResourceType.pearl, 2),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 3),
          BuildingType.coralCitadel:
              Building(type: BuildingType.coralCitadel, level: 0),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingResources[ResourceType.pearl], 3);
    });

    test('cannot upgrade coralCitadel when HQ prerequisite not met', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.coralCitadel,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 1000),
          ResourceType.ore: _resource(ResourceType.ore, 1000),
          ResourceType.energy: _resource(ResourceType.energy, 1000),
          ResourceType.pearl: _resource(ResourceType.pearl, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 2),
          BuildingType.coralCitadel:
              Building(type: BuildingType.coralCitadel, level: 0),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.missingPrerequisites[BuildingType.headquarters], 3);
    });

    test('can upgrade coralCitadel when HQ and resources sufficient', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.coralCitadel,
        currentLevel: 0,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 1000),
          ResourceType.ore: _resource(ResourceType.ore, 1000),
          ResourceType.energy: _resource(ResourceType.energy, 1000),
          ResourceType.pearl: _resource(ResourceType.pearl, 100),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 3),
          BuildingType.coralCitadel:
              Building(type: BuildingType.coralCitadel, level: 0),
        },
      );

      expect(result.canUpgrade, isTrue);
      expect(result.missingResources, isEmpty);
      expect(result.missingPrerequisites, isEmpty);
    });

    test('cannot upgrade coralCitadel at max level (isMaxLevel=true)', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.coralCitadel,
        currentLevel: 5,
        resources: {
          ResourceType.coral: _resource(ResourceType.coral, 10000),
          ResourceType.ore: _resource(ResourceType.ore, 10000),
          ResourceType.energy: _resource(ResourceType.energy, 10000),
          ResourceType.pearl: _resource(ResourceType.pearl, 1000),
        },
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 10),
          BuildingType.coralCitadel:
              Building(type: BuildingType.coralCitadel, level: 5),
        },
      );

      expect(result.canUpgrade, isFalse);
      expect(result.isMaxLevel, isTrue);
    });
  });
}
