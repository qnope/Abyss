import '../building/building.dart';
import '../building/building_deactivator.dart';
import '../game/player.dart';
import '../resource/consumption_calculator.dart';
import '../resource/production_calculator.dart';
import '../resource/resource_type.dart';
import '../unit/unit_loss_calculator.dart';
import 'turn_result.dart';

class PlayerTurnResolver {
  static TurnResult resolve(Player player, int previousTurn) {
    final hadRecruitedUnits = player.recruitedUnitTypes.isNotEmpty;

    // Step 1: Calculate initial production
    var production = ProductionCalculator.fromBuildings(
      player.buildings,
      techBranches: player.techBranches,
    );

    // Steps 2-4: Energy consumption & building deactivation
    final energyProd = production[ResourceType.energy] ?? 0;
    final energyStock = player.resources[ResourceType.energy]?.amount ?? 0;
    final deactivated = BuildingDeactivator.deactivate(
      buildings: player.buildings,
      energyProduction: energyProd,
      energyStock: energyStock,
    );

    // Step 5: Recalculate production if buildings were deactivated
    if (deactivated.isNotEmpty) {
      final activeBuildings = Map.of(player.buildings);
      for (final type in deactivated) {
        activeBuildings[type] = Building(type: type, level: 0);
      }
      production = ProductionCalculator.fromBuildings(
        activeBuildings,
        techBranches: player.techBranches,
      );
    }

    // Steps 6-9: Algae consumption & unit losses (all levels)
    final algaeProd = production[ResourceType.algae] ?? 0;
    final algaeStock = player.resources[ResourceType.algae]?.amount ?? 0;
    final lostUnits = UnitLossCalculator.applyLossesAllLevels(
      unitsPerLevel: player.unitsPerLevel,
      algaeProduction: algaeProd,
      algaeStock: algaeStock,
    );

    // Step 10: Recalculate consumption after losses
    final energyConsumption = ConsumptionCalculator.totalBuildingConsumption(
      player.buildings,
      excluded: deactivated.toSet(),
    );
    final algaeConsumption =
        ConsumptionCalculator.totalUnitConsumptionAllLevels(
      player.unitsPerLevel,
    );

    // Step 11: Apply resource changes
    final changes = _applyResourceChanges(
      player: player,
      production: production,
      energyConsumption: energyConsumption,
      algaeConsumption: algaeConsumption,
    );

    player.recruitedUnitTypes.clear();

    return TurnResult(
      changes: changes,
      previousTurn: previousTurn,
      newTurn: previousTurn,
      hadRecruitedUnits: hadRecruitedUnits,
      deactivatedBuildings: deactivated,
      lostUnits: lostUnits,
    );
  }

  static List<TurnResourceChange> _applyResourceChanges({
    required Player player,
    required Map<ResourceType, int> production,
    required int energyConsumption,
    required int algaeConsumption,
  }) {
    final resourceTypes = <ResourceType>{
      ...production.keys,
      if (energyConsumption > 0) ResourceType.energy,
      if (algaeConsumption > 0) ResourceType.algae,
    };

    final changes = <TurnResourceChange>[];
    for (final type in resourceTypes) {
      final resource = player.resources[type];
      if (resource == null) continue;

      final produced = production[type] ?? 0;
      final consumed = switch (type) {
        ResourceType.energy => energyConsumption,
        ResourceType.algae => algaeConsumption,
        _ => 0,
      };
      final netChange = produced - consumed;
      final beforeAmount = resource.amount;
      var newAmount = resource.amount + netChange;
      final capped = newAmount > resource.maxStorage;
      if (newAmount < 0) newAmount = 0;
      if (capped) newAmount = resource.maxStorage;
      resource.amount = newAmount;

      changes.add(TurnResourceChange(
        type: type,
        produced: produced,
        consumed: consumed,
        wasCapped: capped,
        beforeAmount: beforeAmount,
        afterAmount: resource.amount,
      ));
    }
    return changes;
  }
}
