import '../game/game.dart';
import '../map/exploration_resolver.dart';
import 'player_turn_resolver.dart';
import 'turn_result.dart';

class TurnResolver {
  TurnResult resolve(Game game) {
    final previousTurn = game.turn;
    final humanId = game.humanPlayer.id;
    TurnResult? humanResult;

    for (final player in game.players.values) {
      final result = PlayerTurnResolver.resolve(player, previousTurn);
      if (player.id == humanId) humanResult = result;
    }

    final explorations = ExplorationResolver.resolve(game);
    game.turn++;

    final human = humanResult!;
    return TurnResult(
      changes: human.changes,
      previousTurn: previousTurn,
      newTurn: game.turn,
      hadRecruitedUnits: human.hadRecruitedUnits,
      deactivatedBuildings: human.deactivatedBuildings,
      lostUnits: human.lostUnits,
      explorations: explorations,
    );
  }
}
