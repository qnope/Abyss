import '../action/attack_base_defence.dart';
import '../action/attack_cooldown.dart';
import '../action/attack_held_kernel_action.dart';
import '../action/fight_monster_helpers.dart';
import '../fight/army_planner.dart';
import '../game/player.dart';
import '../map/game_map.dart';
import '../map/grid_position.dart';
import '../map/volcano_footprint.dart';
import '../script/script_turn.dart';
import '../unit/unit_type.dart';
import '../volcano/kernel_garrison.dart';
import 'faction_war.dart';
import 'kernel_siege.dart';

/// A faction that lays siege to the volcanic kernel another player holds,
/// when the fighters it has on the volcano level beat the garrison and the
/// magma rampart in the same share of rehearsals as for a base
/// ([FactionWar.planner]). It only looks at a kernel its own fog has shown.
///
/// A faction besieges a kernel held at [KernelSiege.hotLevel] or more
/// with [besiegeHot], before any base, and one below with [besiegeCold];
/// [play] keeps the plain rule, whatever the level, for the reference
/// scripts (`ContestMoves`). None weighs a kernel its [AttackCooldown]
/// still spares.
///
/// The kernel of the human is not announced: the attack is resolved at
/// once, kept in the history and reported at the end of the turn.
abstract final class FactionKernelWar {
  /// Attacks the held kernel it has seen, whatever its level; returns
  /// whether it attacked.
  static bool play(
    ScriptTurn turn, [
    ArmyPlanner planner = FactionWar.planner,
  ]) => _besiege(turn, planner, hot: null);

  /// Attacks the held kernel it has seen below [KernelSiege.hotLevel];
  /// returns whether it attacked.
  static bool besiegeCold(ScriptTurn turn, ArmyPlanner planner) =>
      _besiege(turn, planner, hot: false);

  /// Attacks the held kernel it has seen at [KernelSiege.hotLevel] or
  /// more, unless its holder already lost [KernelSiege.wonPerTurn] sieges
  /// this turn, with the planner of [KernelSiege.plannerFor]; returns
  /// whether it attacked.
  static bool besiegeHot(ScriptTurn turn, ArmyPlanner planner) =>
      _besiege(turn, planner, hot: true);

  /// With [hot] null, any level and the plain [planner].
  static bool _besiege(
    ScriptTurn turn,
    ArmyPlanner planner, {
    required bool? hot,
  }) {
    final Player me = turn.player;
    final Map<UnitType, int> army = FactionWar.fightersOn(
      me,
      KernelGarrison.volcanoLevel,
    );
    if (army.isEmpty) return false;
    final GridPosition? at = seenKernel(turn);
    final Player? owner = at == null ? null : _holderAt(turn, at);
    if (at == null || owner == null) return false;
    final int level = KernelGarrison.kernelLevelOf(owner);
    if (hot != null && KernelSiege.isHot(level) != hot) return false;
    if (hot == true && KernelSiege.isCapped(turn.game, owner)) return false;
    if (AttackCooldown.onKernel(turn.game, me, owner)) return false;
    final ArmyPlanner judge =
        hot == true ? KernelSiege.plannerFor(planner, level) : planner;
    if (!judge.wins(
      army,
      () => BaseDefence.kernel(owner).side,
      boost: FightMonsterHelpers.unitBoostOf(me, attacking: true),
    )) {
      return false;
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

  /// The other living player holding the kernel the fog of [turn]'s
  /// player has shown, if any.
  static Player? holderOf(ScriptTurn turn) {
    final GridPosition? at = seenKernel(turn);
    return at == null ? null : _holderAt(turn, at);
  }

  static Player? _holderAt(ScriptTurn turn, GridPosition at) {
    final GameMap map = turn.game.levels[KernelGarrison.volcanoLevel]!;
    final Player? owner = turn.game.players[map.cellAt(at.x, at.y).collectedBy];
    if (owner == null || owner.id == turn.player.id || owner.hasFallen) {
      return null;
    }
    return owner;
  }

  /// The anchor of the kernel when the fog of [turn]'s player has shown
  /// it. The volcano is always laid at the centre of its level
  /// (`VolcanicKernelPlacer.place`) and revealed whole, so only its
  /// anchor is looked up (`VolcanoFootprint.anchorOf` checks it is the
  /// kernel).
  static GridPosition? seenKernel(ScriptTurn turn) {
    final GameMap? map = turn.game.levels[KernelGarrison.volcanoLevel];
    if (map == null) return null;
    final GridPosition? at = VolcanoFootprint.anchorOf(
      map,
      map.width ~/ 2,
      map.height ~/ 2,
    );
    if (at == null) return null;
    final List<GridPosition> seen = turn.player.revealedCellsOnLevel(
      KernelGarrison.volcanoLevel,
    );
    return seen.contains(at) ? at : null;
  }
}
