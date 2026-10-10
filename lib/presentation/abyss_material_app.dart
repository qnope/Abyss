import 'package:flutter/material.dart';

import '../data/language_settings.dart';
import '../domain/settings/language_choice.dart';
import 'l10n/abyss_locale.dart';
import 'l10n/language_choice_locale.dart';
import 'l10n/language_scope.dart';
import 'theme/abyss_theme.dart';

/// The game's [MaterialApp]: its theme, its translations, and the language
/// picked in [language], applied as soon as it changes.
///
/// Only the [MaterialApp] is rebuilt on a change; [home] and [builder] are
/// kept as given. [language] is reachable from every screen through
/// [LanguageScope].
class AbyssMaterialApp extends StatelessWidget {
  final LanguageSettings language;
  final Widget home;
  final TransitionBuilder? builder;

  const AbyssMaterialApp({
    super.key,
    required this.language,
    required this.home,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Built once, so a language change does not rebuild the theme.
    final theme = AbyssTheme.create();
    return LanguageScope(
      settings: language,
      child: ValueListenableBuilder<LanguageChoice>(
        valueListenable: language,
        builder:
            (context, choice, _) => MaterialApp(
              title: 'ABYSSES',
              theme: theme,
              locale: choice.locale,
              localizationsDelegates: AbyssLocale.delegates,
              supportedLocales: AbyssLocale.supported,
              localeListResolutionCallback: AbyssLocale.resolveList,
              builder: builder,
              home: home,
            ),
      ),
    );
  }
}
