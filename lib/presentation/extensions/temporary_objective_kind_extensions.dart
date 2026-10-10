import '../../domain/objective/temporary/temporary_objective_kind.dart';

extension TemporaryObjectiveKindLabel on TemporaryObjectiveKind {
  /// Short French name, for the objective banner.
  String get shortLabel => switch (this) {
    TemporaryObjectiveKind.wreck => 'Épave',
    TemporaryObjectiveKind.predators => 'Prédateurs',
  };
}
