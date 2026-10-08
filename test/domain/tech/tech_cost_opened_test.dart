import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_cost_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';

void main() {
  group('opened branches surcharge', () {
    test('counts only the unlocked branches', () {
      expect(TechCostCalculator.openedBranches(techBranchesWith(const [])), 0);
      expect(
        TechCostCalculator.openedBranches(techBranchesWith([
          researchedBranch(TechBranch.military, 0),
          researchedBranch(TechBranch.explorer, 3),
        ])),
        2,
      );
    });

    test('+50% per branch opened beyond the first', () {
      expect(TechCostCalculator.costPercent(0), 100);
      expect(TechCostCalculator.costPercent(1), 100);
      expect(TechCostCalculator.costPercent(2), 150);
      expect(TechCostCalculator.costPercent(3), 200);
    });

    test('the first unlock is at full price, the next ones cost more', () {
      const b = TechBranch.military;
      expect(TechCostCalculator.unlockCost(b, opened: 0),
          {ResourceType.ore: 30, ResourceType.energy: 20});
      expect(TechCostCalculator.unlockCost(b, opened: 1),
          {ResourceType.ore: 45, ResourceType.energy: 30});
      expect(TechCostCalculator.unlockCost(b, opened: 2),
          {ResourceType.ore: 60, ResourceType.energy: 40});
    });

    test('research scales with the opened branches', () {
      const b = TechBranch.resources;
      expect(TechCostCalculator.researchCost(b, 1, opened: 2),
          {ResourceType.coral: 120, ResourceType.algae: 75});
      expect(TechCostCalculator.researchCost(b, 1, opened: 3),
          {ResourceType.coral: 160, ResourceType.algae: 100});
    });

    test('pearls are never scaled', () {
      final cost =
          TechCostCalculator.researchCost(TechBranch.explorer, 5, opened: 3);
      expect(cost, {
        ResourceType.energy: 1048,
        ResourceType.ore: 656,
        ResourceType.pearl: 10,
      });
    });
  });
}
