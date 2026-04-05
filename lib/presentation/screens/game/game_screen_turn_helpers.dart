import '../../../domain/building/building.dart';
import '../../../domain/building/building_deactivator.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/consumption_calculator.dart';
import '../../../domain/game/game.dart';
import '../../../domain/resource/production_calculator.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/unit/unit_loss_calculator.dart';
import '../../../domain/unit/unit_type.dart';

Map<ResourceType, int> computeConsumption(Game game) {
  final consumption = <ResourceType, int>{};
  final energy = ConsumptionCalculator.totalBuildingConsumption(game.buildings);
  if (energy > 0) consumption[ResourceType.energy] = energy;
  final algae = ConsumptionCalculator.totalUnitConsumption(game.units);
  if (algae > 0) consumption[ResourceType.algae] = algae;
  return consumption;
}

List<BuildingType> computeBuildingsToDeactivate(
  Game game,
  Map<ResourceType, int> production,
) {
  final energyProd = production[ResourceType.energy] ?? 0;
  final energyStock = game.resources[ResourceType.energy]?.amount ?? 0;
  return BuildingDeactivator.deactivate(
    buildings: game.buildings,
    energyProduction: energyProd,
    energyStock: energyStock,
  );
}

Map<UnitType, int> computeUnitsToLose(
  Game game,
  List<BuildingType> deactivated,
) {
  final activeBuildings = Map.of(game.buildings);
  for (final type in deactivated) {
    activeBuildings[type] = Building(type: type, level: 0);
  }
  final prod = ProductionCalculator.fromBuildings(
    activeBuildings,
    techBranches: game.techBranches,
  );
  final algaeProd = prod[ResourceType.algae] ?? 0;
  final algaeStock = game.resources[ResourceType.algae]?.amount ?? 0;
  return UnitLossCalculator.calculateLosses(
    units: game.units,
    algaeProduction: algaeProd,
    algaeStock: algaeStock,
  );
}
