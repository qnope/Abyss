import 'package:abyss/data/language_settings.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/abyss_material_app.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/language_picker.dart';
import 'package:abyss/presentation/widgets/common/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/language_settings_harness.dart';

void main() {
  final settings = useLanguageSettings();

  /// Opens the settings of a game, in an app with [language] settings or
  /// in a bare one, on a French device.
  Future<void> open(WidgetTester tester, {LanguageSettings? language}) async {
    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final game = Game.singlePlayer(Player(name: 'Nemo'));
    final home = Scaffold(
      body: Builder(
        builder:
            (context) => ElevatedButton(
              onPressed:
                  () => showSettingsDialog(
                    context,
                    game: game,
                    repository: FakeGameRepository(),
                  ),
              child: const Text('Open'),
            ),
      ),
    );
    await tester.pumpWidget(
      language == null
          ? MaterialApp(theme: AbyssTheme.create(), home: home)
          : AbyssMaterialApp(language: language, home: home),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers no language without app settings', (tester) async {
    await open(tester);

    expect(find.text('Guide du tutoriel'), findsOneWidget);
    expect(find.byType(LanguagePicker), findsNothing);
    expect(find.text('Langue'), findsNothing);
  });

  testWidgets('offers the language above the guide', (tester) async {
    await open(tester, language: settings());

    expect(find.byType(LanguagePicker), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Langue')).dy,
      lessThan(tester.getTopLeft(find.text('Guide du tutoriel')).dy),
    );
  });

  testWidgets('speaks the language picked at once', (tester) async {
    await open(tester, language: settings());

    await tester.ensureVisible(find.text('English'));
    await tapLanguage(tester, find.text('English'));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Tutorial guide'), findsOneWidget);
  });
}
