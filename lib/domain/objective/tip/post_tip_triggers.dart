import '../../action/attack_held_kernel_action.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../history/history_entry.dart';
import '../../map/transition_base.dart';
import '../../unit/unit_type.dart';
import '../../volcano/kernel_garrison.dart';

/// The situations of the tip cards of the posts: the admiral who leads
/// their assault, a post or the kernel held, a post lost. Each check is
/// cheap: a few fields, the history, or one pass over the cells.
abstract final class PostTipTriggers {
  /// An Abyss Admiral stands on any level.
  static bool admiral(Game game, Player player) => player.unitsPerLevel.values
      .any((units) => (units[UnitType.abyssAdmiral]?.count ?? 0) > 0);

  /// A Faille or a Cheminée is held by [player].
  static bool postHeld(Game game, Player player) {
    for (final map in game.levels.values) {
      for (final cell in map.cells) {
        if (cell.transitionBase case final TransitionBase post
            when post.capturedBy == player.id) {
          return true;
        }
      }
    }
    return false;
  }

  /// The kernel is held and built: its garrison can be filled.
  static bool kernelGarrison(Game game, Player player) =>
      KernelGarrison.kernelLevelOf(player) >= 1 &&
      game.isVolcanicKernelCapturedBy(player.id);

  /// A post of [player] fell to an attacker: the entry of its defence
  /// on a Faille or a Cheminée, won by the attacker.
  static bool postLost(Game game, Player player) =>
      player.historyEntries.any(
        (entry) =>
            entry is BaseAssaultEntry &&
            entry.defending &&
            entry.victory &&
            entry.postName != null &&
            entry.postName != AttackHeldKernelAction.kernelCode,
      );
}
