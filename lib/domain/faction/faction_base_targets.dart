import 'dart:math';

import '../action/attack_base_defence.dart';
import '../fight/army_planner.dart';
import '../fight/combatant.dart';
import '../game/player.dart';
import '../map/grid_position.dart';
import '../raid/raid_battle.dart';
import '../script/script_turn.dart';
import '../script/strategies/assault_moves.dart';
import 'base_intel.dart';

/// A base a faction could attack, with what its scouts reported of it.
class BaseTarget {
  final Player player;

  /// What the scouts reported of the base.
  final BaseIntel intel;

  /// How hard the defence the report shows hits back at the army.
  final double strength;

  BaseTarget(this.player, this.intel, List<Combatant> ours)
    : strength = ArmyPlanner.strength(BaseDefence.fromIntel(intel).side, ours);
}

/// The bases a faction knows and has a report on, the weakest first.
abstract final class FactionBaseTargets {
  /// Bases a faction sends a Scout to in one slot.
  static const int spiesPerSlot = 2;

  /// The bases of the fog of [turn]'s player that a scout has reported on
  /// (a fresh report, or the one a Scout brings back now), the weakest
  /// defence against [ours] first; the human first on a [grudge] slot.
  /// It spies at most [spiesPerSlot] bases a slot, the nearest first.
  static List<BaseTarget> weakestFirst(
    ScriptTurn turn,
    List<Combatant> ours, {
    bool grudge = false,
  }) {
    final Player me = turn.player;
    final Set<GridPosition> seen =
        me.revealedCellsOnLevel(RaidBattle.baseLevel).toSet();
    final List<Player> known = <Player>[
      for (final Player p in turn.game.players.values)
        if (p.id != me.id &&
            !p.hasFallen &&
            seen.contains(GridPosition(x: p.baseX, y: p.baseY)))
          p,
    ]..sort((a, b) {
      if (grudge && isHuman(turn, a) != isHuman(turn, b)) {
        return isHuman(turn, a) ? -1 : 1;
      }
      return _distance(me, a).compareTo(_distance(me, b));
    });
    final List<BaseTarget> targets = <BaseTarget>[];
    int spies = 0;
    for (final Player p in known) {
      BaseIntel? intel = me.intel[p.id];
      if (intel == null || !intel.isFresh(turn.number)) {
        if (spies >= spiesPerSlot || !turn.spyOn(p.id)) continue;
        spies++;
        intel = me.intel[p.id];
      }
      targets.add(BaseTarget(p, intel!, ours));
    }
    targets.sort((a, b) {
      if (grudge && isHuman(turn, a.player) != isHuman(turn, b.player)) {
        return isHuman(turn, a.player) ? -1 : 1;
      }
      final int byStrength = a.strength.compareTo(b.strength);
      return byStrength != 0 ? byStrength : a.player.id.compareTo(b.player.id);
    });
    return targets;
  }

  /// Whether [p] is the human of [turn]'s game.
  static bool isHuman(ScriptTurn turn, Player p) =>
      p.id == turn.game.humanPlayerId;

  static int _distance(Player a, Player b) =>
      max((a.baseX - b.baseX).abs(), (a.baseY - b.baseY).abs());
}
