import 'building.dart';
import 'building_type.dart';
import 'coral_citadel_costs.dart';
import 'descent_costs.dart';
import 'volcanic_kernel_costs.dart';
import '../map/transition_base_type.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import 'upgrade_check.dart';

class BuildingCostCalculator {
  Map<ResourceType, int> upgradeCost(BuildingType type, int currentLevel) {
    if (currentLevel >= maxLevel(type)) return {};
    return switch (type) {
      BuildingType.headquarters => {
        ResourceType.coral: 30 * (currentLevel * currentLevel + 1),
        ResourceType.ore: 20 * (currentLevel * currentLevel + 1),
      },
      BuildingType.algaeFarm => {
        ResourceType.coral: 20 * (currentLevel * currentLevel + 1),
      },
      BuildingType.coralMine => {
        ResourceType.ore: 15 * (currentLevel * currentLevel + 1),
      },
      BuildingType.oreExtractor => {
        ResourceType.coral: 25 * (currentLevel * currentLevel + 1),
        ResourceType.energy: 15 * (currentLevel * currentLevel + 1),
      },
      BuildingType.solarPanel => {
        ResourceType.coral: 20 * (currentLevel * currentLevel + 1),
        ResourceType.ore: 15 * (currentLevel * currentLevel + 1),
      },
      BuildingType.laboratory => {
        ResourceType.coral: 25 * (currentLevel * currentLevel + 1),
        ResourceType.ore: 20 * (currentLevel * currentLevel + 1),
      },
      BuildingType.barracks => {
        ResourceType.coral: 20 * (currentLevel * currentLevel + 1),
        ResourceType.ore: 25 * (currentLevel * currentLevel + 1),
        ResourceType.energy: 10 * (currentLevel * currentLevel + 1),
      },
      BuildingType.coralCitadel => coralCitadelCost(currentLevel),
      BuildingType.descentModule => descentModuleCost(),
      BuildingType.pressureCapsule => pressureCapsuleCost(),
      BuildingType.volcanicKernel => volcanicKernelCost(currentLevel),
    };
  }

  int maxLevel(BuildingType type) => switch (type) {
    BuildingType.headquarters => 10,
    BuildingType.algaeFarm ||
    BuildingType.coralMine ||
    BuildingType.oreExtractor ||
    BuildingType.solarPanel ||
    BuildingType.laboratory ||
    BuildingType.barracks ||
    BuildingType.coralCitadel => 5,
    BuildingType.descentModule ||
    BuildingType.pressureCapsule => 1,
    BuildingType.volcanicKernel => 10,
  };

  Map<BuildingType, int> prerequisites(BuildingType type, int targetLevel) {
    return switch (type) {
      BuildingType.headquarters => {},
      BuildingType.laboratory => _hqPrereq(targetLevel, [2, 3, 5, 7, 10]),
      BuildingType.barracks => _hqPrereq(targetLevel, [3, 4, 6, 8, 10]),
      BuildingType.coralCitadel => coralCitadelPrereqs(targetLevel),
      BuildingType.algaeFarm ||
      BuildingType.coralMine ||
      BuildingType.oreExtractor ||
      BuildingType.solarPanel => _hqPrereq(targetLevel, [1, 2, 4, 6, 10]),
      BuildingType.descentModule => {BuildingType.headquarters: 5},
      BuildingType.pressureCapsule => {BuildingType.headquarters: 8},
      BuildingType.volcanicKernel => {BuildingType.headquarters: 10},
    };
  }

  bool requiresCapturedKernel(BuildingType type) {
    return type == BuildingType.volcanicKernel;
  }

  TransitionBaseType? requiredCapturedBase(BuildingType type) {
    return switch (type) {
      BuildingType.descentModule => TransitionBaseType.faille,
      BuildingType.pressureCapsule => TransitionBaseType.cheminee,
      _ => null,
    };
  }

  Map<BuildingType, int> _hqPrereq(int targetLevel, List<int> levels) {
    final hqLevel = targetLevel >= 1 && targetLevel <= levels.length
        ? levels[targetLevel - 1]
        : 0;
    return hqLevel > 0 ? {BuildingType.headquarters: hqLevel} : {};
  }

  UpgradeCheck checkUpgrade({
    required BuildingType type,
    required int currentLevel,
    required Map<ResourceType, Resource> resources,
    required Map<BuildingType, Building> allBuildings,
    Set<TransitionBaseType> capturedBaseTypes = const {},
    bool isVolcanicKernelCaptured = false,
  }) {
    if (currentLevel >= maxLevel(type)) {
      return const UpgradeCheck(canUpgrade: false, isMaxLevel: true);
    }

    final costs = upgradeCost(type, currentLevel);
    final missingResources = <ResourceType, int>{};
    for (final entry in costs.entries) {
      final available = resources[entry.key]?.amount ?? 0;
      if (available < entry.value) {
        missingResources[entry.key] = entry.value - available;
      }
    }

    final prereqs = prerequisites(type, currentLevel + 1);
    final missingPrereqs = <BuildingType, int>{};
    for (final entry in prereqs.entries) {
      final currentBuildingLevel = allBuildings[entry.key]?.level ?? 0;
      if (currentBuildingLevel < entry.value) {
        missingPrereqs[entry.key] = entry.value;
      }
    }

    final reqBase = requiredCapturedBase(type);
    final TransitionBaseType? missingBase =
        reqBase != null && !capturedBaseTypes.contains(reqBase)
            ? reqBase
            : null;

    final bool missingKernel =
        requiresCapturedKernel(type) && !isVolcanicKernelCaptured;

    return UpgradeCheck(
      canUpgrade: missingResources.isEmpty &&
          missingPrereqs.isEmpty &&
          missingBase == null &&
          !missingKernel,
      missingResources: missingResources,
      missingPrerequisites: missingPrereqs,
      missingCapturedBase: missingBase,
      missingCapturedKernel: missingKernel,
    );
  }
}
