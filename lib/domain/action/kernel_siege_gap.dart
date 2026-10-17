import '../building/building_type.dart';
import '../faction/kernel_siege.dart';
import '../game/game.dart';
import '../game/player.dart';

/// The rest the human's kernel gets between the factions' sieges: no
/// faction may besiege it for [Difficulty.kernelGap] turns after it
/// reached [KernelSiege.hotLevel] or after the human lost a siege. The
/// kernels of factions, and the human's own sieges, are not spaced.
abstract final class KernelSiegeGap {
  /// Whether [attacker] must still wait before besieging the kernel
  /// [holder] holds.
  static bool isTooSoon(Game game, Player attacker, Player holder) {
    if (holder.id != game.humanPlayerId || attacker.id == holder.id) {
      return false;
    }
    final int gap = game.difficulty.kernelGap;
    bool recent(int? turn) => turn != null && game.turn - turn < gap;
    return recent(holder.raidState.kernelHotTurn) ||
        recent(holder.raidState.kernelSiegeLostTurn);
  }

  /// Dates the gap when [player] just built [type] up to [level], the
  /// kernel reaching [KernelSiege.hotLevel].
  static void onUpgrade(
    Game game,
    Player player,
    BuildingType type,
    int level,
  ) {
    if (type == BuildingType.volcanicKernel && level == KernelSiege.hotLevel) {
      player.raidState.kernelHotTurn = game.turn;
    }
  }
}
