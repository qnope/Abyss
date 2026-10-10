import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_fr.dart';

final _french = AppLocalizationsFr();

/// Shortcut to the game's texts in the language of the app.
extension L10nContext on BuildContext {
  /// The translations loaded by the app, or the French source texts when
  /// none are loaded (a bare [WidgetsApp], as in most widget tests).
  AppLocalizations get l10n => AppLocalizations.of(this) ?? _french;
}
