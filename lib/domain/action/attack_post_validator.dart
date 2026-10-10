import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/grid_position.dart';
import '../map/map_cell.dart';
import '../map/transition_base.dart';
import '../unit/unit_type.dart';
import 'action_failure.dart';
import 'attack_base_validator.dart';

/// The rules that say whether [player] may attack a post, a Faille or a
/// Cheminée, that another player holds.
abstract final class AttackPostValidator {
  /// Why the attack on the post of [level] at ([x], [y]) with [army] is
  /// refused, `null` if it is not. The army comes from the units of
  /// [level], as when a post is captured from its guardians.
  static ActionFailure? check(
    Game game,
    Player player,
    int level,
    int x,
    int y,
    Map<UnitType, int> army,
  ) =>
      refusal(game, player, level, x, y) ??
      AttackBaseValidator.armyFailure(player, army, level: level);

  /// Why [player] may not attack this post at all, whatever the army.
  static ActionFailure? refusal(
    Game game,
    Player player,
    int level,
    int x,
    int y,
  ) {
    if (game.levels[level] == null) return ActionFailure.mapNotGenerated;
    final MapCell cell = game.levels[level]!.cellAt(x, y);
    if (cell.content != CellContentType.transitionBase) {
      return ActionFailure.noTransitionBaseHere;
    }
    final TransitionBase? post = cell.transitionBase;
    if (post == null) return ActionFailure.baseNotFound;
    if (post.capturedBy == null) return ActionFailure.baseNotCaptured;
    if (post.capturedBy == player.id) return ActionFailure.cannotAttackSelf;
    final Player? owner = game.players[post.capturedBy];
    if (owner == null) return ActionFailure.noSuchPlayer;
    if (owner.hasFallen) return ActionFailure.playerFallen;
    if (AttackBaseValidator.isProtected(game, player) ||
        AttackBaseValidator.isProtected(game, owner)) {
      return ActionFailure.attackTooEarly;
    }
    if (player.id == game.humanPlayerId &&
        !player
            .revealedCellsOnLevel(level)
            .contains(GridPosition(x: x, y: y))) {
      return ActionFailure.baseNotRevealed;
    }
    return null;
  }
}
