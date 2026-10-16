import '../../building/building_type.dart';
import '../../map/grid_position.dart';
import '../../map/transition_base_type.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import 'expedition_moves.dart';

/// Scouts sent down ahead of the army: through every post the player
/// holds, in the same turn, since a descent moves the units at once.
extension ScoutDescentMoves on ScriptTurn {
  /// Deepest level the scouts of the base reach this turn: one level down
  /// for each post held, from the base, whose passage building stands.
  int deepestReachable() {
    int level = 1;
    while (level < 3 && _passageOpen(level)) {
      level++;
    }
    return level;
  }

  /// Scouts the base must send so that [wanted] stand on
  /// [deepestReachable], counting those already on the way there.
  int scoutsMissingBelow(int wanted) {
    final int bottom = deepestReachable();
    if (bottom == 1 || _roadSeen(bottom)) return 0;
    return _missing(bottom, wanted);
  }

  /// Sends scouts down until [wanted] stand on [deepestReachable]; the
  /// scouts already on the way go first, the base gives the rest.
  void sendScoutsDown(int wanted) {
    final int bottom = deepestReachable();
    if (bottom == 1) return;
    final int need = wanted - _scoutsOn(bottom);
    if (need <= 0 || _roadSeen(bottom)) return;
    final int fromHome = _missing(bottom, wanted).clamp(0, _scoutsOn(1));
    if (fromHome > 0) descend(1, <UnitType, int>{UnitType.scout: fromHome});
    for (int level = 2; level < bottom; level++) {
      final int n = _scoutsOn(level) < need ? _scoutsOn(level) : need;
      descend(level, <UnitType, int>{UnitType.scout: n});
    }
  }

  /// Scouts short of [wanted] on levels 2 to [bottom] together.
  int _missing(int bottom, int wanted) {
    int below = 0;
    for (int level = 2; level <= bottom; level++) {
      below += _scoutsOn(level);
    }
    return wanted > below ? wanted - below : 0;
  }

  /// Whether the fog of [level] shows what the road needs there: the
  /// Cheminée on level 2, the volcano on level 3.
  bool _roadSeen(int level) => level == 2
      ? openBase(2) != null || ownBase(2) != null
      : kernelSeen();

  /// Whether the player holds the post of [level] and may go through it.
  bool _passageOpen(int level) {
    final GridPosition? via = ownBase(level);
    if (via == null) return false;
    final TransitionBaseType type =
        game.levels[level]!.cellAt(via.x, via.y).transitionBase!.type;
    final BuildingType passage = type == TransitionBaseType.faille
        ? BuildingType.descentModule
        : BuildingType.pressureCapsule;
    return (player.buildings[passage]?.level ?? 0) > 0 &&
        !player.isDegraded(passage);
  }

  int _scoutsOn(int level) =>
      player.unitsOnLevel(level)[UnitType.scout]?.count ?? 0;
}
