import '../game/game.dart';
import '../game/player.dart';
import '../unit/unit_type.dart';
import 'attack_base_entries.dart';
import 'attack_base_result.dart';
import 'attack_cooldown.dart';
import 'kernel_takeover.dart';

/// The end of a siege of a held kernel: the siege, whatever its outcome,
/// starts the [AttackCooldown] of the attacker; a win brings the kernel
/// down to the level [AttackBaseResult.damage] gives ([KernelTakeover]);
/// then the owner keeps the report of the fight.
abstract final class KernelAssaultSettlement {
  /// Settles [result] of [attacker]'s siege of the kernel [owner] holds
  /// at ([x], [y]), reported under [postName].
  static void settle({
    required Game game,
    required int x,
    required int y,
    required Player attacker,
    required Player owner,
    required AttackBaseResult result,
    required String postName,
  }) {
    AttackCooldown.kernelAttacked(game.turn, attacker, owner);
    final Map<UnitType, int> lost =
        result.victory
            ? KernelTakeover.apply(
              game: game,
              x: x,
              y: y,
              attacker: attacker,
              owner: owner,
              after: result.damage.rampartAfter,
            )
            : const <UnitType, int>{};
    owner.addHistoryEntry(
      AttackBaseEntries.forDefender(
        game.turn,
        attacker.name,
        result,
        postName: postName,
        lostWithPost: lost,
      ),
    );
  }
}
