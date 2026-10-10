import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

typedef PaintCallback = void Function(Canvas canvas);

void main() {
  final String plain = TerrainType.plain.svgPath;
  final String wreck = RandomEventType.wreck.illustration;

  /// Paints the cells of [visuals], two per row, with the real sprites.
  Future<PaintCallback> painterOf(
    WidgetTester tester,
    List<MapCellVisual> visuals,
  ) async {
    final sprites = await tester.runAsync(MapSprites.load);
    final painter = MapPainter(visuals: visuals, columns: 2, sprites: sprites);
    return (Canvas canvas) =>
        painter.paint(canvas, const Size(2 * cellSize, cellSize));
  }

  testWidgets('a hidden wreck and its halo are drawn over the fog', (
    tester,
  ) async {
    final painter = await painterOf(tester, [
      MapCellVisual(terrainSprite: plain),
      MapCellVisual(
        terrainSprite: plain,
        contentSprite: wreck,
        glow: MapGlow.wreck,
        aboveFog: true,
      ),
    ]);
    const cell = Rect.fromLTWH(cellSize, 0, cellSize, cellSize);
    final fog = AbyssColors.abyssBlack.withValues(alpha: 0.7);
    expect(
      painter,
      paints
        ..path(color: AbyssColors.biolumCyan)
        ..path(color: fog)
        ..drawImageRect(destination: cell)
        ..drawImageRect(destination: cell.deflate(10)),
    );
    // Two terrains, the halo and the wreck: nothing drawn twice.
    expect(painter, paintsExactlyCountTimes(#drawImageRect, 4));
  });

  testWidgets('a revealed cell keeps its content under no fog', (
    tester,
  ) async {
    final painter = await painterOf(tester, [
      MapCellVisual(terrainSprite: plain, contentSprite: wreck,
          revealed: true),
      MapCellVisual(terrainSprite: plain, revealed: true),
    ]);
    expect(painter, paintsExactlyCountTimes(#drawImageRect, 3));
  });
}
