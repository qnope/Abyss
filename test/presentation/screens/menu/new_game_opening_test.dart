import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/extensions/guide_message_extensions.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/screens/menu/new_game_screen.dart';
import 'package:abyss/presentation/screens/menu/opening_story_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/opening/story_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  late FakeGameRepository repository;

  setUp(() {
    mockSvgAssets();
    repository = FakeGameRepository();
  });
  tearDown(clearSvgMocks);

  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    reduceMotion(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AbyssTheme.create(), home: home),
    );
  }

  Future<void> startNewGame(WidgetTester tester) async {
    await pumpApp(tester, NewGameScreen(repository: repository));
    await tester.enterText(find.byType(TextFormField), 'Nemo');
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('a new game opens on its story, before the game screen', (
    tester,
  ) async {
    await startNewGame(tester);

    expect(find.byType(OpeningStoryScreen), findsOneWidget);
    expect(find.text('Le Grand Naufrage'), findsOneWidget);
    expect(find.byType(GameScreen), findsNothing);
    expect(find.byType(NewGameScreen), findsNothing);
    expect(repository.loadAll().single.turn, 1);
  });

  testWidgets('the last card lands on the game screen, alone', (tester) async {
    await startNewGame(tester);

    for (var i = 0; i < 3; i++) {
      await tap(tester, 'Suivant');
    }
    await tap(tester, 'Plonger');

    final screen = tester.widget<GameScreen>(find.byType(GameScreen));
    expect(screen.game, same(repository.loadAll().single));
    expect(find.byType(StoryPager), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(GameScreen))).canPop(),
      isFalse,
    );
  });

  testWidgets('« Passer » lands on the game screen at once', (tester) async {
    await startNewGame(tester);

    await tap(tester, 'Passer');

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.byType(OpeningStoryScreen), findsNothing);
  });

  testWidgets('going back skips the story', (tester) async {
    await startNewGame(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);
  });

  testWidgets('the guide speaks first once the story is closed', (
    tester,
  ) async {
    await startNewGame(tester);
    expect(find.text(ObjectiveId.hqLevel1.lesson(fr)!), findsNothing);

    await tap(tester, 'Passer');

    expect(find.text(ObjectiveId.hqLevel1.lesson(fr)!), findsOneWidget);
  });

  testWidgets('continuing a saved game tells no story', (tester) async {
    repository.addGame(
      GameFactory.newSinglePlayer(playerName: 'Alice', mapSeed: 1),
    );
    await pumpApp(tester, MainMenuScreen(repository: repository));

    await tap(tester, 'CONTINUER');

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.byType(StoryPager), findsNothing);
  });
}
