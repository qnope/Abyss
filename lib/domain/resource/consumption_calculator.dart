import '../building/building.dart';
import '../building/building_type.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';

class ConsumptionCalculator {
  static int buildingEnergyConsumption(BuildingType type, int level) {
    if (level == 0) return 0;
    return switch (type) {
      BuildingType.headquarters => 3 * level,
      BuildingType.algaeFarm => 2 * level,
      BuildingType.coralMine => 2 * level,
      BuildingType.oreExtractor => 3 * level,
      BuildingType.solarPanel => 1 * level,
      BuildingType.coralCitadel => 1 * level,
      BuildingType.laboratory => 4 * level,
      BuildingType.barracks => 3 * level,
    };
  }

  static int totalBuildingConsumption(
    Map<BuildingType, Building> buildings, {
    Set<BuildingType>? excluded,
  }) {
    var total = 0;
    for (final building in buildings.values) {
      if (building.level == 0) continue;
      if (excluded != null && excluded.contains(building.type)) continue;
      total += buildingEnergyConsumption(building.type, building.level);
    }
    return total;
  }

  static int unitAlgaeConsumption(UnitType type) {
    return switch (type) {
      UnitType.scout => 1,
      UnitType.harpoonist => 2,
      UnitType.guardian => 3,
      UnitType.domeBreaker => 3,
      UnitType.abyssAdmiral => 2,
      UnitType.saboteur => 2,
    };
  }

  static int totalUnitConsumption(Map<UnitType, Unit> units) {
    var total = 0;
    for (final unit in units.values) {
      total += unitAlgaeConsumption(unit.type) * unit.count;
    }
    return total;
  }
}
