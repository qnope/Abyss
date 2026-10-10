import 'package:abyss/domain/settings/language_choice.dart';
import 'package:abyss/presentation/abyss_material_app.dart';
import 'package:abyss/presentation/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/language_settings_harness.dart';

Widget _start() =>
    Builder(builder: (context) => Text(context.l10n.newGameStart));

void main() {
  final settings = useLanguageSettings();

  testWidgets('switches language as soon as the player picks one', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final language = settings();

    await tester.pumpWidget(
      AbyssMaterialApp(language: language, home: _start()),
    );
    expect(find.text('Start'), findsOneWidget);

    await chooseLanguage(tester, language, LanguageChoice.french);
    expect(find.text('Commencer'), findsOneWidget);

    await chooseLanguage(tester, language, LanguageChoice.english);
    expect(find.text('Start'), findsOneWidget);

    await chooseLanguage(tester, language, LanguageChoice.spanish);
    expect(find.text('Empezar'), findsOneWidget);

    await chooseLanguage(tester, language, LanguageChoice.automatic);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('follows the device language on automatic', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es', 'MX')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      AbyssMaterialApp(language: settings(), home: _start()),
    );

    expect(find.text('Empezar'), findsOneWidget);
  });

  testWidgets('opens in the language picked at a previous launch', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es', 'MX')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.runAsync(() => settings().choose(LanguageChoice.french));

    await tester.pumpWidget(
      AbyssMaterialApp(language: settings(), home: _start()),
    );

    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('wraps every screen with the given builder', (tester) async {
    await tester.pumpWidget(
      AbyssMaterialApp(
        language: settings(),
        home: _start(),
        builder:
            (context, child) => Column(
              children: [const Text('layer'), Expanded(child: child!)],
            ),
      ),
    );

    expect(find.text('layer'), findsOneWidget);
  });
}
