import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_cell_widget.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  MapCell passageCell() => MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.passage,
        passageName: 'Faille Alpha',
      );

  BoxDecoration? findCircleDecoration(WidgetTester tester) {
    for (final container in tester.widgetList<Container>(
      find.byType(Container),
    )) {
      final decoration = container.decoration;
      if (decoration is BoxDecoration &&
          decoration.shape == BoxShape.circle) {
        return decoration;
      }
    }
    return null;
  }

  group('MapCellWidget passage overlay', () {
    testWidgets('passage cell shows purple glow when revealed',
        (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: passageCell(), isRevealed: true),
      ));

      final decoration = findCircleDecoration(tester);
      expect(decoration, isNotNull);
      expect(
        decoration!.color,
        AbyssColors.biolumPurple.withValues(alpha: 0.3),
      );
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.first.color,
          AbyssColors.biolumPurple.withValues(alpha: 0.6));
    });

    testWidgets('passage cell not revealed has no glow', (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: passageCell(), isRevealed: false),
      ));

      final decoration = findCircleDecoration(tester);
      expect(decoration, isNull);
    });
  });
}
