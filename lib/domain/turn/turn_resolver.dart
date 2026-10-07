import '../game/game.dart';
import '../game/victory_checker.dart';
import '../map/exploration_resolver.dart';
import '../map/reinforcement_resolver.dart';
import '../raid/raid_resolver.dart';
import '../resource/pearl_income.dart';
import 'player_turn_resolver.dart';
import 'turn_result.dart';

class TurnResolver {
  TurnResult resolve(Game game) {
    final previousTurn = game.turn;
    final humanId = game.humanPlayer.id;
    TurnResult? humanResult;
    RaidTurnOutcome raid = const RaidTurnOutcome();

    for (final player in game.players.values) {
      final result = PlayerTurnResolver.resolve(
        player,
        previousTurn,
        extraProduction: PearlIncome.asProduction(game, player.id),
      );
      final outcome = RaidResolver.resolve(player, previousTurn);
      if (player.id == humanId) {
        humanResult = result;
        raid = outcome;
      }
    }

    final explorations = ExplorationResolver.resolve(game);
    final reinforcements = ReinforcementResolver.resolve(game);
    game.turn++;
    game.status = VictoryChecker.check(game) ?? game.status;

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
    );
  }
}
