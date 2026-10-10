import 'package:abyss/domain/building/building_type.dart';

import 'game.dart';
import 'player.dart';
import 'game_status.dart';

class VictoryChecker {
  static const int _winLevel = 10;

  /// Returns a new GameStatus if the game state should change,
  /// or null if no change.
  static GameStatus? check(Game game) {
    if (game.status == GameStatus.freePlay) return null;
    if (game.status != GameStatus.playing) return null;
    final Player? winner = winnerOf(game);
    if (winner == null) return null;
    return winner.id == game.humanPlayerId
        ? GameStatus.victory
        : GameStatus.defeat;
  }

  /// The player whose kernel stands at level 10, not degraded: the one
  /// who tamed the volcano, `null` while nobody has.
  static Player? winnerOf(Game game) {
    for (final Player player in game.players.values) {
      final int kernelLevel =
          player.buildings[BuildingType.volcanicKernel]?.level ?? 0;
      if (kernelLevel >= _winLevel &&
          !player.isDegraded(BuildingType.volcanicKernel)) {
        return player;
      }
    }
    return null;
  }
}
