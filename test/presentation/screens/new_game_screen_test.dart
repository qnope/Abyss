import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/presentation/screens/new_game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';

void main() {
  setUp(() async {
    Hive.init('/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}');
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(GameAdapter());
    await Hive.openBox<Game>('games');
  });

  tearDown(() async {
    await Hive.close();
  });

  group('NewGameScreen', () {
    Widget createApp() {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: const NewGameScreen(),
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
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer un nom'), findsOneWidget);
    });

    testWidgets('validates short name', (tester) async {
      await tester.pumpWidget(createApp());

      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      expect(
        find.text('Le nom doit contenir au moins 2 caractères'),
        findsOneWidget,
      );
    });
  });
}
