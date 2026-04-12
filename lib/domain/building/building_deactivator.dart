import 'building.dart';
import 'building_type.dart';
import '../resource/consumption_calculator.dart';

class BuildingDeactivator {
  /// Priority order: buildings later in this list are disabled first.
  /// HQ is never disabled (index 0, never reached).
  static const List<BuildingType> _priority = [
    BuildingType.headquarters, // 0 - never disabled
    BuildingType.coralCitadel, // 1 - last to be disabled
    BuildingType.solarPanel, // 2
    BuildingType.descentModule, // 3
    BuildingType.pressureCapsule, // 4
    BuildingType.barracks, // 5
    BuildingType.laboratory, // 6
    BuildingType.algaeFarm, // 7
    BuildingType.coralMine, // 8
    BuildingType.volcanicKernel, // 10
    BuildingType.oreExtractor, // 11 - disabled first
  ];

  /// Returns list of buildings that must be deactivated.
  static List<BuildingType> deactivate({
    required Map<BuildingType, Building> buildings,
    required int energyProduction,
    required int energyStock,
  }) {
    var consumption =
        ConsumptionCalculator.totalBuildingConsumption(buildings);
    final available = energyProduction + energyStock;

    if (consumption <= available) return [];

    final deactivated = <BuildingType>[];

    for (var i = _priority.length - 1; i > 0; i--) {
      if (consumption <= available) break;

      final type = _priority[i];
      final building = buildings[type];
      if (building == null || building.level == 0) continue;

      deactivated.add(type);
      consumption -= ConsumptionCalculator.buildingEnergyConsumption(
        type,
        building.level,
      );
    }

    return deactivated;
  }
}
