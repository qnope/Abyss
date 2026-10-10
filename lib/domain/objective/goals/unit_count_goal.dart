import '../../game/game.dart';
import '../../game/player.dart';
import '../../unit/unit_type.dart';
import '../objective_goal.dart';
import '../objective_progress.dart';

/// [count] units of [type] owned, all levels together; each unit counts
/// one step.
class UnitCountGoal extends ObjectiveGoal {
  final UnitType type;
  final int count;

  const UnitCountGoal(this.type, this.count);

  @override
  ObjectiveProgress progressOf(Game game, Player player) {
    var owned = 0;
    for (final units in player.unitsPerLevel.values) {
      owned += units[type]?.count ?? 0;
    }
    return ObjectiveProgress(owned, count);
  }
}
