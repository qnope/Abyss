import 'dart:math';

import '../game/defeat_checker.dart';
import '../game/game.dart';
import '../map/exploration_resolver.dart';
import '../map/reinforcement_resolver.dart';
import '../raid/raid_resolver.dart';
import '../volcano/volcano_resolver.dart';
import '../resource/pearl_income.dart';
import 'player_turn_resolver.dart';
import 'turn_result.dart';

class TurnResolver {
  /// [random] drives the raid fights; pass a seeded one for a
  /// reproducible turn.
  TurnResult resolve(Game game, {Random? random}) {
    final previousTurn = game.turn;
    final humanId = game.humanPlayer.id;
    TurnResult? humanResult;
    RaidTurnOutcome raid = const RaidTurnOutcome();
    VolcanoTurnOutcome volcano = const VolcanoTurnOutcome();

    for (final player in game.players.values) {
      final result = PlayerTurnResolver.resolve(
        player,
        previousTurn,
        extraProduction: PearlIncome.asProduction(game, player.id),
        difficulty: game.difficulty,
      );
      final outcome = RaidResolver.resolve(
        player,
        previousTurn,
        random: random,
        difficulty: game.difficulty,
      );
      final volcanoOutcome = VolcanoResolver.resolve(
        player,
        previousTurn,
        random: random,
        difficulty: game.difficulty,
      );
      if (player.id == humanId) {
        humanResult = result;
        raid = outcome;
        volcano = volcanoOutcome;
      }
    }

    final explorations = ExplorationResolver.resolve(game);
    final reinforcements = ReinforcementResolver.resolve(game);
    game.turn++;
    game.status = DefeatChecker.check(game) ?? game.status;

    final human = humanResult!;
    return TurnResult(
      changes: human.changes,
      previousTurn: previousTurn,
      newTurn: game.turn,
      hadRecruitedUnits: human.hadRecruitedUnits,
      deactivatedBuildings: human.deactivatedBuildings,
      lostUnits: human.lostUnits,
      explorations: explorations,
      arrivedReinforcements: reinforcements,
      raid: raid.report,
      announcedRaid: raid.announced,
      announcedRaidTurn: raid.announcedTurn,
      volcano: volcano.report,
      announcedWave: volcano.announced,
    );
  }
}
