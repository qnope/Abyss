import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/screens/menu/new_game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../../helpers/fake_game_repository.dart';

void main() {
  group('NewGameScreen', () {
    late FakeGameRepository repository;

    setUp(() {
      repository = FakeGameRepository();
    });

    Widget createApp() {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: NewGameScreen(repository: repository),
      );
    }

    testWidgets('shows player name input', (tester) async {
      await tester.pumpWidget(createApp());

      expect(find.text('Entrez votre nom'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);
    });

    testWidgets('offers the three difficulties, normal first', (tester) async {
      await tester.pumpWidget(createApp());

      expect(find.text('Facile'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Difficile'), findsOneWidget);
      final normal = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Normal'),
      );
      expect(normal.selected, isTrue);
    });

    testWidgets('starts the game in the difficulty picked', (tester) async {
      await tester.pumpWidget(createApp());

      await tester.enterText(find.byType(TextFormField), 'Nemo');
      await tester.tap(find.text('Difficile'));
      await tester.pump();
      await tester.tap(find.text('Commencer'));
      await tester.pump();

      expect(repository.loadAll().single.difficulty, Difficulty.hard);
    });

    Future<Game> start(WidgetTester tester) async {
      await tester.enterText(find.byType(TextFormField), 'Nemo');
      await tester.tap(find.text('Commencer'));
      await tester.pump();
      return repository.loadAll().last;
    }

    bool tutorialSwitch(WidgetTester tester) =>
        tester.widget<Switch>(find.byType(Switch)).value;

    testWidgets('offers the tutorial, checked for a first game', (
      tester,
    ) async {
      await tester.pumpWidget(createApp());

      expect(find.text('Tutoriel'), findsOneWidget);
      expect(
        find.text('Un guide t\'accompagne sur les premiers tours'),
        findsOneWidget,
      );
      expect(tutorialSwitch(tester), isTrue);
    });

    testWidgets('leaves the tutorial unchecked once a game reached turn 20', (
      tester,
    ) async {
      repository.addGame(Game.singlePlayer(Player(name: 'Old'))..turn = 20);

      await tester.pumpWidget(createApp());

      expect(tutorialSwitch(tester), isFalse);
    });

    testWidgets('starts the game with the tutorial and its tips', (
      tester,
    ) async {
      await tester.pumpWidget(createApp());

      final state = (await start(tester)).humanPlayer.savedObjectiveState!;

      expect(state.tutorialEnabled, isTrue);
      expect(state.tipsEnabled, isTrue);
    });

    testWidgets('starts the game without the tutorial once unchecked', (
      tester,
    ) async {
      await tester.pumpWidget(createApp());

      await tester.tap(find.text('Tutoriel'));
      await tester.pump();
      expect(tutorialSwitch(tester), isFalse);
      final state = (await start(tester)).humanPlayer.savedObjectiveState!;

      expect(state.tutorialEnabled, isFalse);
      expect(state.tipsEnabled, isFalse);
    });

    testWidgets('validates empty name', (tester) async {
      await tester.pumpWidget(createApp());

      await tester.tap(find.text('Commencer'));
      await tester.pump();

      expect(find.text('Veuillez entrer un nom'), findsOneWidget);
    });

    testWidgets('validates short name', (tester) async {
      await tester.pumpWidget(createApp());

      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.tap(find.text('Commencer'));
      await tester.pump();

      expect(
        find.text('Le nom doit contenir au moins 2 caractères'),
        findsOneWidget,
      );
    });
  });
}
