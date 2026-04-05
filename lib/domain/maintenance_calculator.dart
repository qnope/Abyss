import 'resource_type.dart';
import 'unit.dart';
import 'unit_cost_calculator.dart';
import 'unit_type.dart';

class MaintenanceCalculator {
  static Map<ResourceType, int> fromUnits(Map<UnitType, Unit> units) {
    final calculator = UnitCostCalculator();
    final result = <ResourceType, int>{};
    for (final entry in units.entries) {
      if (entry.value.count <= 0) continue;
      final cost = calculator.maintenanceCost(entry.key);
      for (final c in cost.entries) {
        result[c.key] = (result[c.key] ?? 0) + c.value * entry.value.count;
      }
    }
    return result;
  }
}
