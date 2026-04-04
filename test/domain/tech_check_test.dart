import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';
import 'package:abyss/domain/tech_cost_calculator.dart';

Map<ResourceType, Resource> _richResources() => {
      ResourceType.ore: Resource(type: ResourceType.ore, amount: 500),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: 500),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: 500),
      ResourceType.algae: Resource(type: ResourceType.algae, amount: 500),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 50),
    };

Map<TechBranch, TechBranchState> _lockedBranches() => {
      for (final b in TechBranch.values)
        b: TechBranchState(branch: b),
    };

void main() {
  group('checkUnlock', () {
    test('success when lab level 1, branch locked, resources sufficient', () {
      final result = TechCostCalculator.checkUnlock(
        branch: TechBranch.military,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 1)},
        techBranches: _lockedBranches(),
      );
      expect(result.canAct, isTrue);
    });

    test('fail when lab level 0', () {
      final result = TechCostCalculator.checkUnlock(
        branch: TechBranch.military,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 0)},
        techBranches: _lockedBranches(),
      );
      expect(result.canAct, isFalse);
      expect(result.currentLabLevel, 0);
    });

    test('fail when branch already unlocked', () {
      final branches = _lockedBranches();
      branches[TechBranch.military]!.unlocked = true;
      final result = TechCostCalculator.checkUnlock(
        branch: TechBranch.military,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 1)},
        techBranches: branches,
      );
      expect(result.canAct, isFalse);
    });

    test('fail when insufficient resources', () {
      final poor = {
        ResourceType.ore: Resource(type: ResourceType.ore, amount: 0),
        ResourceType.energy: Resource(type: ResourceType.energy, amount: 0),
      };
      final result = TechCostCalculator.checkUnlock(
        branch: TechBranch.military,
        resources: poor,
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 1)},
        techBranches: _lockedBranches(),
      );
      expect(result.canAct, isFalse);
      expect(result.missingResources, isNotEmpty);
    });
  });

  group('checkResearch', () {
    test('success: branch unlocked, level 0 to 1, lab level 1', () {
      final branches = _lockedBranches();
      branches[TechBranch.military]!.unlocked = true;
      final result = TechCostCalculator.checkResearch(
        branch: TechBranch.military,
        targetLevel: 1,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 1)},
        techBranches: branches,
      );
      expect(result.canAct, isTrue);
    });

    test('fail when branch locked', () {
      final result = TechCostCalculator.checkResearch(
        branch: TechBranch.military,
        targetLevel: 1,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 1)},
        techBranches: _lockedBranches(),
      );
      expect(result.canAct, isFalse);
      expect(result.branchLocked, isTrue);
    });

    test('fail when previous node not researched (skip level)', () {
      final branches = _lockedBranches();
      branches[TechBranch.military]!.unlocked = true;
      // researchLevel is 0, trying to go to level 3
      final result = TechCostCalculator.checkResearch(
        branch: TechBranch.military,
        targetLevel: 3,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 5)},
        techBranches: branches,
      );
      expect(result.canAct, isFalse);
      expect(result.previousNodeMissing, isTrue);
    });

    test('fail when lab level too low', () {
      final branches = _lockedBranches();
      branches[TechBranch.military]!.unlocked = true;
      branches[TechBranch.military]!.researchLevel = 2;
      final result = TechCostCalculator.checkResearch(
        branch: TechBranch.military,
        targetLevel: 3,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 1)},
        techBranches: branches,
      );
      expect(result.canAct, isFalse);
      expect(result.requiredLabLevel, 3);
      expect(result.currentLabLevel, 1);
    });

    test('fail when max level reached', () {
      final branches = _lockedBranches();
      branches[TechBranch.military]!.unlocked = true;
      final result = TechCostCalculator.checkResearch(
        branch: TechBranch.military,
        targetLevel: 6,
        resources: _richResources(),
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 5)},
        techBranches: branches,
      );
      expect(result.canAct, isFalse);
      expect(result.isMaxLevel, isTrue);
    });

    test('fail when insufficient resources', () {
      final branches = _lockedBranches();
      branches[TechBranch.military]!.unlocked = true;
      final poor = {
        ResourceType.ore: Resource(type: ResourceType.ore, amount: 0),
        ResourceType.energy: Resource(type: ResourceType.energy, amount: 0),
      };
      final result = TechCostCalculator.checkResearch(
        branch: TechBranch.military,
        targetLevel: 1,
        resources: poor,
        buildings: {BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 1)},
        techBranches: branches,
      );
      expect(result.canAct, isFalse);
      expect(result.missingResources, isNotEmpty);
    });
  });
}
