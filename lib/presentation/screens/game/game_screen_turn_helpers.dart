import 'package:flutter/widgets.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/resource/consumption_calculator.dart';
import '../../../domain/game/defeat_checker.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/raid/raid_battle.dart';
import '../../../domain/resource/pearl_income.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/turn/turn_production.dart';
import '../../../domain/unit/unit_loss_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../widgets/raid/raid_due_warning.dart';
import '../../widgets/volcano/volcano_due_warning.dart';

/// What the base will make at the end of the current turn.
Map<ResourceType, int> computeProduction(Game game, Player player) {
  final production = TurnProduction.of(
    player,
    turn: game.turn,
    difficulty: game.difficulty,
  );
  final pearls = PearlIncome.of(game, player.id);
  if (pearls > 0) {
    production[ResourceType.pearl] =
        (production[ResourceType.pearl] ?? 0) + pearls;
  }
  return production;
}

/// What the base will spend at the end of the current turn.
Map<ResourceType, int> computeConsumption(Game game, Player player) {
  final consumption = <ResourceType, int>{};
  final energy = TurnProduction.energyConsumption(player, turn: game.turn);
  if (energy > 0) consumption[ResourceType.energy] = energy;
  final algae = ConsumptionCalculator.totalUnitConsumptionAllLevels(
      player.unitsPerLevel);
  if (algae > 0) consumption[ResourceType.algae] = algae;
  return consumption;
}

/// Buildings the end of the current turn will shut down for lack of
/// energy.
List<BuildingType> computeBuildingsToDeactivate(
  Game game,
  Player player,
  Map<ResourceType, int> production,
) => TurnProduction.deactivated(player, production, turn: game.turn);

/// Units the end of the current turn will lose for lack of algae.
Map<UnitType, int> computeUnitsToLose(
  Game game,
  Player player,
  List<BuildingType> deactivated,
) {
  final prod = TurnProduction.of(
    player,
    turn: game.turn,
    difficulty: game.difficulty,
    deactivated: deactivated,
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
  return RaidDueWarning(
    wave: state.incoming!,
    defenderCount: _defenderCount(player),
    lastChance: DefeatChecker.isLastChance(game),
  );
}

/// Warning for the end-of-turn confirmation when the school of predators
/// faced this turn strikes at its end. Losing it never ends the game.
RaidDueWarning? predatorsDueWarning(Game game, Player player) {
  final state = player.eventState;
  final wave = state.predatorWave;
  final due = state.predatorsTurn;
  if (wave == null || due == null || due > game.turn) return null;
  return RaidDueWarning(
    wave: wave,
    defenderCount: _defenderCount(player),
    attacker: 'Banc de prédateurs',
  );
}

int _defenderCount(Player player) => RaidBattle.defendersOf(player)
    .values
    .fold<int>(0, (sum, count) => sum + count);

/// Warnings for the end-of-turn confirmation: the raid or the predators
/// on the base and the kraken wave on an unguarded kernel, `null` when
/// none hits.
Widget? dueWarnings(Game game, Player player) {
  final Widget? raid = raidDueWarning(game, player);
  final Widget? predators = predatorsDueWarning(game, player);
  final Widget? volcano = VolcanoDueWarning.of(game, player);
  final List<Widget> warnings = <Widget>[
    if (raid != null) raid,
    if (predators != null) predators,
    if (volcano != null) volcano,
  ];
  if (warnings.isEmpty) return null;
  if (warnings.length == 1) return warnings.single;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: warnings,
  );
}
