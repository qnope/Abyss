import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_cost_calculator.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  late BuildingCostCalculator calculator;

  setUp(() {
    calculator = BuildingCostCalculator();
  });

  group('upgradeCost', () {
    test('HQ level 0->1: coral=30, ore=20', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 0);
      expect(cost[ResourceType.coral], 30);
      expect(cost[ResourceType.ore], 20);
    });

    test('HQ level 1->2: coral=60, ore=40', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 1);
      expect(cost[ResourceType.coral], 60);
      expect(cost[ResourceType.ore], 40);
    });

    test('HQ level 5->6: coral=780, ore=520', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 5);
      expect(cost[ResourceType.coral], 780);
      expect(cost[ResourceType.ore], 520);
    });

    test('HQ level 9->10: coral=2460, ore=1640', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 9);
      expect(cost[ResourceType.coral], 2460);
      expect(cost[ResourceType.ore], 1640);
    });

    test('HQ at max level (10): returns empty map', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 10);
      expect(cost, isEmpty);
    });

    test('algaeFarm level 0->1: coral=20', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 0);
      expect(cost[ResourceType.coral], 20);
    });

    test('algaeFarm level 2->3: coral=100', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 2);
      expect(cost[ResourceType.coral], 100);
    });

    test('algaeFarm at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 5);
      expect(cost, isEmpty);
    });

    test('coralMine level 0->1: ore=15', () {
      final cost = calculator.upgradeCost(BuildingType.coralMine, 0);
      expect(cost[ResourceType.ore], 15);
    });

    test('coralMine level 3->4: ore=150', () {
      final cost = calculator.upgradeCost(BuildingType.coralMine, 3);
      expect(cost[ResourceType.ore], 150);
    });

    test('oreExtractor level 0->1: coral=25, energy=15', () {
      final cost = calculator.upgradeCost(BuildingType.oreExtractor, 0);
      expect(cost[ResourceType.coral], 25);
      expect(cost[ResourceType.energy], 15);
    });

    test('oreExtractor level 1->2: coral=50, energy=30', () {
      final cost = calculator.upgradeCost(BuildingType.oreExtractor, 1);
      expect(cost[ResourceType.coral], 50);
      expect(cost[ResourceType.energy], 30);
    });

    test('solarPanel level 0->1: coral=20, ore=15', () {
      final cost = calculator.upgradeCost(BuildingType.solarPanel, 0);
      expect(cost[ResourceType.coral], 20);
      expect(cost[ResourceType.ore], 15);
    });

    test('solarPanel level 4->5: coral=340, ore=255', () {
      final cost = calculator.upgradeCost(BuildingType.solarPanel, 4);
      expect(cost[ResourceType.coral], 340);
      expect(cost[ResourceType.ore], 255);
    });

    test('laboratory level 0->1: coral=25, ore=20', () {
      final cost = calculator.upgradeCost(BuildingType.laboratory, 0);
      expect(cost[ResourceType.coral], 25);
      expect(cost[ResourceType.ore], 20);
    });

    test('laboratory at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.laboratory, 5);
      expect(cost, isEmpty);
    });

    test('barracks level 0->1: coral=20, ore=25, energy=10', () {
      final cost = calculator.upgradeCost(BuildingType.barracks, 0);
      expect(cost[ResourceType.coral], 20);
      expect(cost[ResourceType.ore], 25);
      expect(cost[ResourceType.energy], 10);
    });

    test('barracks at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.barracks, 5);
      expect(cost, isEmpty);
    });
  });

  group('coralCitadel', () {
    test('level 0->1: coral=120, ore=120, energy=60, pearl=5', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 0);
      expect(cost[ResourceType.coral], 120);
      expect(cost[ResourceType.ore], 120);
      expect(cost[ResourceType.energy], 60);
      expect(cost[ResourceType.pearl], 5);
    });

    test('level 1->2: coral=240, ore=240, energy=120, pearl=10', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 1);
      expect(cost[ResourceType.coral], 240);
      expect(cost[ResourceType.ore], 240);
      expect(cost[ResourceType.energy], 120);
      expect(cost[ResourceType.pearl], 10);
    });

    test('level 2->3: coral=500, ore=500, energy=250, pearl=20', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 2);
      expect(cost[ResourceType.coral], 500);
      expect(cost[ResourceType.ore], 500);
      expect(cost[ResourceType.energy], 250);
      expect(cost[ResourceType.pearl], 20);
    });

    test('level 3->4: coral=850, ore=850, energy=425, pearl=35', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 3);
      expect(cost[ResourceType.coral], 850);
      expect(cost[ResourceType.ore], 850);
      expect(cost[ResourceType.energy], 425);
      expect(cost[ResourceType.pearl], 35);
    });

    test('level 4->5: coral=1300, ore=1300, energy=650, pearl=60', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 4);
      expect(cost[ResourceType.coral], 1300);
      expect(cost[ResourceType.ore], 1300);
      expect(cost[ResourceType.energy], 650);
      expect(cost[ResourceType.pearl], 60);
    });

    test('at max level 5: returns empty map', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 5);
      expect(cost, isEmpty);
    });
  });

  group('maxLevel', () {
    test('HQ is 10', () {
      expect(calculator.maxLevel(BuildingType.headquarters), 10);
    });

    test('algaeFarm is 5', () {
      expect(calculator.maxLevel(BuildingType.algaeFarm), 5);
    });

    test('coralMine is 5', () {
      expect(calculator.maxLevel(BuildingType.coralMine), 5);
    });

    test('oreExtractor is 5', () {
      expect(calculator.maxLevel(BuildingType.oreExtractor), 5);
    });

    test('solarPanel is 5', () {
      expect(calculator.maxLevel(BuildingType.solarPanel), 5);
    });

    test('laboratory is 5', () {
      expect(calculator.maxLevel(BuildingType.laboratory), 5);
    });

    test('barracks is 5', () {
      expect(calculator.maxLevel(BuildingType.barracks), 5);
    });

    test('coralCitadel is 5', () {
      expect(calculator.maxLevel(BuildingType.coralCitadel), 5);
    });

    test('descentModule is 1', () {
      expect(calculator.maxLevel(BuildingType.descentModule), 1);
    });

    test('pressureCapsule is 1', () {
      expect(calculator.maxLevel(BuildingType.pressureCapsule), 1);
    });

    test('volcanicKernel is 10', () {
      expect(calculator.maxLevel(BuildingType.volcanicKernel), 10);
    });
  });

  group('descentModule', () {
    test('level 0->1: coral=200, ore=150, energy=80, pearl=5', () {
      final cost = calculator.upgradeCost(BuildingType.descentModule, 0);
      expect(cost[ResourceType.coral], 200);
      expect(cost[ResourceType.ore], 150);
      expect(cost[ResourceType.energy], 80);
      expect(cost[ResourceType.pearl], 5);
    });

    test('at max level 1: returns empty map', () {
      final cost = calculator.upgradeCost(BuildingType.descentModule, 1);
      expect(cost, isEmpty);
    });

    test('prerequisites: HQ level 5', () {
      final prereqs = calculator.prerequisites(BuildingType.descentModule, 1);
      expect(prereqs, {BuildingType.headquarters: 5});
    });
  });

  group('pressureCapsule', () {
    test('level 0->1: coral=400, ore=300, energy=150, pearl=15', () {
      final cost = calculator.upgradeCost(BuildingType.pressureCapsule, 0);
      expect(cost[ResourceType.coral], 400);
      expect(cost[ResourceType.ore], 300);
      expect(cost[ResourceType.energy], 150);
      expect(cost[ResourceType.pearl], 15);
    });

    test('at max level 1: returns empty map', () {
      final cost = calculator.upgradeCost(BuildingType.pressureCapsule, 1);
      expect(cost, isEmpty);
    });

    test('prerequisites: HQ level 8', () {
      final prereqs = calculator.prerequisites(
        BuildingType.pressureCapsule,
        1,
      );
      expect(prereqs, {BuildingType.headquarters: 8});
    });
  });

  group('volcanicKernel', () {
    test('level 0->1: coral=50, ore=40, energy=30, pearl=8', () {
      final cost = calculator.upgradeCost(BuildingType.volcanicKernel, 0);
      expect(cost[ResourceType.coral], 50);
      expect(cost[ResourceType.ore], 40);
      expect(cost[ResourceType.energy], 30);
      expect(cost[ResourceType.pearl], 8);
    });

    test('at max level 10: returns empty map', () {
      final cost = calculator.upgradeCost(BuildingType.volcanicKernel, 10);
      expect(cost, isEmpty);
    });

    test('prerequisites at level 1: HQ 10', () {
      final prereqs = calculator.prerequisites(
        BuildingType.volcanicKernel,
        1,
      );
      expect(prereqs, {BuildingType.headquarters: 10});
    });

    test('prerequisites at level 5: HQ 10', () {
      final prereqs = calculator.prerequisites(
        BuildingType.volcanicKernel,
        5,
      );
      expect(prereqs, {BuildingType.headquarters: 10});
    });
  });

  group('requiresCapturedKernel', () {
    test('true for volcanicKernel', () {
      expect(calculator.requiresCapturedKernel(BuildingType.volcanicKernel),
          isTrue);
    });

    test('false for headquarters', () {
      expect(calculator.requiresCapturedKernel(BuildingType.headquarters),
          isFalse);
    });
  });

  group('checkUpgrade volcanicKernel', () {
    Map<ResourceType, Resource> abundant() => {
          ResourceType.coral: Resource(
              type: ResourceType.coral, amount: 99999),
          ResourceType.ore: Resource(
              type: ResourceType.ore, amount: 99999),
          ResourceType.energy: Resource(
              type: ResourceType.energy, amount: 99999),
          ResourceType.pearl: Resource(
              type: ResourceType.pearl, amount: 99999),
        };

    test('kernel not captured returns canUpgrade false', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.volcanicKernel,
        currentLevel: 0,
        resources: abundant(),
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 10),
        },
        isVolcanicKernelCaptured: false,
      );
      expect(result.canUpgrade, isFalse);
      expect(result.missingCapturedKernel, isTrue);
    });

    test('kernel captured + HQ 10 + resources returns canUpgrade true', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.volcanicKernel,
        currentLevel: 0,
        resources: abundant(),
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 10),
        },
        isVolcanicKernelCaptured: true,
      );
      expect(result.canUpgrade, isTrue);
      expect(result.missingCapturedKernel, isFalse);
    });

    test('kernel captured but HQ < 10 returns canUpgrade false', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.volcanicKernel,
        currentLevel: 0,
        resources: abundant(),
        allBuildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 9),
        },
        isVolcanicKernelCaptured: true,
      );
      expect(result.canUpgrade, isFalse);
      expect(result.missingPrerequisites, {BuildingType.headquarters: 10});
      expect(result.missingCapturedKernel, isFalse);
    });
  });
}
