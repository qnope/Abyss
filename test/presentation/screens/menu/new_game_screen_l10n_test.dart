import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/menu/new_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/localized_app.dart';

Future<void> _pump(WidgetTester tester, Locale locale) => tester.pumpWidget(
  localizedApp(NewGameScreen(repository: FakeGameRepository()), locale: locale),
);

Future<void> _submitName(WidgetTester tester, String name) async {
  await tester.enterText(find.byType(TextFormField), name);
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
}

void main() {
  group('NewGameScreen in English', () {
    testWidgets('asks for the player name', (tester) async {
      await _pump(tester, AbyssLocale.en);

      expect(find.text('New Game'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.text('Player name'), findsOneWidget);
      expect(find.text('Difficulty'), findsOneWidget);
      expect(find.text('Tutorial'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('explains why a name is refused', (tester) async {
      await _pump(tester, AbyssLocale.en);

      await _submitName(tester, '');
      expect(find.text('Please enter a name'), findsOneWidget);

      await _submitName(tester, 'A');
      expect(
        find.text('The name must be at least 2 characters long'),
        findsOneWidget,
      );
    });
  });

  group('NewGameScreen in Spanish', () {
    testWidgets('asks for the player name', (tester) async {
      await _pump(tester, AbyssLocale.es);

      expect(find.text('Nueva partida'), findsOneWidget);
      expect(find.text('Escribe tu nombre'), findsOneWidget);
      expect(find.text('Dificultad'), findsOneWidget);
      expect(find.text('Tutorial'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);
    });

    testWidgets('explains why a name is refused', (tester) async {
      await _pump(tester, AbyssLocale.es);

      await _submitName(tester, '');
      expect(find.text('Escribe un nombre'), findsOneWidget);
    });
  });
}
