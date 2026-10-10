import 'package:abyss/data/language_settings.dart';
import 'package:abyss/domain/settings/language_choice.dart';
import 'package:abyss/presentation/abyss_material_app.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/language_settings_harness.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  final settings = useLanguageSettings();

  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  /// Shows the home screen on a French device, in an app with [language]
  /// settings or in a bare one.
  Future<void> openMenu(WidgetTester tester, {LanguageSettings? language}) {
    reduceMotion(tester);
    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final menu = MainMenuScreen(repository: FakeGameRepository());
    return tester.pumpWidget(
      language == null
          ? MaterialApp(theme: AbyssTheme.create(), home: menu)
          : AbyssMaterialApp(language: language, home: menu),
    );
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Paramètres'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers no settings without app settings', (tester) async {
    await openMenu(tester);

    expect(find.byIcon(Icons.settings), findsNothing);
  });

  testWidgets('keeps the settings in the top right corner', (tester) async {
    await openMenu(tester, language: settings());

    final corner = tester.getCenter(find.byIcon(Icons.settings));
    final screen = tester.getSize(find.byType(MainMenuScreen));
    expect(corner.dx, greaterThan(screen.width * 0.8));
    expect(corner.dy, lessThan(screen.height * 0.1));
  });

  testWidgets('the settings offer the language and close', (tester) async {
    await openMenu(tester, language: settings());

    await openSettings(tester);
    expect(find.byType(LanguagePicker), findsOneWidget);
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();

    expect(find.byType(LanguagePicker), findsNothing);
  });

  testWidgets('picking English switches the menu at once', (tester) async {
    await openMenu(tester, language: settings());

    await openSettings(tester);
    await tapLanguage(tester, find.text('English'));

    expect(find.text('NEW GAME'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(settings().choice, LanguageChoice.english);
  });

  testWidgets('automatic hands the menu back to the device', (tester) async {
    await tester.runAsync(() => settings().choose(LanguageChoice.english));
    await openMenu(tester, language: settings());
    expect(find.text('NEW GAME'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tapLanguage(tester, find.text('Automatic'));

    expect(find.text('NOUVELLE PARTIE'), findsOneWidget);
  });
}
