import 'package:abyss/domain/game/defeat_analysis.dart';
import 'package:abyss/domain/game/game_statistics.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/widgets/game_over/defeat_cause_card.dart';
import 'package:abyss/presentation/screens/game/defeat_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const statistics = GameStatistics(
    turnsPlayed: 27,
    monstersDefeated: 40,
    basesCaptured: 1,
    totalResourcesCollected: 5000,
    raidsRepelled: 2,
    raidsLost: 4,
  );

  Widget build({
    VoidCallback? onMenu,
    VoidCallback? onExport,
    String? winnerName,
    DefeatAnalysis? analysis,
  }) => MaterialApp(
        theme: AbyssTheme.create(),
        home: DefeatScreen(
          statistics: statistics,
          fallTurn: 26,
          winnerName: winnerName,
          analysis: analysis,
          onReturnToMenu: onMenu ?? () {},
          onExport: onExport,
        ),
      );

  testWidgets('shows the title and the cause of the defeat', (tester) async {
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(find.text('DÉFAITE'), findsOneWidget);
    expect(
      find.text("Votre base est tombée à la fin du tour 26, après 3 raids "
          "perdus d'affilée."),
      findsOneWidget,
    );
  });

  testWidgets('names the faction that tamed the volcano', (tester) async {
    await tester.pumpWidget(build(winnerName: 'La Horde des Murènes'));
    await tester.pumpAndSettle();
    expect(
      find.text('La Horde des Murènes a dompté le Volcan au tour 26.'),
      findsOneWidget,
    );
    expect(find.textContaining('Votre base est tombée'), findsNothing);
  });

  testWidgets('shows the raid statistics', (tester) async {
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(find.text('Raids repoussés : 2'), findsOneWidget);
    expect(find.text('Raids perdus : 4'), findsOneWidget);
  });

  testWidgets('only offers to return to the menu', (tester) async {
    var called = false;
    await tester.pumpWidget(build(onMenu: () => called = true));
    await tester.pumpAndSettle();
    expect(find.text('Continuer en mode libre'), findsNothing);
    await tester.tap(find.text('Retour au menu'));
    expect(called, isTrue);
  });

  testWidgets('offers to export the lost game', (tester) async {
    var exported = false;
    await tester.pumpWidget(build(onExport: () => exported = true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exporter la partie'));
    expect(exported, isTrue);
  });

  testWidgets('hides the export without a way to export', (tester) async {
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(find.text('Exporter la partie'), findsNothing);
  });

  testWidgets('explains the fall when it has an analysis', (tester) async {
    await tester.pumpWidget(build(
      analysis: const DefeatAnalysis(
        raids: [
          LostRaid(
            turn: 26,
            wave: MonsterLair(
              difficulty: MonsterDifficulty.easy,
              unitCount: 20,
            ),
            defenders: 0,
          ),
        ],
        advice: DefeatAdvice.raiseAnArmy,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(DefeatCauseCard), findsOneWidget);
  });

  testWidgets('shows no explanation without an analysis', (tester) async {
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(find.byType(DefeatCauseCard), findsNothing);
  });
}
