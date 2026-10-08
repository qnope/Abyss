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
    test('HQ level 0->1: coral=60, ore=40', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 0);
      expect(cost[ResourceType.coral], 60);
      expect(cost[ResourceType.ore], 40);
    });

    test('HQ level 1->2: coral=96, ore=64', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 1);
      expect(cost[ResourceType.coral], 96);
      expect(cost[ResourceType.ore], 64);
    });

    test('HQ level 5->6: coral=629, ore=419', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 5);
      expect(cost[ResourceType.coral], 629);
      expect(cost[ResourceType.ore], 419);
    });

    test('HQ level 9->10: coral=4123, ore=2749', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 9);
      expect(cost[ResourceType.coral], 4123);
      expect(cost[ResourceType.ore], 2749);
    });

    test('HQ at max level 10: empty', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 10);
      expect(cost, isEmpty);
    });

    test('algaeFarm level 0->1: coral=80', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 0);
      expect(cost[ResourceType.coral], 80);
    });

    test('algaeFarm level 2->3: coral=205', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 2);
      expect(cost[ResourceType.coral], 205);
    });

    test('algaeFarm at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 5);
      expect(cost, isEmpty);
    });

    test('coralMine level 0->1: ore=60', () {
      final cost = calculator.upgradeCost(BuildingType.coralMine, 0);
      expect(cost[ResourceType.ore], 60);
    });

    test('coralMine level 3->4: ore=246', () {
      final cost = calculator.upgradeCost(BuildingType.coralMine, 3);
      expect(cost[ResourceType.ore], 246);
    });

    test('oreExtractor level 0->1: coral=75, energy=45', () {
      final cost = calculator.upgradeCost(BuildingType.oreExtractor, 0);
      expect(cost[ResourceType.coral], 75);
      expect(cost[ResourceType.energy], 45);
    });

    test('oreExtractor level 1->2: coral=120, energy=72', () {
      final cost = calculator.upgradeCost(BuildingType.oreExtractor, 1);
      expect(cost[ResourceType.coral], 120);
      expect(cost[ResourceType.energy], 72);
    });

    test('solarPanel level 0->1: coral=60, ore=45', () {
      final cost = calculator.upgradeCost(BuildingType.solarPanel, 0);
      expect(cost[ResourceType.coral], 60);
      expect(cost[ResourceType.ore], 45);
    });

    test('solarPanel level 4->5: coral=393, ore=295', () {
      final cost = calculator.upgradeCost(BuildingType.solarPanel, 4);
      expect(cost[ResourceType.coral], 393);
      expect(cost[ResourceType.ore], 295);
    });

    test('laboratory level 0->1: coral=75, ore=60', () {
      final cost = calculator.upgradeCost(BuildingType.laboratory, 0);
      expect(cost[ResourceType.coral], 75);
      expect(cost[ResourceType.ore], 60);
    });

    test('laboratory at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.laboratory, 5);
      expect(cost, isEmpty);
    });

    test('barracks level 0->1: coral=60, ore=75, energy=30', () {
      final cost = calculator.upgradeCost(BuildingType.barracks, 0);
      expect(cost[ResourceType.coral], 60);
      expect(cost[ResourceType.ore], 75);
      expect(cost[ResourceType.energy], 30);
    });

    test('barracks at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.barracks, 5);
      expect(cost, isEmpty);
    });

    test('every level costs 1.6 times the previous one', () {
      for (var level = 1; level < 5; level++) {
        final previous = calculator.upgradeCost(
          BuildingType.coralMine,
          level - 1,
        );
        final cost = calculator.upgradeCost(BuildingType.coralMine, level);
        expect(
          cost[ResourceType.ore]! / previous[ResourceType.ore]!,
          closeTo(1.6, 0.02),
        );
      }
    });
  });

  group('coralCitadel', () {
    test('level 0->1: coral=250, ore=250, energy=125, pearl=5', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 0);
      expect(cost[ResourceType.coral], 250);
      expect(cost[ResourceType.ore], 250);
      expect(cost[ResourceType.energy], 125);
      expect(cost[ResourceType.pearl], 5);
    });

    test('level 1->2: coral=400, ore=400, energy=200, pearl=10', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 1);
      expect(cost[ResourceType.coral], 400);
      expect(cost[ResourceType.ore], 400);
      expect(cost[ResourceType.energy], 200);
      expect(cost[ResourceType.pearl], 10);
    });

    test('level 2->3: coral=640, ore=640, energy=320, pearl=20', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 2);
      expect(cost[ResourceType.coral], 640);
      expect(cost[ResourceType.ore], 640);
      expect(cost[ResourceType.energy], 320);
      expect(cost[ResourceType.pearl], 20);
    });

    test('level 3->4: coral=1024, ore=1024, energy=512, pearl=35', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 3);
      expect(cost[ResourceType.coral], 1024);
      expect(cost[ResourceType.ore], 1024);
      expect(cost[ResourceType.energy], 512);
      expect(cost[ResourceType.pearl], 35);
    });

    test('level 4->5: coral=1638, ore=1638, energy=819, pearl=60', () {
      final cost = calculator.upgradeCost(BuildingType.coralCitadel, 4);
      expect(cost[ResourceType.coral], 1638);
      expect(cost[ResourceType.ore], 1638);
      expect(cost[ResourceType.energy], 819);
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
      final prereqs = calculator.prerequisites(BuildingType.pressureCapsule, 1);
      expect(prereqs, {BuildingType.headquarters: 8});
    });
  });

  group('volcanicKernel', () {
    test('level 0->1: coral=50, ore=40, energy=12, pearl=8', () {
      final cost = calculator.upgradeCost(BuildingType.volcanicKernel, 0);
      expect(cost[ResourceType.coral], 50);
      expect(cost[ResourceType.ore], 40);
      expect(cost[ResourceType.energy], 12);
      expect(cost[ResourceType.pearl], 8);
    });

    test('at max level 10: returns empty map', () {
      final cost = calculator.upgradeCost(BuildingType.volcanicKernel, 10);
      expect(cost, isEmpty);
    });

    test('prerequisites at level 1: HQ 10', () {
      final prereqs = calculator.prerequisites(BuildingType.volcanicKernel, 1);
      expect(prereqs, {BuildingType.headquarters: 10});
    });

    test('prerequisites at level 5: HQ 10', () {
      final prereqs = calculator.prerequisites(BuildingType.volcanicKernel, 5);
      expect(prereqs, {BuildingType.headquarters: 10});
    });
  });

  group('requiresCapturedKernel', () {
    test('true for volcanicKernel', () {
      expect(
        calculator.requiresCapturedKernel(BuildingType.volcanicKernel),
        isTrue,
      );
    });

    test('false for headquarters', () {
      expect(
        calculator.requiresCapturedKernel(BuildingType.headquarters),
        isFalse,
      );
    });
  });

  group('checkUpgrade volcanicKernel', () {
    Map<ResourceType, Resource> abundant() => {
      ResourceType.coral: Resource(type: ResourceType.coral, amount: 99999),
      ResourceType.ore: Resource(type: ResourceType.ore, amount: 99999),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: 99999),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 99999),
    };

    test('kernel not captured returns canUpgrade false', () {
      final result = calculator.checkUpgrade(
        type: BuildingType.volcanicKernel,
        currentLevel: 0,
        resources: abundant(),
        allBuildings: {
          BuildingType.headquarters: Building(
            type: BuildingType.headquarters,
            level: 10,
          ),
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
          BuildingType.headquarters: Building(
            type: BuildingType.headquarters,
            level: 10,
          ),
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
          BuildingType.headquarters: Building(
            type: BuildingType.headquarters,
            level: 9,
          ),
        },
        isVolcanicKernelCaptured: true,
      );
      expect(result.canUpgrade, isFalse);
      expect(result.missingPrerequisites, {BuildingType.headquarters: 10});
      expect(result.missingCapturedKernel, isFalse);
    });
  });
}
