import '../game/game.dart';
import '../game/player.dart';
import '../map/grid_position.dart';
import '../objective/installation_objectives.dart';
import '../objective/objective_migration.dart';
import '../objective/objective_state.dart';
import '../raid/noise_rules.dart';
import '../unit/unit_type.dart';
import 'action_failure.dart';

/// The rules that say whether [player] may attack the base of another.
abstract final class AttackBaseValidator {
  /// Why the attack on [targetId] with [army] is refused, `null` if it
  /// is not.
  static ActionFailure? check(
    Game game,
    Player player,
    String targetId,
    Map<UnitType, int> army,
  ) {
    final Player? target = game.players[targetId];
    if (targetId == player.id) return ActionFailure.cannotAttackSelf;
    if (target == null) return ActionFailure.noSuchPlayer;
    if (target.hasFallen) return ActionFailure.playerFallen;
    if (isProtected(game, player) || isProtected(game, target)) {
      return ActionFailure.attackTooEarly;
    }
    if (player.id == game.humanPlayerId && !_hasSeen(player, target)) {
      return ActionFailure.baseNotRevealed;
    }
    return _armyFailure(player, army);
  }

  /// Whether [player] is too new for a base war: no one attacks before
  /// the turn of the first raid, nor while the first chapter of the
  /// objectives, the tutorial, is unfinished for a player it guides.
  static bool isProtected(Game game, Player player) {
    if (game.turn < NoiseRules.firstRaidTurn) return true;
    final ObjectiveState state = ObjectiveMigration.stateOf(game, player);
    return state.tutorialEnabled &&
        !installationObjectives.every((o) => state.isCompleted(o.id));
  }

  static bool _hasSeen(Player player, Player target) => player
      .revealedCellsOnLevel(1)
      .contains(GridPosition(x: target.baseX, y: target.baseY));

  static ActionFailure? _armyFailure(Player player, Map<UnitType, int> army) {
    int total = 0;
    for (final MapEntry<UnitType, int> e in army.entries) {
      if (e.value <= 0) continue;
      if (e.value > (player.unitsOnLevel(1)[e.key]?.count ?? 0)) {
        return ActionFailure.notEnoughUnits;
      }
      total += e.value;
    }
    return total > 0 ? null : ActionFailure.noUnitSelected;
  }
}
