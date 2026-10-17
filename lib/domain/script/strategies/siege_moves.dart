import '../../action/attack_base_defence.dart';
import '../../faction/faction_kernel_war.dart';
import '../../faction/kernel_siege.dart';
import '../../fight/combatant.dart';
import '../../game/player.dart';
import '../../volcano/kernel_garrison.dart';
import '../script_turn.dart';

/// The army a faction takes down to a kernel someone else holds high:
/// sized against the holder's garrison and magma rampart, the fight
/// `AttackHeldKernelAction` resolves, instead of the starting guardians.
extension SiegeMoves on ScriptTurn {
  /// Defence of the kernel the fog has shown when another living player
  /// holds it at [KernelSiege.hotLevel] or more; `null` otherwise.
  List<Combatant> Function()? hotKernelDefence() {
    final Player? holder = FactionKernelWar.holderOf(this);
    if (holder == null ||
        !KernelSiege.isHot(KernelGarrison.kernelLevelOf(holder))) {
      return null;
    }
    return () => BaseDefence.kernel(holder).side;
  }
}
