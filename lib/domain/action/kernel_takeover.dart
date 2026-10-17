import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/game_map.dart';
import '../unit/unit_type.dart';
import '../volcano/kernel_garrison.dart';

/// What a won attack does to a held kernel: it loses one level and, when
/// it reaches level 0, the attacker holds it and the garrison of the old
/// owner is lost with it. The owner keeps the turn of its loss, which
/// spaces the next sieges of the human (`KernelSiegeGap`).
abstract final class KernelTakeover {
  /// Takes [owner]'s kernel at ([x], [y]) of the volcano level of [game]
  /// down to [after]; returns the units of the garrison the owner lost.
  static Map<UnitType, int> apply({
    required Game game,
    required int x,
    required int y,
    required Player attacker,
    required Player owner,
    required int after,
  }) {
    owner.raidState.kernelSiegeLostTurn = game.turn;
    owner.buildings[BuildingType.volcanicKernel]!.level = after;
    if (after > 0) return const <UnitType, int>{};
    final Map<UnitType, int> lost = KernelGarrison.of(owner);
    for (final unit in KernelGarrison.stockOf(owner).values) {
      unit.count = 0;
    }
    final GameMap map = game.levels[KernelGarrison.volcanoLevel]!;
    map.setCell(x, y, map.cellAt(x, y).copyWith(collectedBy: attacker.id));
    return lost;
  }
}
