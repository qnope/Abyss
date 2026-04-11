import '../../../domain/building/building.dart';
import '../../../domain/building/building_deactivator.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/consumption_calculator.dart';
import '../../../domain/game/player.dart';
import '../../../domain/resource/production_calculator.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/unit/unit_loss_calculator.dart';
import '../../../domain/unit/unit_type.dart';

Map<ResourceType, int> computeConsumption(Player player) {
  final consumption = <ResourceType, int>{};
  final energy =
      ConsumptionCalculator.totalBuildingConsumption(player.buildings);
  if (energy > 0) consumption[ResourceType.energy] = energy;
  final algae = ConsumptionCalculator.totalUnitConsumptionAllLevels(
      player.unitsPerLevel);
  if (algae > 0) consumption[ResourceType.algae] = algae;
  return consumption;
}

List<BuildingType> computeBuildingsToDeactivate(
  Player player,
  Map<ResourceType, int> production,
) {
  final energyProd = production[ResourceType.energy] ?? 0;
  final energyStock = player.resources[ResourceType.energy]?.amount ?? 0;
  return BuildingDeactivator.deactivate(
    buildings: player.buildings,
    energyProduction: energyProd,
    energyStock: energyStock,
  );
}

Map<UnitType, int> computeUnitsToLose(
  Player player,
  List<BuildingType> deactivated,
) {
  final activeBuildings = Map.of(player.buildings);
  for (final type in deactivated) {
    activeBuildings[type] = Building(type: type, level: 0);
  }
  final prod = ProductionCalculator.fromBuildings(
    activeBuildings,
    techBranches: player.techBranches,
  );
  final algaeProd = prod[ResourceType.algae] ?? 0;
  final algaeStock = player.resources[ResourceType.algae]?.amount ?? 0;
  return UnitLossCalculator.calculateLossesAllLevels(
    unitsPerLevel: player.unitsPerLevel,
    algaeProduction: algaeProd,
    algaeStock: algaeStock,
  );
}
