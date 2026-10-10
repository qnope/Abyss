import '../../domain/objective/temporary/temporary_objective_kind.dart';
import '../l10n/app_localizations.dart';

extension TemporaryObjectiveKindLabel on TemporaryObjectiveKind {
  /// Short name, for the objective banner.
  String shortLabel(AppLocalizations l10n) => switch (this) {
    TemporaryObjectiveKind.wreck => l10n.temporaryObjectiveWreckShort,
    TemporaryObjectiveKind.predators => l10n.temporaryObjectivePredatorsShort,
  };
}
