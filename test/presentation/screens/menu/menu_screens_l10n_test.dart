import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/menu/load_game_screen.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/load_game_harness.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

Widget _app(Widget home, Locale locale) => MaterialApp(
  theme: AbyssTheme.create(),
  locale: locale,
  localizationsDelegates: AbyssLocale.delegates,
  supportedLocales: AbyssLocale.supported,
  home: home,
);

void main() {
  late FakeGameRepository repository;

  setUp(() {
    mockSvgAssets();
    repository = FakeGameRepository();
  });
  tearDown(clearSvgMocks);

  Future<void> show(WidgetTester t, Widget home, Locale locale) async {
    reduceMotion(t);
    await t.pumpWidget(_app(home, locale));
    await t.pumpAndSettle();
  }

  LoadGameScreen loadScreen() =>
      LoadGameScreen(repository: repository, now: () => loadScreenNow);

  testWidgets('the home screen in English', (t) async {
    repository.addGame(savedGame('Alice'));
    await show(t, MainMenuScreen(repository: repository), AbyssLocale.en);
    expect(find.text('THE DEPTHS AWAIT YOU'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('Alice · Turn 5 · Normal'), findsOneWidget);
    expect(find.text('NEW GAME'), findsOneWidget);
    expect(find.text('LOAD GAME'), findsOneWidget);
    expect(find.textContaining('Beta version', findRichText: true),
        findsOneWidget);
    expect(find.textContaining('saves may be wiped', findRichText: true),
        findsOneWidget);
  });

  testWidgets('the home screen in Spanish', (t) async {
    await show(t, MainMenuScreen(repository: repository), AbyssLocale.es);
    expect(find.text('LAS PROFUNDIDADES TE ESPERAN'), findsOneWidget);
    expect(find.text('NUEVA PARTIDA'), findsOneWidget);
    expect(find.text('CARGAR PARTIDA'), findsOneWidget);
  });

  testWidgets('no save yet, in English', (t) async {
    await show(t, loadScreen(), AbyssLocale.en);
    expect(find.text('Load a game'), findsOneWidget);
    expect(find.text('No colony detected'), findsOneWidget);
    expect(find.text('Found your first base in the abyss.'), findsOneWidget);
  });

  testWidgets('the saves in Spanish', (t) async {
    repository
      ..addGame(savedGame('Alice', hoursAgo: 2))
      ..addGame(savedGame('Bob', status: GameStatus.defeat, hoursAgo: 30));
    await show(t, loadScreen(), AbyssLocale.es);
    expect(find.text('EN CURSO'), findsOneWidget);
    expect(find.text('TERMINADAS'), findsOneWidget);
    expect(find.text('hace 2 h'), findsOneWidget);
    expect(find.text('ayer'), findsOneWidget);
    expect(find.text('DERROTA'), findsOneWidget);
    expect(find.text('Ver el balance de la partida'), findsOneWidget);
  });

  testWidgets('deleting a save in English', (t) async {
    repository.addGame(savedGame('Alice'));
    await show(t, loadScreen(), AbyssLocale.en);
    await t.tap(find.byTooltip('Options'));
    await t.pumpAndSettle();
    await t.tap(find.text('Delete'));
    await t.pumpAndSettle();
    expect(find.text('Delete this game?'), findsOneWidget);
    expect(find.text("Alice's game will be deleted for good."),
        findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
