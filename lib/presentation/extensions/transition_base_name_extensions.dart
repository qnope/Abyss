import '../../domain/map/transition_base.dart';
import '../../domain/map/transition_base_name.dart';
import '../../domain/map/transition_base_type.dart';
import '../l10n/app_localizations.dart';
import 'transition_base_type_extensions.dart';

/// The name of a transition base in the player's language.
extension TransitionBaseNameTexts on TransitionBaseName {
  String displayName(AppLocalizations l10n) => switch ((type, rank)) {
    (TransitionBaseType.faille, 0) => l10n.baseFailleAlpha,
    (TransitionBaseType.faille, 1) => l10n.baseFailleBeta,
    (TransitionBaseType.faille, 2) => l10n.baseFailleGamma,
    (TransitionBaseType.faille, 3) => l10n.baseFailleDelta,
    (TransitionBaseType.cheminee, 0) => l10n.baseChemineePrimary,
    (TransitionBaseType.cheminee, 1) => l10n.baseChemineeSecondary,
    (TransitionBaseType.cheminee, 2) => l10n.baseChemineeTertiary,
    _ => l10n.baseOtherName(type.displayName(l10n), rank + 1),
  };
}

extension TransitionBaseTexts on TransitionBase {
  /// Its name in the player's language, see [baseNameLabel].
  String displayName(AppLocalizations l10n) => baseNameLabel(l10n, name);
}

/// The name of a base as a save [stored] it (a passage, a capture...),
/// in the player's language. A text naming no known base is shown as is.
String baseNameLabel(AppLocalizations l10n, String stored) =>
    TransitionBaseName.parse(stored)?.displayName(l10n) ?? stored;
