import '../game/game.dart';
import '../game/player.dart';
import '../resource/resource_credit.dart';
import 'objective_catalog.dart';
import 'objective_completion.dart';
import 'objective_migration.dart';

/// Completes, at the end of a turn, the objectives a player has reached,
/// and credits their rewards.
abstract final class ObjectiveResolver {
  /// Every objective of the catalog not yet completed by [player] whose
  /// goal is met in [game], in catalog order; each reward is credited up
  /// to the storage. A completion is never undone nor paid twice.
  static List<ObjectiveCompletion> resolve(Game game, Player player) {
    final state = ObjectiveMigration.stateOf(game, player);
    final completions = <ObjectiveCompletion>[];
    for (final objective in ObjectiveCatalog.all) {
      if (state.isCompleted(objective.id)) continue;
      if (!objective.isDone(game, player)) continue;
      state.complete(objective.id);
      completions.add(
        ObjectiveCompletion(
          objective: objective,
          credited: ResourceCredit.add(player.resources, objective.reward),
        ),
      );
    }
    return completions;
  }
}
