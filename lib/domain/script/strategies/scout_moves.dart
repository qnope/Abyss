import 'dart:math';

import '../../action/recruit_unit_action.dart';
import '../../map/game_map.dart';
import '../../map/grid_position.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import 'conquest_moves.dart';
import 'expedition_moves.dart';
import 'explore_moves.dart';
import 'scout_descent_moves.dart';

/// Scouting of the conquest: scouts recruited at home, sent over each
/// level towards what the road to the volcano still has to find.
extension ScoutMoves on ScriptTurn {
  /// Scouts the base level should hold: [explorers] while it is not fully
  /// known, plus, while on the expedition, the [deepScouts] it takes down
  /// with the army. With [scoutsAhead], the scouts go down on their own:
  /// only those missing below are wanted.
  int scoutsWanted({
    required int explorers,
    required int deepScouts,
    bool scoutsAhead = false,
  }) {
    final int deep = !_onExpedition
        ? 0
        : scoutsAhead
        ? scoutsMissingBelow(deepScouts)
        : deepScouts;
    return (fullyExplored(1) ? 0 : explorers) + deep;
  }

  /// Whether a Faille is held and the kernel not taken yet.
  bool get _onExpedition =>
      ownBase(1) != null && !game.isVolcanicKernelCapturedBy(player.id);

  /// Recruits the scouts it lacks, explores the base level with
  /// [explorers] of them and levels 2 and 3 with [deepExplorers] each.
  ///
  /// Until a Faille is found, [bias] steers the base level (by default
  /// away from the middle); level 2 looks away from the middle until a
  /// Cheminée is seen, level 3 towards it until the volcano is seen. With
  /// [scoutsAhead], while on the expedition, scouts go down to the deepest
  /// level it reaches until [deepScouts] stand there, army or not.
  void scout({
    required int explorers,
    int deepScouts = ConquestMoves.expeditionScouts,
    int deepExplorers = 2,
    bool scoutsAhead = false,
    double Function(ScriptTurn turn, GridPosition target)? bias,
  }) {
    final bool expedition = _onExpedition;
    final int reserve = expedition && !scoutsAhead ? deepScouts : 0;
    final int home = _scoutsOn(1);
    final int wanted = scoutsWanted(
      explorers: explorers,
      deepScouts: deepScouts,
      scoutsAhead: scoutsAhead,
    );
    if (home < wanted) {
      tryPerform(
        RecruitUnitAction(unitType: UnitType.scout, quantity: wanted - home),
      );
    }
    // The fog only moves at the end of the turn: what is seen holds for
    // every target of the turn.
    final bool found = ownBase(1) != null || openBase(1) != null;
    final int Function(GridPosition) off1 = _fromCentreOf(1);
    explore(1, min(explorers, _scoutsOn(1) - reserve), (GridPosition p) {
      if (found) return 0;
      return bias?.call(this, p) ?? 0.3 * off1(p);
    });
    if (scoutsAhead && expedition) sendScoutsDown(deepScouts);
    final bool chemineeSeen = openBase(2) != null;
    final int Function(GridPosition) off2 = _fromCentreOf(2);
    explore(2, deepExplorers,
        (GridPosition p) => chemineeSeen ? 0 : 0.5 * off2(p));
    final bool kernelSeen = this.kernelSeen();
    final int Function(GridPosition) off3 = _fromCentreOf(3);
    explore(3, deepExplorers,
        (GridPosition p) => kernelSeen ? 0 : -1.0 * off3(p));
  }

  /// Distance of [p] to the middle of the [level] map, where the volcano
  /// stands on level 3.
  int fromCentre(int level, GridPosition p) => _fromCentreOf(level)(p);

  /// Distance to the middle of the [level] map, its centre read once.
  int Function(GridPosition) _fromCentreOf(int level) {
    final GameMap? map = game.levels[level];
    final int cx = map == null ? 10 : map.width ~/ 2;
    final int cy = map == null ? 10 : map.height ~/ 2;
    return (GridPosition p) => max((p.x - cx).abs(), (p.y - cy).abs());
  }

  int _scoutsOn(int level) =>
      player.unitsOnLevel(level)[UnitType.scout]?.count ?? 0;
}
