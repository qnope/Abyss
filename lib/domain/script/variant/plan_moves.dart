import 'dart:math';

import '../../action/recruit_unit_action.dart';
import '../../map/cell_content_type.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';
import '../../unit/unit_type.dart';
import '../action_codec.dart';
import '../script_turn.dart';
import '../strategies/expedition_moves.dart';
import '../strategies/explore_moves.dart';
import 'plan_step.dart';
import 'replay_variant.dart';

/// Plays the steps of a human plan, on its own map or on a new one.
///
/// On a new map, a step that aims at a cell aims instead at the cell
/// that plays the same part there: the open transition base of the
/// level, the kernel, the player's own base to go down, the weakest lair,
/// the frontier cell that reveals the most.
extension PlanMoves on ScriptTurn {
  /// Plays [step]; returns whether it succeeded, so a failed step can be
  /// tried again on a later turn.
  bool playStep(PlanStep step, ReplayVariant variant) {
    final Map<String, Object?>? json = step.adapt(variant, _unitsOn(step));
    if (json == null) return false;
    if (!variant.sameMap && step.onMap) {
      switch (step.verb) {
        case 'explore':
          return _exploreOne(step.level);
        case 'collect':
          collectRevealed(step.level);
          return true;
      }
      final GridPosition? target = _targetOf(step);
      if (target == null) return _searchFor(step);
      json['x'] = target.x;
      json['y'] = target.y;
    }
    return perform(ActionCodec.decode(json)(random)).isSuccess;
  }

  Map<UnitType, int> _unitsOn(PlanStep step) => <UnitType, int>{
        for (final e in player.unitsOnLevel(step.level).entries)
          e.key: e.value.count,
      };

  GridPosition? _targetOf(PlanStep step) => switch (step.verb) {
        'attackBase' => openBase(step.level),
        'attackKernel' => openKernel(),
        'descend' || 'reinforce' => ownBase(step.level),
        'fight' => _weakestLair(step.level),
        _ => null,
      };

  GridPosition? _weakestLair(int level) {
    GridPosition? best;
    int bestPower = 1 << 30;
    for (final GridPosition p in revealedWhere(
      level,
      (MapCell c) =>
          c.content == CellContentType.monsterLair &&
          !c.isCollected &&
          c.lair != null,
    )) {
      final lair = game.levels[level]!.cellAt(p.x, p.y).lair!;
      final int power = lair.unitCount * lair.level * lair.level;
      if (power < bestPower) {
        best = p;
        bestPower = power;
      }
    }
    return best;
  }

  /// Explores [step]'s level with two scouts, recruiting them on the base
  /// level if needed, since the target it waits for is not revealed yet.
  bool _searchFor(PlanStep step) {
    if (step.verb == 'descend' || step.verb == 'reinforce') return false;
    final int level = step.level;
    final int scouts = player.unitsOnLevel(level)[UnitType.scout]?.count ?? 0;
    if (level == 1 && scouts < 2) {
      tryPerform(
        RecruitUnitAction(unitType: UnitType.scout, quantity: 2 - scouts),
      );
    }
    _exploreOne(level);
    _exploreOne(level);
    return false;
  }

  /// Sends one scout of [level] where a careful player would: towards
  /// the edges while the way down is unknown, towards the kernel below.
  bool _exploreOne(int level) {
    int scouts() => player.unitsOnLevel(level)[UnitType.scout]?.count ?? 0;
    final int before = scouts();
    explore(level, 1, (GridPosition p) {
      final int edge = max((p.x - 10).abs(), (p.y - 10).abs());
      return switch (level) {
        1 => ownBase(1) != null || openBase(1) != null ? 0 : 0.3 * edge,
        2 => openBase(2) == null ? 0.5 * edge : 0,
        _ => openKernel() == null ? -1.0 * edge : 0,
      };
    });
    return scouts() < before;
  }
}
