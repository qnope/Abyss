import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_cost_calculator.dart';

void main() {
  group('unlockCost', () {
    test('military costs ore 30 and energy 20', () {
      final cost = TechCostCalculator.unlockCost(TechBranch.military);
      expect(cost, {ResourceType.ore: 30, ResourceType.energy: 20});
    });

    test('resources costs coral 30 and algae 20', () {
      final cost = TechCostCalculator.unlockCost(TechBranch.resources);
      expect(cost, {ResourceType.coral: 30, ResourceType.algae: 20});
    });

    test('explorer costs energy 30 and ore 20', () {
      final cost = TechCostCalculator.unlockCost(TechBranch.explorer);
      expect(cost, {ResourceType.energy: 30, ResourceType.ore: 20});
    });
  });

  group('researchCost', () {
    test('military levels 1-5', () {
      expect(TechCostCalculator.researchCost(TechBranch.military, 1),
          {ResourceType.ore: 40, ResourceType.energy: 25});
      expect(TechCostCalculator.researchCost(TechBranch.military, 2),
          {ResourceType.ore: 80, ResourceType.energy: 50});
      expect(TechCostCalculator.researchCost(TechBranch.military, 3),
          {ResourceType.ore: 150, ResourceType.energy: 90});
      expect(TechCostCalculator.researchCost(TechBranch.military, 4),
          {ResourceType.ore: 250, ResourceType.energy: 150, ResourceType.pearl: 5});
      expect(TechCostCalculator.researchCost(TechBranch.military, 5),
          {ResourceType.ore: 400, ResourceType.energy: 250, ResourceType.pearl: 10});
    });

    test('resources levels 1-5', () {
      expect(TechCostCalculator.researchCost(TechBranch.resources, 1),
          {ResourceType.coral: 40, ResourceType.algae: 25});
      expect(TechCostCalculator.researchCost(TechBranch.resources, 2),
          {ResourceType.coral: 80, ResourceType.algae: 50});
      expect(TechCostCalculator.researchCost(TechBranch.resources, 3),
          {ResourceType.coral: 150, ResourceType.algae: 90});
      expect(TechCostCalculator.researchCost(TechBranch.resources, 4),
          {ResourceType.coral: 250, ResourceType.algae: 150, ResourceType.pearl: 5});
      expect(TechCostCalculator.researchCost(TechBranch.resources, 5),
          {ResourceType.coral: 400, ResourceType.algae: 250, ResourceType.pearl: 10});
    });

    test('explorer levels 1-5', () {
      expect(TechCostCalculator.researchCost(TechBranch.explorer, 1),
          {ResourceType.energy: 40, ResourceType.ore: 25});
      expect(TechCostCalculator.researchCost(TechBranch.explorer, 2),
          {ResourceType.energy: 80, ResourceType.ore: 50});
      expect(TechCostCalculator.researchCost(TechBranch.explorer, 3),
          {ResourceType.energy: 150, ResourceType.ore: 90});
      expect(TechCostCalculator.researchCost(TechBranch.explorer, 4),
          {ResourceType.energy: 250, ResourceType.ore: 150, ResourceType.pearl: 5});
      expect(TechCostCalculator.researchCost(TechBranch.explorer, 5),
          {ResourceType.energy: 400, ResourceType.ore: 250, ResourceType.pearl: 10});
    });

    test('pearl is included only at levels 4 and 5', () {
      for (final branch in TechBranch.values) {
        for (int level = 1; level <= 3; level++) {
          final cost = TechCostCalculator.researchCost(branch, level);
          expect(cost.containsKey(ResourceType.pearl), isFalse,
              reason: '$branch level $level should not have pearl');
        }
        for (int level = 4; level <= 5; level++) {
          final cost = TechCostCalculator.researchCost(branch, level);
          expect(cost.containsKey(ResourceType.pearl), isTrue,
              reason: '$branch level $level should have pearl');
        }
      }
    });
  });

  group('requiredLabLevel', () {
    test('levels 1-5 return the same value', () {
      expect(TechCostCalculator.requiredLabLevel(1), 1);
      expect(TechCostCalculator.requiredLabLevel(2), 2);
      expect(TechCostCalculator.requiredLabLevel(3), 3);
      expect(TechCostCalculator.requiredLabLevel(4), 4);
      expect(TechCostCalculator.requiredLabLevel(5), 5);
    });
  });
}
