import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/menu/count_badge.dart';
import 'package:abyss/presentation/widgets/menu/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

Game _game(
  String name, {
  int turn = 1,
  GameStatus status = GameStatus.playing,
  Difficulty difficulty = Difficulty.normal,
  int playedOn = 1,
}) =>
    GameFactory.newSinglePlayer(
        playerName: name,
        mapSeed: 1,
        difficulty: difficulty,
      )
      ..turn = turn
      ..status = status
      ..savedLastPlayedAt = DateTime(2026, 10, playedOn);

MenuButton _button(WidgetTester tester, String label) => tester.widget(
  find.ancestor(of: find.text(label), matching: find.byType(MenuButton)),
);

void main() {
  late FakeGameRepository repository;

  setUp(() {
    mockSvgAssets();
    repository = FakeGameRepository();
  });
  tearDown(clearSvgMocks);

  Future<void> openMenu(WidgetTester tester) async {
    reduceMotion(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: MainMenuScreen(repository: repository),
      ),
    );
  }

  testWidgets('shows the title and the menu', (tester) async {
    await openMenu(tester);
    expect(find.text('ABYSSES'), findsOneWidget);
    expect(find.text('LES PROFONDEURS VOUS ATTENDENT'), findsOneWidget);
    expect(find.text('NOUVELLE PARTIE'), findsOneWidget);
    expect(find.text('CHARGER UNE PARTIE'), findsOneWidget);
    expect(
      find.textContaining('Version bêta', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('without saves, offers no continue and no count', (tester) async {
    await openMenu(tester);
    expect(find.text('CONTINUER'), findsNothing);
    expect(find.byType(CountBadge), findsNothing);
    expect(
      _button(tester, 'NOUVELLE PARTIE').variant,
      MenuButtonVariant.primary,
    );
  });

  testWidgets('finished games are not continued', (tester) async {
    repository
      ..addGame(_game('Cousteau', status: GameStatus.victory))
      ..addGame(_game('Nemo', status: GameStatus.defeat));
    await openMenu(tester);
    expect(find.text('CONTINUER'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('continues the latest game played still in progress', (
    tester,
  ) async {
    repository
      ..addGame(_game('Marin', turn: 3, playedOn: 2))
      ..addGame(_game('Alice', turn: 14, playedOn: 5))
      ..addGame(_game('Cousteau', status: GameStatus.victory, playedOn: 9));
    await openMenu(tester);
    expect(find.text('CONTINUER'), findsOneWidget);
    expect(find.text('Alice · Tour 14 · Normal'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(
      _button(tester, 'NOUVELLE PARTIE').variant,
      MenuButtonVariant.outlined,
    );
  });

  testWidgets('continue resumes that game on its own', (tester) async {
    final alice = _game('Alice', turn: 14, playedOn: 5);
    repository.addGame(alice);
    await openMenu(tester);
    await tester.tap(find.text('CONTINUER'));
    await tester.pumpAndSettle();

    final screen = tester.widget<GameScreen>(find.byType(GameScreen));
    expect(screen.game, same(alice));
    expect(find.byType(MainMenuScreen), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(GameScreen))).canPop(),
      isFalse,
    );
  });

  testWidgets('opens the new game screen', (tester) async {
    await openMenu(tester);
    await tester.tap(find.text('NOUVELLE PARTIE'));
    await tester.pumpAndSettle();
    expect(find.text('Entrez votre nom'), findsOneWidget);
  });

  testWidgets('refreshes when coming back from the load screen', (
    tester,
  ) async {
    repository.addGame(_game('Alice', turn: 14));
    await openMenu(tester);
    await tester.tap(find.text('CHARGER UNE PARTIE'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer').last);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('CONTINUER'), findsNothing);
    expect(find.byType(CountBadge), findsNothing);
  });
}
