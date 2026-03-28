import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/screens/new_game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../helpers/fake_game_repository.dart';

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
