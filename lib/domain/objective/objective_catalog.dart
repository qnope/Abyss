import 'campaign_objectives.dart';
import 'installation_objectives.dart';
import 'objective.dart';
import 'objective_chapter.dart';
import 'objective_id.dart';

/// The main thread of objectives, from the first building to the victory.
class ObjectiveCatalog {
  const ObjectiveCatalog._();

  /// Every objective, in the order they are given.
  static final List<Objective> all = List.unmodifiable([
    ...installationObjectives,
    ...campaignObjectives,
  ]);

  static final Map<ObjectiveId, Objective> _byId = {
    for (final objective in all) objective.id: objective,
  };

  static Objective byId(ObjectiveId id) => _byId[id]!;

  /// The objectives of [chapter], in order.
  static List<Objective> ofChapter(ObjectiveChapter chapter) =>
      all.where((objective) => objective.chapter == chapter).toList();

  /// The first objective not in [completed], `null` once all are.
  static Objective? firstNotDone(Set<ObjectiveId> completed) {
    for (final objective in all) {
      if (!completed.contains(objective.id)) return objective;
    }
    return null;
  }
}
