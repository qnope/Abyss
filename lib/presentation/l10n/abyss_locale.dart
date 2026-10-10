import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// The languages the game speaks, and how the device picks one.
///
/// French and Spanish devices get their own language; every other device
/// falls back to English.
abstract final class AbyssLocale {
  static const fr = Locale('fr');
  static const en = Locale('en');
  static const es = Locale('es');

  static const supported = [fr, en, es];

  static const delegates = AppLocalizations.localizationsDelegates;

  /// The game language for a device whose preferred languages are
  /// [deviceLocales], most preferred first. Only the first one counts.
  static Locale resolve(List<Locale>? deviceLocales) {
    final language = deviceLocales?.firstOrNull?.languageCode;
    return supported.firstWhere(
      (locale) => locale.languageCode == language,
      orElse: () => en,
    );
  }

  /// [resolve] in the shape of [WidgetsApp.localeListResolutionCallback].
  static Locale resolveList(
    List<Locale>? deviceLocales,
    Iterable<Locale> supportedLocales,
  ) => resolve(deviceLocales);
}
