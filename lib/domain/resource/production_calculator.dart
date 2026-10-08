import '../building/building.dart';
import '../building/building_type.dart';
import 'production_formulas.dart';
import 'resource_type.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_branch_state.dart';

class ProductionCalculator {
  /// Flat income of a built HQ, whatever its level. Coral pays for the
  /// Ore Extractor and ore for the Coral Mine, so without it a base that
  /// spent its stock on anything else could never build either again.
  static const Map<ResourceType, int> headquartersIncome = {
    ResourceType.coral: 15,
    ResourceType.ore: 10,
  };

  static Map<ResourceType, int> fromBuildings(
    Map<BuildingType, Building> buildings, {
    Map<TechBranch, TechBranchState>? techBranches,
  }) {
    final result = <ResourceType, int>{};
    for (final building in buildings.values) {
      final formula = productionFormulas[building.type];
      if (formula != null && building.level > 0) {
        final amount = formula.compute(building.level);
        result[formula.resourceType] =
            (result[formula.resourceType] ?? 0) + amount;
      }
    }
    if ((buildings[BuildingType.headquarters]?.level ?? 0) > 0) {
      for (final entry in headquartersIncome.entries) {
        result[entry.key] = (result[entry.key] ?? 0) + entry.value;
      }
    }
    final resourcesLevel =
        techBranches?[TechBranch.resources]?.researchLevel ?? 0;
    if (resourcesLevel > 0) {
      final multiplier = 1.0 + (0.2 * resourcesLevel);
      for (final type in result.keys.toList()) {
        result[type] = (result[type]! * multiplier).floor();
      }
    }
    return result;
  }
}
