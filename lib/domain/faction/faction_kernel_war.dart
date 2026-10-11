import '../fight/army_planner.dart';
import '../action/attack_base_defence.dart';
import '../action/attack_held_kernel_action.dart';
import '../fight/unit_boost.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/game_map.dart';
import '../map/grid_position.dart';
import '../map/map_cell.dart';
import '../script/script_turn.dart';
import '../unit/unit_type.dart';
import '../volcano/kernel_garrison.dart';
import '../action/fight_monster_helpers.dart';
import 'faction_war.dart';

/// A faction that lays siege to the volcanic kernel another player holds,
/// when the fighters it has on the volcano level beat the garrison and the
/// magma rampart in the same share of rehearsals as for a base
/// ([FactionWar.planner]). It only looks at a kernel its own fog has shown.
///
/// The kernel of the human is not announced: the attack is resolved at
/// once, kept in the history and reported at the end of the turn.
abstract final class FactionKernelWar {
  /// Attacks the held kernel it has seen; returns whether it attacked.
  static bool play(
    ScriptTurn turn, [
    ArmyPlanner planner = FactionWar.planner,
  ]) {
    final Player me = turn.player;
    final GameMap? map = turn.game.levels[KernelGarrison.volcanoLevel];
    final Map<UnitType, int> army = FactionWar.fightersOn(
      me,
      KernelGarrison.volcanoLevel,
    );
    if (map == null || army.isEmpty) return false;
    final UnitBoost boost = FightMonsterHelpers.unitBoostOf(
      me,
      attacking: true,
    );
    for (final GridPosition at in me.revealedCellsOnLevel(
      KernelGarrison.volcanoLevel,
    )) {
      final MapCell cell = map.cellAt(at.x, at.y);
      final Player? owner = turn.game.players[cell.collectedBy];
      if (cell.content != CellContentType.volcanicKernel ||
          owner == null ||
          owner.id == me.id ||
          owner.hasFallen) {
        continue;
      }
      if (!planner.wins(
        army,
        () => BaseDefence.kernel(owner).side,
        boost: boost,
      )) {
        continue;
      }
      return turn.tryPerform(
        AttackHeldKernelAction(
          targetX: at.x,
          targetY: at.y,
          selectedUnits: army,
          random: turn.random,
        ),
      );
    }
    return false;
  }
}
