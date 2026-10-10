import 'package:abyss/data/language_settings.dart';
import 'package:abyss/domain/settings/language_choice.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/common/language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../../../helpers/language_settings_harness.dart';
import '../../../helpers/localized_app.dart';

const _endonyms = ['Français', 'English', 'Español'];

ListTile _row(WidgetTester tester, String label) => tester.widget(
  find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
);

void main() {
  final settings = useLanguageSettings();

  Future<void> show(WidgetTester tester, {Locale locale = AbyssLocale.fr}) =>
      tester.pumpWidget(
        localizedApp(
          Scaffold(body: LanguagePicker(settings: settings())),
          locale: locale,
        ),
      );

  testWidgets('offers automatic and the three languages', (tester) async {
    await show(tester);

    expect(find.text('Langue'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(4));
    expect(find.text('Automatique'), findsOneWidget);
    expect(find.text("Langue de l'appareil"), findsOneWidget);
    for (final name in _endonyms) {
      expect(find.text(name), findsOneWidget);
    }
  });

  for (final (locale, title, automatic, hint) in const [
    (AbyssLocale.en, 'Language', 'Automatic', 'Device language'),
    (AbyssLocale.es, 'Idioma', 'Automático', 'Idioma del dispositivo'),
  ]) {
    testWidgets('names each language in itself, in ${locale.languageCode}', (
      tester,
    ) async {
      await show(tester, locale: locale);

      expect(find.text(title), findsOneWidget);
      expect(find.text(automatic), findsOneWidget);
      expect(find.text(hint), findsOneWidget);
      for (final name in _endonyms) {
        expect(find.text(name), findsOneWidget);
      }
    });
  }

  testWidgets('marks the current choice only', (tester) async {
    await show(tester);

    expect(_row(tester, 'Automatique').selected, isTrue);
    for (final name in _endonyms) {
      expect(_row(tester, name).selected, isFalse);
    }
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('follows a choice made elsewhere', (tester) async {
    await show(tester);

    await chooseLanguage(tester, settings(), LanguageChoice.spanish);

    expect(_row(tester, 'Español').selected, isTrue);
    expect(_row(tester, 'Automatique').selected, isFalse);
  });

  testWidgets('tapping a language picks it and saves it', (tester) async {
    await show(tester);

    await tapLanguage(tester, find.text('English'));

    expect(settings().choice, LanguageChoice.english);
    expect(_row(tester, 'English').selected, isTrue);
    final saved = await tester.runAsync(() async {
      await Hive.close();
      return (await LanguageSettings.open()).choice;
    });
    expect(saved, LanguageChoice.english);
  });

  testWidgets('tapping automatic hands back to the device', (tester) async {
    await tester.runAsync(() => settings().choose(LanguageChoice.french));
    await show(tester);

    await tapLanguage(tester, find.text('Automatique'));

    expect(settings().choice, LanguageChoice.automatic);
    expect(_row(tester, 'Automatique').selected, isTrue);
  });
}
