import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';

/// A themed [MaterialApp] showing [home] in [locale], with the game's
/// translations loaded as in the real app.
Widget localizedApp(Widget home, {Locale locale = AbyssLocale.fr}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    locale: locale,
    localizationsDelegates: AbyssLocale.delegates,
    supportedLocales: AbyssLocale.supported,
    home: home,
  );
}
