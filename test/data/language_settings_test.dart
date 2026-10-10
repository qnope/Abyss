import 'dart:io';

import 'package:abyss/data/language_settings.dart';
import 'package:abyss/domain/settings/language_choice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_language_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Closes the settings box and opens it again, as a new launch would.
  Future<LanguageSettings> relaunch() async {
    await Hive.close();
    Hive.init(tempDir.path);
    return LanguageSettings.open();
  }

  test('follows the device language until the player picks one', () async {
    final settings = await LanguageSettings.open();

    expect(settings.choice, LanguageChoice.automatic);
    expect(settings.value, LanguageChoice.automatic);
  });

  test('keeps the chosen language across launches', () async {
    final settings = await LanguageSettings.open();
    await settings.choose(LanguageChoice.spanish);

    expect(settings.choice, LanguageChoice.spanish);
    expect((await relaunch()).choice, LanguageChoice.spanish);
  });

  test('choosing automatic again forgets the stored language', () async {
    final settings = await LanguageSettings.open();
    await settings.choose(LanguageChoice.english);
    await settings.choose(LanguageChoice.automatic);

    expect(Hive.box<String>('settings').containsKey('language'), isFalse);
    expect((await relaunch()).choice, LanguageChoice.automatic);
  });

  test('tells its listeners once per real change', () async {
    final settings = await LanguageSettings.open();
    var calls = 0;
    settings.addListener(() => calls++);

    await settings.choose(LanguageChoice.french);
    await settings.choose(LanguageChoice.french);
    await settings.choose(LanguageChoice.automatic);
    await settings.choose(LanguageChoice.automatic);

    expect(calls, 2);
  });

  test('reads an unknown stored code as automatic', () async {
    final box = await Hive.openBox<String>('settings');
    await box.put('language', 'klingon');

    expect(LanguageSettings(box).choice, LanguageChoice.automatic);
  });

  test('starts over on automatic when the box cannot be opened', () async {
    // Holding the box open with another type makes the typed open throw.
    final untyped = await Hive.openBox<dynamic>('settings');
    await untyped.put('language', 42);

    final settings = await LanguageSettings.open();

    expect(settings.choice, LanguageChoice.automatic);
    await settings.choose(LanguageChoice.french);
    expect((await relaunch()).choice, LanguageChoice.french);
  });
}
