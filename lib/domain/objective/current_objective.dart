import '../game/game.dart';
import '../game/player.dart';
import 'objective.dart';
import 'objective_catalog.dart';
import 'objective_migration.dart';

/// The objective a player is on, read without computing any progress.
abstract final class CurrentObjective {
  /// The first objective of the catalog [player] has not completed in
  /// [game], `null` once all are.
  static Objective? of(Game game, Player player) =>
      ObjectiveCatalog.firstNotDone(
        ObjectiveMigration.stateOf(game, player).completed.toSet(),
      );
}
