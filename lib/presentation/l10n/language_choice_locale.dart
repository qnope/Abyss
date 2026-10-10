import 'package:flutter/widgets.dart';

import '../../domain/settings/language_choice.dart';
import 'abyss_locale.dart';

/// The app locale each [LanguageChoice] asks for.
extension LanguageChoiceLocale on LanguageChoice {
  /// The forced locale, or null on [LanguageChoice.automatic] so the
  /// device language decides through [AbyssLocale.resolveList].
  Locale? get locale => switch (this) {
    LanguageChoice.automatic => null,
    LanguageChoice.french => AbyssLocale.fr,
    LanguageChoice.english => AbyssLocale.en,
    LanguageChoice.spanish => AbyssLocale.es,
  };
}
