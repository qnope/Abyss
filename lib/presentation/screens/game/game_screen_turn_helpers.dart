import 'package:flutter/widgets.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_deactivator.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/consumption_calculator.dart';
import '../../../domain/game/defeat_checker.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/raid/raid_battle.dart';
import '../../../domain/resource/pearl_income.dart';
import '../../../domain/resource/production_calculator.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/unit/unit_loss_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../widgets/raid/raid_due_warning.dart';
import '../../widgets/volcano/volcano_due_warning.dart';

Map<ResourceType, int> computeProduction(Game game, Player player) {
  final production = game.difficulty.scaleProduction(
    ProductionCalculator.fromBuildings(
      player.buildings, techBranches: player.techBranches));
  final pearls = PearlIncome.of(game, player.id);
  if (pearls > 0) {
    production[ResourceType.pearl] =
        (production[ResourceType.pearl] ?? 0) + pearls;
  }
  return production;
}

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
  Game game,
  Player player,
  List<BuildingType> deactivated,
) {
  final activeBuildings = Map.of(player.buildings);
  for (final type in deactivated) {
    activeBuildings[type] = Building(type: type, level: 0);
  }
  final prod = game.difficulty.scaleProduction(
    ProductionCalculator.fromBuildings(
      activeBuildings,
      techBranches: player.techBranches,
    ),
  );
  final algaeProd = prod[ResourceType.algae] ?? 0;
  final algaeStock = player.resources[ResourceType.algae]?.amount ?? 0;
  return UnitLossCalculator.calculateLossesAllLevels(
    unitsPerLevel: player.unitsPerLevel,
    algaeProduction: algaeProd,
    algaeStock: algaeStock,
  );
}

/// Warning for the end-of-turn confirmation when a raid hits this turn.
RaidDueWarning? raidDueWarning(Game game, Player player) {
  final state = player.raidState;
  if (!state.isIncoming || state.arrivalTurn! > game.turn) return null;
  final defenders = RaidBattle.defendersOf(player)
      .values
      .fold<int>(0, (sum, count) => sum + count);
  return RaidDueWarning(
    wave: state.incoming!,
    defenderCount: defenders,
    lastChance: DefeatChecker.isLastChance(game),
  );
}

/// Warnings for the end-of-turn confirmation: the raid on the base and
/// the kraken wave on an unguarded kernel, `null` when neither hits.
Widget? dueWarnings(Game game, Player player) {
  final Widget? raid = raidDueWarning(game, player);
  final Widget? volcano = VolcanoDueWarning.of(game, player);
  final List<Widget> warnings = <Widget>[
    if (raid != null) raid,
    if (volcano != null) volcano,
  ];
  if (warnings.isEmpty) return null;
  if (warnings.length == 1) return warnings.single;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: warnings,
  );
}
