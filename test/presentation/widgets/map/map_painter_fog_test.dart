import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'map_painter_probe.dart';

void main() {
  final tiles = TerrainType.plain.tileSvgPaths;
  final String plain = tiles.first;
  final String wreck = RandomEventType.wreck.illustration;
  final fog = AbyssColors.abyssBlack.withValues(alpha: 0.7);

  testWidgets('the fog covers the diamonds of hidden cells, softly', (
    tester,
  ) async {
    final painter = await painterOf(tester, [
      MapCellVisual(terrainSprite: plain),
      MapCellVisual(terrainSprite: plain, revealed: true),
    ]);
    final hidden = MapProjection.tileRectOf((0, 0));
    expect(
      painter,
      paints
        ..path(color: AbyssColors.biolumCyan)
        ..path(
          color: fog,
          hasMaskFilter: true,
          includes: [hidden.center, hidden.centerLeft.translate(2, 0)],
          excludes: [
            hidden.topLeft.translate(4, 4),
            MapProjection.centreOf((1, 0)),
          ],
        ),
    );
  });

  testWidgets('a cell a scout explores is outlined in a diamond', (
    tester,
  ) async {
    final painter = await painterOf(tester, [
      MapCellVisual(terrainSprite: plain, revealed: true),
      MapCellVisual(terrainSprite: plain, revealed: true, pending: true),
    ]);
    final pending = MapProjection.tileRectOf((1, 0));
    expect(
      painter,
      paints
        ..path(
          color: AbyssColors.biolumCyan,
          style: PaintingStyle.stroke,
          includes: [pending.center],
          excludes: [
            pending.bottomRight.translate(-4, -4),
            MapProjection.centreOf((0, 0)),
          ],
        ),
    );
  });

  testWidgets('standing contents, still or moving, are left to the '
      'standing layer', (tester) async {
    final painter = await painterOf(tester, [
      MapCellVisual(terrainSprite: plain, contentSprite: wreck,
          revealed: true),
      MapCellVisual(terrainSprite: plain, contentSprite: wreck,
          revealed: true, motion: AmbientMotion.bob),
      MapCellVisual(terrainSprite: plain, contentSprite: wreck,
          glow: MapGlow.wreck, aboveFog: true, motion: AmbientMotion.sway),
      MapCellVisual(terrainSprite: plain, revealed: true,
          factionColor: AbyssColors.coralPink),
    ]);
    // The four terrains only: no content, no halo, no ring.
    expect(painter, paintsExactlyCountTimes(#drawImageRect, 4));
    expect(painter, paintsExactlyCountTimes(#drawOval, 0));
  });
}
