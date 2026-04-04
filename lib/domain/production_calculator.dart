import 'building.dart';
import 'building_cost_calculator.dart';
import 'building_type.dart';
import 'resource_type.dart';

class ProductionCalculator {
  static Map<ResourceType, int> fromBuildings(
    Map<BuildingType, Building> buildings,
  ) {
    final result = <ResourceType, int>{};
    for (final building in buildings.values) {
      final prod = BuildingCostCalculator.productionPerLevel(building.type);
      if (prod != null && building.level > 0) {
        result[prod.key] = (result[prod.key] ?? 0) + building.level * prod.value;
      }
    }
    return result;
  }
}
