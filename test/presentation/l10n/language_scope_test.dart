import 'package:abyss/data/language_settings.dart';
import 'package:abyss/domain/settings/language_choice.dart';
import 'package:abyss/presentation/abyss_material_app.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/l10n/language_choice_locale.dart';
import 'package:abyss/presentation/l10n/language_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/language_settings_harness.dart';

void main() {
  final settings = useLanguageSettings();

  test('maps each choice to its locale, automatic to none', () {
    expect(LanguageChoice.automatic.locale, isNull);
    expect(LanguageChoice.french.locale, AbyssLocale.fr);
    expect(LanguageChoice.english.locale, AbyssLocale.en);
    expect(LanguageChoice.spanish.locale, AbyssLocale.es);
  });

  testWidgets('is found from a screen pushed over the home', (tester) async {
    late BuildContext home;
    LanguageSettings? found;
    await tester.pumpWidget(
      AbyssMaterialApp(
        language: settings(),
        home: Builder(
          builder: (context) {
            home = context;
            return const SizedBox();
          },
        ),
      ),
    );

    Navigator.of(home).push(
      MaterialPageRoute<void>(
        builder: (context) {
          found = LanguageScope.maybeOf(context);
          return const SizedBox();
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(found, same(settings()));
  });

  testWidgets('rebuilds its dependents when the language changes', (
    tester,
  ) async {
    final seen = <LanguageChoice?>[];
    await tester.pumpWidget(
      AbyssMaterialApp(
        language: settings(),
        home: Builder(
          builder: (context) {
            seen.add(LanguageScope.maybeOf(context)?.choice);
            return const SizedBox();
          },
        ),
      ),
    );

    await chooseLanguage(tester, settings(), LanguageChoice.english);

    expect(seen.first, LanguageChoice.automatic);
    expect(seen.last, LanguageChoice.english);
  });

  testWidgets('is absent from an app without settings', (tester) async {
    LanguageSettings? found = settings();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            found = LanguageScope.maybeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(found, isNull);
  });
}
