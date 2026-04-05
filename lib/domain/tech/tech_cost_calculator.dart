import '../building/building.dart';
import '../building/building_type.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import 'tech_branch.dart';
import 'tech_branch_state.dart';
import 'tech_check.dart';

class TechCostCalculator {
  static const maxResearchLevel = 5;

  static Map<ResourceType, int> unlockCost(TechBranch branch) {
    return switch (branch) {
      TechBranch.military => {ResourceType.ore: 30, ResourceType.energy: 20},
      TechBranch.resources => {ResourceType.coral: 30, ResourceType.algae: 20},
      TechBranch.explorer => {ResourceType.energy: 30, ResourceType.ore: 20},
    };
  }

  static Map<ResourceType, int> researchCost(TechBranch branch, int level) {
    final (primary, secondary) = switch (branch) {
      TechBranch.military => (ResourceType.ore, ResourceType.energy),
      TechBranch.resources => (ResourceType.coral, ResourceType.algae),
      TechBranch.explorer => (ResourceType.energy, ResourceType.ore),
    };
    return _scaledCost(primary, secondary, level);
  }

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

    final costs = unlockCost(branch);
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

    final costs = researchCost(branch, targetLevel);
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
    final (p, s, pearl) = switch (level) {
      1 => (40, 25, 0),
      2 => (80, 50, 0),
      3 => (150, 90, 0),
      4 => (250, 150, 5),
      5 => (400, 250, 10),
      _ => (0, 0, 0),
    };
    if (p == 0) return {};
    return {
      primary: p,
      secondary: s,
      if (pearl > 0) ResourceType.pearl: pearl,
    };
  }
}
