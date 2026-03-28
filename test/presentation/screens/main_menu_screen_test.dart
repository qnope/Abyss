import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/screens/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';

void main() {
  group('MainMenuScreen', () {
    Widget createApp() {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: const MainMenuScreen(),
      );
    }

    testWidgets('shows game title and menu buttons', (tester) async {
      await tester.pumpWidget(createApp());

      expect(find.text('ABYSSES'), findsOneWidget);
      expect(find.text('Nouvelle Partie'), findsOneWidget);
      expect(find.text('Charger une partie'), findsOneWidget);
    });

    testWidgets('navigates to new game screen', (tester) async {
      await tester.pumpWidget(createApp());

      await tester.tap(find.text('Nouvelle Partie'));
      await tester.pumpAndSettle();

      expect(find.text('Entrez votre nom'), findsOneWidget);
    });
  });
}
