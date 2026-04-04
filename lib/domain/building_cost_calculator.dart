import 'building.dart';
import 'building_type.dart';
import 'resource.dart';
import 'resource_type.dart';
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
    };
  }

  int maxLevel(BuildingType type) => switch (type) {
    BuildingType.headquarters => 10,
    BuildingType.algaeFarm ||
    BuildingType.coralMine ||
    BuildingType.oreExtractor ||
    BuildingType.solarPanel => 5,
  };

  Map<BuildingType, int> prerequisites(BuildingType type, int targetLevel) {
    return switch (type) {
      BuildingType.headquarters => {},
      BuildingType.algaeFarm ||
      BuildingType.coralMine ||
      BuildingType.oreExtractor ||
      BuildingType.solarPanel => _productionBuildingPrereqs(targetLevel),
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

  UpgradeCheck checkUpgrade({
    required BuildingType type,
    required int currentLevel,
    required Map<ResourceType, Resource> resources,
    required Map<BuildingType, Building> allBuildings,
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

    return UpgradeCheck(
      canUpgrade: missingResources.isEmpty && missingPrereqs.isEmpty,
      missingResources: missingResources,
      missingPrerequisites: missingPrereqs,
    );
  }
}
