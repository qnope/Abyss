import '../../game/game.dart';
import '../../game/player.dart';
import '../objective_goal.dart';

/// The player has gone down to [level]: its map exists and the player
/// either sees part of it (a descent reveals the landing area) or has
/// units there.
class LevelReachedGoal extends FlagGoal {
  final int level;

  const LevelReachedGoal(this.level);

  @override
  bool isMet(Game game, Player player) =>
      game.mapForLevel(level) != null &&
      (player.revealedCellsOnLevel(level).isNotEmpty ||
          player.unitsOnLevel(level).values.any((unit) => unit.count > 0));
}
