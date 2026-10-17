import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/grid_position.dart';
import '../map/map_cell.dart';
import '../unit/unit_type.dart';
import '../volcano/kernel_garrison.dart';
import 'action_failure.dart';
import 'attack_base_validator.dart';
import 'kernel_siege_gap.dart';

/// The rules that say whether [player] may attack the volcanic kernel
/// another player holds.
abstract final class AttackHeldKernelValidator {
  /// Why the attack on the kernel at ([x], [y]) with [army] is refused,
  /// `null` if it is not. The army comes from the volcano level.
  static ActionFailure? check(
    Game game,
    Player player,
    int x,
    int y,
    Map<UnitType, int> army,
  ) =>
      refusal(game, player, x, y) ??
      AttackBaseValidator.armyFailure(
        player,
        army,
        level: KernelGarrison.volcanoLevel,
      );

  /// Why [player] may not attack this kernel at all, whatever the army.
  static ActionFailure? refusal(Game game, Player player, int x, int y) {
    final map = game.levels[KernelGarrison.volcanoLevel];
    if (map == null) return ActionFailure.mapNotGenerated;
    final MapCell cell = map.cellAt(x, y);
    if (cell.content != CellContentType.volcanicKernel) {
      return ActionFailure.noVolcanicKernelHere;
    }
    if (cell.collectedBy == null) return ActionFailure.kernelNotCaptured;
    if (cell.collectedBy == player.id) return ActionFailure.cannotAttackSelf;
    final Player? owner = game.players[cell.collectedBy];
    if (owner == null) return ActionFailure.noSuchPlayer;
    if (owner.hasFallen) return ActionFailure.playerFallen;
    if (AttackBaseValidator.isProtected(game, player) ||
        AttackBaseValidator.isProtected(game, owner)) {
      return ActionFailure.attackTooEarly;
    }
    if (player.id == game.humanPlayerId &&
        !player
            .revealedCellsOnLevel(KernelGarrison.volcanoLevel)
            .contains(GridPosition(x: x, y: y))) {
      return ActionFailure.baseNotRevealed;
    }
    if (KernelSiegeGap.isTooSoon(game, player, owner)) {
      return ActionFailure.attackTooSoon;
    }
    return AttackBaseValidator.alreadyHit(game, player, owner);
  }
}
