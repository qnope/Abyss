import 'building.dart';
import 'building_type.dart';
import 'production_formulas.dart';
import 'resource_type.dart';

class ProductionCalculator {
  static Map<ResourceType, int> fromBuildings(
    Map<BuildingType, Building> buildings,
  ) {
    final result = <ResourceType, int>{};
    for (final building in buildings.values) {
      final formula = productionFormulas[building.type];
      if (formula != null && building.level > 0) {
        final amount = formula.compute(building.level);
        result[formula.resourceType] =
            (result[formula.resourceType] ?? 0) + amount;
      }
    }
    return result;
  }
}
