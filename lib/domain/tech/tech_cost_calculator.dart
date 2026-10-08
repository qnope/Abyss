import 'dart:math' as math;

import '../building/building.dart';
import '../building/building_type.dart';
import '../resource/exponential_cost.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import 'tech_branch.dart';
import 'tech_branch_state.dart';
import 'tech_check.dart';
import 'tech_tree.dart';

class TechCostCalculator {
  static const maxResearchLevel = TechTree.maxLevel;

  /// Extra cost of every unlock and research per branch opened beyond
  /// the first, in percent.
  static const int perOpenedBranchPercent = 50;

  /// Branches already unlocked in [techBranches].
  static int openedBranches(Map<TechBranch, TechBranchState> techBranches) =>
      techBranches.values.where((s) => s.unlocked).length;

  /// Cost multiplier, in percent, once [opened] branches are unlocked.
  static int costPercent(int opened) =>
      100 + perOpenedBranchPercent * math.max(0, opened - 1);

  /// Cost to unlock [branch] when [opened] branches already are.
  static Map<ResourceType, int> unlockCost(TechBranch branch,
      {int opened = 0}) {
    return _scale(switch (branch) {
      TechBranch.military => {ResourceType.ore: 30, ResourceType.energy: 20},
      TechBranch.resources => {ResourceType.coral: 30, ResourceType.algae: 20},
      TechBranch.explorer => {ResourceType.energy: 30, ResourceType.ore: 20},
    }, opened + 1);
  }

  /// Cost of research [level] of [branch] with [opened] branches unlocked.
  static Map<ResourceType, int> researchCost(TechBranch branch, int level,
      {int opened = 1}) {
    final (primary, secondary) = switch (branch) {
      TechBranch.military => (ResourceType.ore, ResourceType.energy),
      TechBranch.resources => (ResourceType.coral, ResourceType.algae),
      TechBranch.explorer => (ResourceType.energy, ResourceType.ore),
    };
    return _scale(_scaledCost(primary, secondary, level), opened);
  }

  /// Pearls are rare: only resources grow with the opened branches.
  static Map<ResourceType, int> _scale(
          Map<ResourceType, int> cost, int opened) =>
      cost.map((t, v) => MapEntry(
          t, t == ResourceType.pearl ? v : v * costPercent(opened) ~/ 100));

  static int requiredLabLevel(int researchLevel) => researchLevel;

  static TechCheck checkUnlock({
    required TechBranch branch,
    required Map<ResourceType, Resource> resources,
    required Map<BuildingType, Building> buildings,
    required Map<TechBranch, TechBranchState> techBranches,
  }) {
    final state = techBranches[branch];
    if (state != null && state.unlocked) {
      return const TechCheck(canAct: false);
    }

    final labLevel = buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < 1) {
      return TechCheck(
        canAct: false,
        requiredLabLevel: 1,
        currentLabLevel: labLevel,
      );
    }

    final costs = unlockCost(branch, opened: openedBranches(techBranches));
    final missing = _missingResources(costs, resources);
    return TechCheck(
      canAct: missing.isEmpty,
      missingResources: missing,
      requiredLabLevel: 1,
      currentLabLevel: labLevel,
    );
  }

  static TechCheck checkResearch({
    required TechBranch branch,
    required int targetLevel,
    required Map<ResourceType, Resource> resources,
    required Map<BuildingType, Building> buildings,
    required Map<TechBranch, TechBranchState> techBranches,
  }) {
    final state = techBranches[branch];
    if (state == null || !state.unlocked) {
      return const TechCheck(canAct: false, branchLocked: true);
    }
    if (targetLevel > maxResearchLevel) {
      return const TechCheck(canAct: false, isMaxLevel: true);
    }
    if (targetLevel > 1 && state.researchLevel < targetLevel - 1) {
      return const TechCheck(canAct: false, previousNodeMissing: true);
    }

    final labLevel = buildings[BuildingType.laboratory]?.level ?? 0;
    final reqLab = requiredLabLevel(targetLevel);
    if (labLevel < reqLab) {
      return TechCheck(
        canAct: false,
        requiredLabLevel: reqLab,
        currentLabLevel: labLevel,
      );
    }

    final costs = researchCost(branch, targetLevel,
        opened: openedBranches(techBranches));
    final missing = _missingResources(costs, resources);
    return TechCheck(
      canAct: missing.isEmpty,
      missingResources: missing,
      requiredLabLevel: reqLab,
      currentLabLevel: labLevel,
    );
  }

  static Map<ResourceType, int> _missingResources(
    Map<ResourceType, int> costs,
    Map<ResourceType, Resource> resources,
  ) {
    final missing = <ResourceType, int>{};
    for (final entry in costs.entries) {
      final available = resources[entry.key]?.amount ?? 0;
      if (available < entry.value) {
        missing[entry.key] = entry.value - available;
      }
    }
    return missing;
  }

  static Map<ResourceType, int> _scaledCost(
    ResourceType primary,
    ResourceType secondary,
    int level,
  ) {
    if (level < 1 || level > maxResearchLevel) return {};
    final pearl = _researchPearls[level - 1];
    return {
      ...exponentialCost({primary: 80, secondary: 50}, level - 1),
      if (pearl > 0) ResourceType.pearl: pearl,
    };
  }

  static const _researchPearls = [0, 0, 0, 5, 10];
}
