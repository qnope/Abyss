import '../game/game.dart';
import '../game/player.dart';
import 'objective_catalog.dart';
import 'objective_state.dart';

/// Brings the games saved before the objectives to the objectives: what
/// was already met counts as completed, without its reward, and the
/// tutorial stays off.
abstract final class ObjectiveMigration {
  /// The state of [player] in [game] had it been saved before the
  /// objectives. Pure: [game] is left as is.
  static ObjectiveState legacyState(Game game, Player player) =>
      ObjectiveState(
        completed: [
          for (final objective in ObjectiveCatalog.all)
            if (objective.isDone(game, player)) objective.id,
        ],
      );

  /// The objectives of [player], filled with [legacyState] when it was
  /// saved before them.
  static ObjectiveState stateOf(Game game, Player player) =>
      player.savedObjectiveState ??= legacyState(game, player);

  /// Gives every player of [game] saved before the objectives its
  /// [legacyState]; applied when a game is loaded.
  static void migrate(Game game) {
    for (final player in game.players.values) {
      stateOf(game, player);
    }
  }
}
