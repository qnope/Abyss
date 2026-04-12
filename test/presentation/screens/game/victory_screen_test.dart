import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game_statistics.dart';
import 'package:abyss/presentation/screens/game/victory_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const statistics = GameStatistics(
    turnsPlayed: 42,
    monstersDefeated: 15,
    basesCaptured: 3,
    totalResourcesCollected: 9001,
  );

  Widget buildScreen({VoidCallback? onContinue, VoidCallback? onMenu}) {
    return MaterialApp(
      theme: AbyssTheme.create(),
      home: VictoryScreen(
        statistics: statistics,
        onContinue: onContinue ?? () {},
        onReturnToMenu: onMenu ?? () {},
      ),
    );
  }

  group('VictoryScreen', () {
    testWidgets('displays VICTOIRE ! title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('VICTOIRE !'), findsOneWidget);
    });

    testWidgets('displays subtitle', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Vous avez conquis le Noyau Volcanique !'),
        findsOneWidget,
      );
    });

    testWidgets('displays all 4 statistics with correct values',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Tours joues: 42'), findsOneWidget);
      expect(find.text('Monstres vaincus: 15'), findsOneWidget);
      expect(find.text('Bases capturees: 3'), findsOneWidget);
      expect(find.text('Ressources collectees: 9001'), findsOneWidget);
    });

    testWidgets('Continuer button calls onContinue', (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildScreen(onContinue: () => called = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuer en mode libre'));
      expect(called, isTrue);
    });

    testWidgets('Retour au menu button calls onReturnToMenu',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildScreen(onMenu: () => called = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retour au menu'));
      expect(called, isTrue);
    });

    testWidgets('volcanic kernel SVG icon is displayed', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });
}
