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
      BuildingType.laboratory => _laboratoryPrereqs(targetLevel),
      BuildingType.barracks => _barracksPrereqs(targetLevel),
      BuildingType.coralCitadel => coralCitadelPrereqs(targetLevel),
      BuildingType.algaeFarm ||
      BuildingType.coralMine ||
      BuildingType.oreExtractor ||
      BuildingType.solarPanel => _productionBuildingPrereqs(targetLevel),
      BuildingType.descentModule => {BuildingType.headquarters: 5},
      BuildingType.pressureCapsule => {BuildingType.headquarters: 8},
      BuildingType.volcanicKernel => {},
    };
  }

  TransitionBaseType? requiredCapturedBase(BuildingType type) {
    return switch (type) {
      BuildingType.descentModule => TransitionBaseType.faille,
      BuildingType.pressureCapsule => TransitionBaseType.cheminee,
      _ => null,
    };
  }

  Map<BuildingType, int> _productionBuildingPrereqs(int targetLevel) {
    final hqLevel = switch (targetLevel) {
      1 => 1,
      2 => 2,
      3 => 4,
      4 => 6,
      5 => 10,
      _ => 0,
    };
    return hqLevel > 0 ? {BuildingType.headquarters: hqLevel} : {};
  }

  Map<BuildingType, int> _laboratoryPrereqs(int targetLevel) {
    final hqLevel = switch (targetLevel) {
      1 => 2,
      2 => 3,
      3 => 5,
      4 => 7,
      5 => 10,
      _ => 0,
    };
    return hqLevel > 0 ? {BuildingType.headquarters: hqLevel} : {};
  }

  Map<BuildingType, int> _barracksPrereqs(int targetLevel) {
    final hqLevel = switch (targetLevel) {
      1 => 3,
      2 => 4,
      3 => 6,
      4 => 8,
      5 => 10,
      _ => 0,
    };
    return hqLevel > 0 ? {BuildingType.headquarters: hqLevel} : {};
  }

  UpgradeCheck checkUpgrade({
    required BuildingType type,
    required int currentLevel,
    required Map<ResourceType, Resource> resources,
    required Map<BuildingType, Building> allBuildings,
    Set<TransitionBaseType> capturedBaseTypes = const {},
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

    return UpgradeCheck(
      canUpgrade: missingResources.isEmpty &&
          missingPrereqs.isEmpty &&
          missingBase == null,
      missingResources: missingResources,
      missingPrerequisites: missingPrereqs,
      missingCapturedBase: missingBase,
    );
  }
}
