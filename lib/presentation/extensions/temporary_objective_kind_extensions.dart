import '../../domain/objective/temporary/temporary_objective.dart';
import '../../domain/objective/temporary/temporary_objective_kind.dart';
import '../l10n/app_localizations.dart';

extension TemporaryObjectiveKindLabel on TemporaryObjectiveKind {
  /// Short name, for the objective banner.
  String shortLabel(AppLocalizations l10n) => switch (this) {
    TemporaryObjectiveKind.wreck => l10n.temporaryObjectiveWreckShort,
    TemporaryObjectiveKind.predators => l10n.temporaryObjectivePredatorsShort,
  };
}

extension TemporaryObjectiveTitle on TemporaryObjective {
  /// What the player is asked to do, e.g. "Repousse le banc de prédateurs".
  String displayTitle(AppLocalizations l10n) => switch (kind) {
    TemporaryObjectiveKind.wreck => l10n.temporaryObjectiveWreckTitle(lastTurn),
    TemporaryObjectiveKind.predators => l10n.temporaryObjectivePredatorsTitle,
  };
}
