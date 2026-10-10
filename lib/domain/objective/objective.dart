import '../game/game.dart';
import '../game/player.dart';
import '../resource/resource_type.dart';
import 'objective_chapter.dart';
import 'objective_goal.dart';
import 'objective_id.dart';
import 'objective_progress.dart';

/// One step of the main thread: what to reach, and what it pays. The
/// presentation words it after its [id] and its [goal].
class Objective {
  final ObjectiveId id;
  final ObjectiveChapter chapter;

  /// Resources credited once the objective is reached.
  final Map<ResourceType, int> reward;

  final ObjectiveGoal goal;

  const Objective({
    required this.id,
    required this.chapter,
    required this.reward,
    required this.goal,
  });

  /// Where [player] stands on this objective in [game].
  ObjectiveProgress progressOf(Game game, Player player) =>
      goal.progressOf(game, player);

  bool isDone(Game game, Player player) => progressOf(game, player).isDone;
}
