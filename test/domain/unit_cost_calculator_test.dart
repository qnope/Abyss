import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/unit_cost_calculator.dart';
import 'package:abyss/domain/unit_type.dart';

Resource _resource(ResourceType type, int amount) =>
    Resource(type: type, amount: amount);

Map<ResourceType, Resource> _resources({
  int algae = 100,
  int coral = 100,
  int ore = 100,
  int energy = 100,
  int pearl = 100,
}) => {
  ResourceType.algae: _resource(ResourceType.algae, algae),
  ResourceType.coral: _resource(ResourceType.coral, coral),
  ResourceType.ore: _resource(ResourceType.ore, ore),
  ResourceType.energy: _resource(ResourceType.energy, energy),
  ResourceType.pearl: _resource(ResourceType.pearl, pearl),
};

void main() {
  late UnitCostCalculator calculator;

  setUp(() => calculator = UnitCostCalculator());

  group('recruitmentCost', () {
    test('scout costs algae and coral', () {
      expect(calculator.recruitmentCost(UnitType.scout), {
        ResourceType.algae: 10,
        ResourceType.coral: 5,
      });
    });

    test('harpoonist costs algae, coral, ore', () {
      expect(calculator.recruitmentCost(UnitType.harpoonist), {
        ResourceType.algae: 15,
        ResourceType.coral: 10,
        ResourceType.ore: 5,
      });
    });

    test('guardian costs coral and ore', () {
      expect(calculator.recruitmentCost(UnitType.guardian), {
        ResourceType.coral: 20,
        ResourceType.ore: 15,
      });
    });

    test('domeBreaker costs ore and energy', () {
      expect(calculator.recruitmentCost(UnitType.domeBreaker), {
        ResourceType.ore: 25,
        ResourceType.energy: 15,
      });
    });

    test('siphoner costs algae, energy, pearl', () {
      expect(calculator.recruitmentCost(UnitType.siphoner), {
        ResourceType.algae: 20,
        ResourceType.energy: 10,
        ResourceType.pearl: 2,
      });
    });

    test('saboteur costs coral, energy, pearl', () {
      expect(calculator.recruitmentCost(UnitType.saboteur), {
        ResourceType.coral: 15,
        ResourceType.energy: 20,
        ResourceType.pearl: 3,
      });
    });
  });

  group('unlockLevel', () {
    test('scout requires barracks 1', () {
      expect(calculator.unlockLevel(UnitType.scout), 1);
    });

    test('harpoonist requires barracks 1', () {
      expect(calculator.unlockLevel(UnitType.harpoonist), 1);
    });

    test('guardian requires barracks 3', () {
      expect(calculator.unlockLevel(UnitType.guardian), 3);
    });

    test('domeBreaker requires barracks 3', () {
      expect(calculator.unlockLevel(UnitType.domeBreaker), 3);
    });

    test('siphoner requires barracks 5', () {
      expect(calculator.unlockLevel(UnitType.siphoner), 5);
    });

    test('saboteur requires barracks 5', () {
      expect(calculator.unlockLevel(UnitType.saboteur), 5);
    });
  });

  group('isUnlocked', () {
    test('scout at barracks 1 is unlocked', () {
      expect(calculator.isUnlocked(UnitType.scout, 1), isTrue);
    });

    test('scout at barracks 0 is locked', () {
      expect(calculator.isUnlocked(UnitType.scout, 0), isFalse);
    });

    test('guardian at barracks 2 is locked', () {
      expect(calculator.isUnlocked(UnitType.guardian, 2), isFalse);
    });

    test('guardian at barracks 3 is unlocked', () {
      expect(calculator.isUnlocked(UnitType.guardian, 3), isTrue);
    });
  });

  group('maxRecruitableCount', () {
    test('scout with 100 algae 50 coral barracks 1', () {
      final res = _resources(algae: 100, coral: 50);
      expect(calculator.maxRecruitableCount(UnitType.scout, 1, res), 10);
    });

    test('scout with 100 algae 50 coral barracks 5', () {
      final res = _resources(algae: 100, coral: 50);
      expect(calculator.maxRecruitableCount(UnitType.scout, 5, res), 10);
    });

    test('scout with 5 algae 5 coral returns 0', () {
      final res = _resources(algae: 5, coral: 5);
      expect(calculator.maxRecruitableCount(UnitType.scout, 1, res), 0);
    });

    test('capped by barracks level', () {
      final res = _resources(algae: 5000, coral: 5000);
      expect(calculator.maxRecruitableCount(UnitType.scout, 1, res), 100);
    });
  });
}
