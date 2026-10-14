import '../../domain/map/transition_base_type.dart';
import '../l10n/app_localizations.dart';

extension TransitionBaseTypeExtensions on TransitionBaseType {
  String displayName(AppLocalizations l10n) => switch (this) {
    TransitionBaseType.faille => l10n.transitionBaseFailleName,
    TransitionBaseType.cheminee => l10n.transitionBaseChemineeName,
  };

  String description(AppLocalizations l10n) => switch (this) {
    TransitionBaseType.faille => l10n.transitionBaseFailleDescription,
    TransitionBaseType.cheminee => l10n.transitionBaseChemineeDescription,
  };
}
