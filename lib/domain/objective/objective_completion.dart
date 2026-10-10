import '../resource/resource_type.dart';
import 'objective.dart';

/// An objective completed at the end of a turn, and what its reward
/// actually added once capped by the storage.
class ObjectiveCompletion {
  final Objective objective;

  /// Resources added, by type; less than [Objective.reward] when the
  /// storage was nearly full.
  final Map<ResourceType, int> credited;

  const ObjectiveCompletion({required this.objective, required this.credited});
}
