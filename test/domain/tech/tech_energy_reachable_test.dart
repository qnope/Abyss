import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_cost_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every research and unlock fits in the energy storage', () {
    final cap = Player(name: 'A').resources[ResourceType.energy]!.maxStorage;
    for (final branch in TechBranch.values) {
      for (var level = 1; level <= TechCostCalculator.maxResearchLevel;
          level++) {
        final cost = TechCostCalculator.researchCost(branch, level, opened: 3);
        expect(cost[ResourceType.energy] ?? 0, lessThanOrEqualTo(cap),
            reason: '$branch level $level');
      }
      final unlock = TechCostCalculator.unlockCost(branch, opened: 2);
      expect(unlock[ResourceType.energy] ?? 0, lessThanOrEqualTo(cap));
    }
  });
}
