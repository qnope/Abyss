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
