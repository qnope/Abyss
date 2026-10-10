import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/settings_dialog.dart';

import '../../../helpers/fake_game_repository.dart';

void main() {
  group('showSettingsDialog', () {
    late Game game;
    late FakeGameRepository repository;
    SettingsDialogResult? captured;

    setUp(() {
      game = Game.singlePlayer(
        Player(name: 'Nemo')
          ..savedObjectiveState = ObjectiveState(tutorialEnabled: true),
      );
      repository = FakeGameRepository();
      captured = null;
    });

    ObjectiveState state() => game.humanPlayer.savedObjectiveState!;

    bool switchOf(WidgetTester tester, String title) => tester
        .widget<Switch>(
          find.descendant(
            of: find.widgetWithText(ListTile, title),
            matching: find.byType(Switch),
          ),
        )
        .value;

    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AbyssTheme.create(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  captured = await showSettingsDialog(
                    context,
                    game: game,
                    repository: repository,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Paramètres'), findsOneWidget);
    }

    Future<SettingsDialogResult?> openAndTap(
      WidgetTester tester,
      String buttonLabel,
    ) async {
      await open(tester);
      await tester.tap(find.text(buttonLabel));
      await tester.pumpAndSettle();
      return captured;
    }

    testWidgets('tapping Annuler returns cancel', (tester) async {
      final result = await openAndTap(tester, 'Annuler');
      expect(result, SettingsDialogResult.cancel);
    });

    testWidgets('tapping Voir l\'historique returns openHistory',
        (tester) async {
      final result = await openAndTap(tester, 'Voir l\'historique');
      expect(result, SettingsDialogResult.openHistory);
    });

    testWidgets('tapping Sauvegarder et quitter returns saveAndQuit',
        (tester) async {
      final result = await openAndTap(tester, 'Sauvegarder et quitter');
      expect(result, SettingsDialogResult.saveAndQuit);
    });

    testWidgets('dismissing the dialog defaults to cancel', (tester) async {
      await open(tester);

      // Tap outside the dialog to dismiss it.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(captured, SettingsDialogResult.cancel);
    });

    testWidgets('shows the guide and tips switches of the game', (
      tester,
    ) async {
      await open(tester);

      expect(switchOf(tester, 'Guide du tutoriel'), isTrue);
      expect(switchOf(tester, 'Conseils'), isFalse);
    });

    testWidgets('switching the guide off saves the game', (tester) async {
      await open(tester);

      await tester.tap(find.text('Guide du tutoriel'));
      await tester.pumpAndSettle();

      expect(switchOf(tester, 'Guide du tutoriel'), isFalse);
      expect(state().tutorialEnabled, isFalse);
      expect(repository.saveCallCount, 1);
      expect(repository.loadAll().single, same(game));
    });

    testWidgets('switching the tips on saves the game', (tester) async {
      await open(tester);

      await tester.tap(find.text('Conseils'));
      await tester.pumpAndSettle();

      expect(switchOf(tester, 'Conseils'), isTrue);
      expect(state().tipsEnabled, isTrue);
      expect(state().tutorialEnabled, isTrue);
      expect(repository.saveCallCount, 1);
    });
  });
}
