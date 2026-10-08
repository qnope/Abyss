import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/exploration_result.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn/exploration_summary_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(List<ExplorationResult> explorations) => MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ExplorationSummarySection(explorations: explorations),
        ),
      );

  testWidgets('sums the new cells of every exploration', (tester) async {
    await tester.pumpWidget(host([
      ExplorationResult(target: GridPosition(x: 1, y: 2), newCellsRevealed: 4),
      ExplorationResult(target: GridPosition(x: 7, y: 3), newCellsRevealed: 5),
    ]));

    expect(find.text('Exploration : 9 nouvelles cellules'), findsOneWidget);
    expect(find.text('(1, 2) → 4 cellules'), findsOneWidget);
    expect(find.text('(7, 3) → 5 cellules'), findsOneWidget);
  });

  testWidgets('lists notable content found', (tester) async {
    await tester.pumpWidget(host([
      ExplorationResult(
        target: GridPosition(x: 0, y: 6),
        newCellsRevealed: 9,
        notableContent: const [
          CellContentType.ruins,
          CellContentType.monsterLair,
        ],
      ),
    ]));

    expect(
      find.text('(0, 6) → 9 cellules (Ruines, Repaire)'),
      findsOneWidget,
    );
  });

  testWidgets('shows a zero total when nothing was explored',
      (tester) async {
    await tester.pumpWidget(host(const []));

    expect(find.text('Exploration : 0 nouvelles cellules'), findsOneWidget);
    expect(find.textContaining('→'), findsNothing);
  });
}
