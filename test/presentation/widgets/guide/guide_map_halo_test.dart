import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/presentation/widgets/guide/guide_halo.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/level_selector.dart';
import 'package:abyss/presentation/widgets/map/map_layers.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';
import 'guide_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final faille = GuideTarget.cell(1, GridPosition(x: 2, y: 3));

  Widget map(GuideTarget? target, {int level = 1}) => guidedApp(
    GameMapView(
      gameMap: plainMap(),
      revealedCells: allPositions().toSet(),
      humanPlayerId: 'nemo',
      level: level,
    ),
    target,
  );

  group('on the map', () {
    testWidgets('the halo surrounds the tile of the target', (tester) async {
      await tester.pumpWidget(map(faille));
      expect(activeHalos, findsOneWidget);
      final Rect halo = tester.getRect(activeHalos);
      final Rect box = tester.getRect(find.byType(MapLayers));
      final scale =
          box.width / MapProjection.sizeOf(harnessMapSize, harnessMapSize).width;
      final tile = MapProjection.tileRectOf((2, 3))
          .shift(MapProjection.originOf(harnessMapSize));
      expect(halo.left - box.left, closeTo(tile.left * scale, 0.01));
      expect(halo.top - box.top, closeTo(tile.top * scale, 0.01));
      expect(halo.width, closeTo(tile.width * scale, 0.01));
      expect(halo.height, closeTo(tile.height * scale, 0.01));
    });

    testWidgets('nothing on another level, or without a cell', (tester) async {
      await tester.pumpWidget(map(faille, level: 2));
      expect(activeHalos, findsNothing);
      await tester.pumpWidget(map(const GuideTarget.map()));
      expect(activeHalos, findsNothing);
      await tester.pumpWidget(map(null));
      expect(activeHalos, findsNothing);
    });
  });

  group('on the level chips', () {
    Widget chips(GuideTarget? target, int current) => guidedApp(
      LevelSelector(
        currentLevel: current,
        unlockedLevels: const {1, 2, 3},
        onLevelSelected: (_) {},
      ),
      target,
    );

    testWidgets('the halo surrounds the level of the target', (tester) async {
      await tester.pumpWidget(
        chips(GuideTarget.cell(2, GridPosition(x: 1, y: 1)), 1),
      );
      expect(
        haloAround(find.textContaining(fr.mapLevelChip(2, '').trim())),
        findsOneWidget,
      );
      expect(activeHalos, findsOneWidget);
    });

    testWidgets('nothing once that level is shown', (tester) async {
      await tester.pumpWidget(
        chips(GuideTarget.cell(2, GridPosition(x: 1, y: 1)), 2),
      );
      expect(activeHalos, findsNothing);
      await tester.pumpWidget(chips(const GuideTarget.map(), 1));
      expect(find.byType(GuideHalo), findsWidgets);
      expect(activeHalos, findsNothing);
    });
  });
}
