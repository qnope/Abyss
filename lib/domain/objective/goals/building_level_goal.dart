import '../../building/building_type.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../objective_goal.dart';
import '../objective_progress.dart';

/// The [type] building raised to [level]; each level counts one step.
class BuildingLevelGoal extends ObjectiveGoal {
  final BuildingType type;
  final int level;

  const BuildingLevelGoal(this.type, this.level);

  @override
  ObjectiveProgress progressOf(Game game, Player player) =>
      ObjectiveProgress(player.buildings[type]?.level ?? 0, level);
}
