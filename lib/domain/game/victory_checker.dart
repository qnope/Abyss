import 'package:abyss/domain/building/building_type.dart';

import 'game.dart';
import 'game_status.dart';

class VictoryChecker {
  static const int _winLevel = 10;

  /// Returns a new GameStatus if the game state should change,
  /// or null if no change.
  static GameStatus? check(Game game) {
    if (game.status == GameStatus.freePlay) return null;
    if (game.status != GameStatus.playing) return null;

    for (final player in game.players.values) {
      final kernelLevel =
          player.buildings[BuildingType.volcanicKernel]?.level ?? 0;
      if (kernelLevel >= _winLevel) {
        return player.id == game.humanPlayerId
            ? GameStatus.victory
            : GameStatus.defeat;
      }
    }
    return null;
  }
}
