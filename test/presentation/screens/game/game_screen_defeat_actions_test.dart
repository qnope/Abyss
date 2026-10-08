import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/presentation/screens/game/defeat_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen_defeat_actions.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/replay_export_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<Game> openDefeat(WidgetTester tester) async {
    final game = GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 1)
      ..turn = 9;
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              showDefeatScreen(context, game, FakeGameRepository()),
          child: const Text('lose'),
        ),
      ),
    ));
    await tester.tap(find.text('lose'));
    await tester.pumpAndSettle();
    return game;
  }

  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.scrollUntilVisible(find.text(label), 300);
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('replaces every screen with the defeat screen',
      (tester) async {
    await openDefeat(tester);

    final screen = tester.widget<DefeatScreen>(find.byType(DefeatScreen));
    expect(screen.fallTurn, 8);
    expect(find.text('lose'), findsNothing);
    expect(Navigator.of(tester.element(find.byType(DefeatScreen))).canPop(),
        isFalse);
  });

  testWidgets('export opens the replay export dialog', (tester) async {
    final game = await openDefeat(tester);
    await tapAction(tester, 'Exporter la partie');

    final dialog =
        tester.widget<ReplayExportDialog>(find.byType(ReplayExportDialog));
    expect(dialog.game, same(game));
  });

  testWidgets('return to menu leaves only the main menu', (tester) async {
    await openDefeat(tester);
    await tapAction(tester, 'Retour au menu');

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.byType(DefeatScreen), findsNothing);
    expect(Navigator.of(tester.element(find.byType(MainMenuScreen))).canPop(),
        isFalse);
  });
}
