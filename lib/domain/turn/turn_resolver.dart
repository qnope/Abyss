import '../building/building.dart';
import '../building/building_deactivator.dart';
import '../map/exploration_resolver.dart';
import '../resource/consumption_calculator.dart';
import '../game/game.dart';
import '../resource/production_calculator.dart';
import '../resource/resource_type.dart';
import 'turn_result.dart';
import '../unit/unit_loss_calculator.dart';

class TurnResolver {
  TurnResult resolve(Game game) {
    final previousTurn = game.turn;
    final hadRecruitedUnits = game.recruitedUnitTypes.isNotEmpty;

    // Step 1: Calculate initial production
    var production = ProductionCalculator.fromBuildings(
      game.buildings,
      techBranches: game.techBranches,
    );

    // Steps 2-4: Energy consumption & building deactivation
    final energyProd = production[ResourceType.energy] ?? 0;
    final energyStock = game.resources[ResourceType.energy]?.amount ?? 0;
    final deactivated = BuildingDeactivator.deactivate(
      buildings: game.buildings,
      energyProduction: energyProd,
      energyStock: energyStock,
    );

    // Step 5: Recalculate production if buildings were deactivated
    if (deactivated.isNotEmpty) {
      final activeBuildings = Map.of(game.buildings);
      for (final type in deactivated) {
        activeBuildings[type] = Building(type: type, level: 0);
      }
      production = ProductionCalculator.fromBuildings(
        activeBuildings,
        techBranches: game.techBranches,
      );
    }

    // Steps 6-8: Algae consumption & unit losses
    final algaeProd = production[ResourceType.algae] ?? 0;
    final algaeStock = game.resources[ResourceType.algae]?.amount ?? 0;
    final lostUnits = UnitLossCalculator.calculateLosses(
      units: game.units,
      algaeProduction: algaeProd,
      algaeStock: algaeStock,
    );

    // Step 9: Apply unit losses
    for (final entry in lostUnits.entries) {
      final unit = game.units[entry.key];
      if (unit != null) unit.count -= entry.value;
    }

    // Step 10: Recalculate consumption after losses
    final energyConsumption =
        ConsumptionCalculator.totalBuildingConsumption(
      game.buildings,
      excluded: deactivated.toSet(),
    );
    final algaeConsumption =
        ConsumptionCalculator.totalUnitConsumption(game.units);

    // Step 11: Apply resource changes
    final changes = _applyResourceChanges(
      game: game,
      production: production,
      energyConsumption: energyConsumption,
      algaeConsumption: algaeConsumption,
    );

    // Step 12: Resolve explorations
    final explorations = ExplorationResolver.resolve(game);

    // Steps 13-15
    game.recruitedUnitTypes.clear();
    game.turn++;
    return TurnResult(
      changes: changes,
      previousTurn: previousTurn,
      newTurn: game.turn,
      hadRecruitedUnits: hadRecruitedUnits,
      deactivatedBuildings: deactivated,
      lostUnits: lostUnits,
      explorations: explorations,
    );
  }

  List<TurnResourceChange> _applyResourceChanges({
    required Game game,
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
      final resource = game.resources[type];
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
