import 'dart:io';

import 'package:abyss/data/language_settings.dart';
import 'package:abyss/domain/settings/language_choice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Gives each test of the file fresh [LanguageSettings], stored by Hive in
/// a temporary directory removed afterwards.
LanguageSettings Function() useLanguageSettings() {
  late Directory tempDir;
  late LanguageSettings settings;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_language_ui_');
    Hive.init(tempDir.path);
    settings = await LanguageSettings.open();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  return () => settings;
}

/// Picks [choice] with real file access, outside the fake clock of
/// widget tests, then lets the app redraw.
Future<void> chooseLanguage(
  WidgetTester tester,
  LanguageSettings settings,
  LanguageChoice choice,
) async {
  await tester.runAsync(() => settings.choose(choice));
  await tester.pumpAndSettle();
}

/// Taps [finder], a row of the language picker, with real file access,
/// waits until the choice it makes is written, then lets the app redraw.
Future<void> tapLanguage(WidgetTester tester, Finder finder) async {
  await tester.runAsync(() async {
    await tester.tap(finder);
    await Hive.box<String>(LanguageSettings.boxName).flush();
  });
  await tester.pumpAndSettle();
}
