import '../../domain/settings/language_choice.dart';
import '../l10n/app_localizations.dart';

/// How each [LanguageChoice] is named to the player.
extension LanguageChoiceLabel on LanguageChoice {
  /// The language named in itself ("Español" for Spanish), never
  /// translated: a player stuck in a language they cannot read still finds
  /// their own. Null for [LanguageChoice.automatic], which is no language.
  String? get endonym => switch (this) {
    LanguageChoice.automatic => null,
    LanguageChoice.french => 'Français',
    LanguageChoice.english => 'English',
    LanguageChoice.spanish => 'Español',
  };

  /// The row label: the [endonym], or "Automatique" in the app language.
  String label(AppLocalizations l10n) =>
      endonym ?? l10n.settingsLanguageAutomatic;
}
