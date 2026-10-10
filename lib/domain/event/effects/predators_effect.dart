import '../../game/game.dart';
import '../../game/player.dart';
import 'event_effect.dart';

/// Shoal of predators striking the base at the end of the turn, fought
/// or baited away.
class PredatorsEffect extends EventEffect {
  const PredatorsEffect();

  /// Never on top of a raid hitting the base at the end of the next turn.
  @override
  bool allowedAt(Game game, Player player, int endedTurn) {
    final raid = player.raidState;
    return !(raid.isIncoming && raid.arrivalTurn == endedTurn + 1);
  }
}
