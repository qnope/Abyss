import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/map_cell.dart';
import '../map/transition_base.dart';
import '../unit/unit_type.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'attack_transition_base_helpers.dart';
import 'attack_transition_base_result.dart';

/// The rules that say whether [Player] may assault the guardians of a
/// Faille or a Cheminée nobody holds yet.
abstract final class AttackTransitionBaseValidator {
  /// Success when [player] may send [units] of [level] against the post at
  /// ([x], [y]); otherwise the failure that says why not.
  static ActionResult check(
    Game game,
    Player player,
    int level,
    int x,
    int y,
    Map<UnitType, int> units,
  ) {
    final map = game.levels[level];
    if (map == null) {
      return const AttackTransitionBaseResult.failure(
        ActionFailure.mapNotGenerated,
      );
    }
    final MapCell cell = map.cellAt(x, y);
    if (cell.content != CellContentType.transitionBase) {
      return const AttackTransitionBaseResult.failure(
        ActionFailure.noTransitionBaseHere,
      );
    }
    final TransitionBase? base = cell.transitionBase;
    if (base == null) {
      return const AttackTransitionBaseResult.failure(
        ActionFailure.baseNotFound,
      );
    }
    if (base.isCaptured) {
      return const AttackTransitionBaseResult.failure(
        ActionFailure.baseAlreadyCaptured,
      );
    }
    final unitErr = AttackTransitionBaseHelpers.validateUnits(
      player, level, units,
    );
    if (unitErr != null) return unitErr;
    return const ActionResult.success();
  }
}
