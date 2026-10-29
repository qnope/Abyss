import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'map_painter_probe.dart';

void main() {
  final tiles = TerrainType.plain.tileSvgPaths;
  final String plain = tiles.first;
  final String wreck = RandomEventType.wreck.illustration;

  /// Whether [dst] is the tile box of [cell], drawn a hair larger.
  bool floors(Rect dst, (int, int) cell) {
    final box = MapProjection.tileRectOf(cell);
    return (dst.center - box.center).distance < 1e-9 &&
        dst.width > box.width &&
        dst.width < box.width + 4 &&
        (dst.height / dst.width - 0.5).abs() < 0.01;
  }

  testWidgets('each cell is floored with its own tile, a hair larger', (
    tester,
  ) async {
    final painter = await painterOf(tester, [
      for (final tile in [...tiles, tiles.first])
        MapCellVisual(terrainSprite: tile, revealed: true),
    ]);
    final sprites = MapSprites.ready!;
    PaintPatternPredicate tileOf(String tile, (int, int) cell) =>
        (method, args) =>
            method == #drawImageRect &&
            args[0] == sprites.svg(tile) &&
            floors(args[2] as Rect, cell);
    expect(
      painter,
      paints
        ..something(tileOf(tiles[0], (0, 0)))
        ..something(tileOf(tiles[1], (1, 0)))
        ..something(tileOf(tiles[2], (0, 1)))
        ..something(tileOf(tiles[0], (1, 1))),
    );
    // The dark around the diamonds is the viewport's, not a fill.
    expect(painter, paintsExactlyCountTimes(#drawRect, 0));
  });

  test('a floor not loaded yet is a plain diamond', () {
    final painter = MapPainter(
      visuals: [MapCellVisual(terrainSprite: plain, revealed: true)],
      columns: 1,
    );
    final box = MapProjection.tileRectOf((0, 0));
    expect(
      (Canvas canvas) => painter.paint(canvas, MapProjection.sizeOf(1, 1)),
      paints
        ..path(
          color: AbyssColors.plainBlue,
          includes: [box.center],
          excludes: [box.topLeft.translate(4, 4)],
        ),
    );
  });

  testWidgets('a still content stands on its cell, over every floor tile', (
    tester,
  ) async {
    final home = MapCellVisual(
        terrainSprite: plain, contentSprite: wreck, revealed: true);
    final painter = await painterOf(tester, [
      home,
      MapCellVisual(terrainSprite: plain, revealed: true),
    ]);
    final standing = MapProjection.standingOf((0, 0));
    expect(
      painter,
      paints
        ..drawImageRect()
        ..drawImageRect()
        ..drawImageRect(
            destination: MapContentDrawer.bodyOf(home, standing)),
    );
  });

}
