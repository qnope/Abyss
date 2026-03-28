import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/presentation/screens/load_game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../helpers/fake_game_repository.dart';

void main() {
  group('LoadGameScreen', () {
    late FakeGameRepository repository;

    setUp(() {
      repository = FakeGameRepository();
    });

    Widget createApp() {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: LoadGameScreen(repository: repository),
      );
    }

    testWidgets('shows empty state when no saves', (tester) async {
      await tester.pumpWidget(createApp());

      expect(find.text('Aucune partie sauvegardée'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('shows saved games with info', (tester) async {
      repository.addGame(Game(
        player: Player(name: 'Alice'),
        turn: 5,
        createdAt: DateTime(2026, 3, 15, 14, 30),
      ));
      repository.addGame(Game(
        player: Player(name: 'Bob'),
        turn: 12,
        createdAt: DateTime(2026, 3, 20, 9, 0),
      ));

      await tester.pumpWidget(createApp());

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Tour 5'), findsOneWidget);
      expect(find.text('15/03/2026 14:30'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Tour 12'), findsOneWidget);
      expect(find.text('20/03/2026 09:00'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      repository.addGame(Game(player: Player(name: 'Alice')));

      await tester.pumpWidget(createApp());
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer la partie ?'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('deletes game after confirmation', (tester) async {
      repository.addGame(Game(player: Player(name: 'Alice')));

      await tester.pumpWidget(createApp());
      expect(find.text('Alice'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsNothing);
      expect(find.text('Aucune partie sauvegardée'), findsOneWidget);
    });

    testWidgets('cancel delete keeps game', (tester) async {
      repository.addGame(Game(player: Player(name: 'Alice')));

      await tester.pumpWidget(createApp());

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });
  });
}
