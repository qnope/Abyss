import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
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

  bool mesh(Symbol method, List<dynamic> args) => method == #drawVertices;

  testWidgets('floors every cell in one draw, its tiles packed together', (
    tester,
  ) async {
    final painter = await painterOf(tester, [
      for (final tile in [...tiles, tiles.first])
        MapCellVisual(terrainSprite: tile, revealed: true),
    ]);
    expect(painter, paintsExactlyCountTimes(#drawVertices, 1));
    expect(painter, paintsExactlyCountTimes(#drawImageRect, 0));
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

  testWidgets('a hole lies flat on its diamond, over every floor tile', (
    tester,
  ) async {
    const faille = 'assets/icons/posts/faille_guarded.svg';
    final painter = await painterOf(tester, [
      MapCellVisual(terrainSprite: plain, revealed: true),
      MapCellVisual(
        terrainSprite: plain,
        contentSprite: faille,
        glow: MapGlow.post,
        revealed: true,
        motion: AmbientMotion.pulse,
      ),
    ]);
    final flat = MapContentDrawer.flatOf((1, 0));
    final cell = MapContentDrawer.cellRect(1, 2);
    expect((flat.center - cell.center).distance, lessThan(1e-9));
    expect(flat.width, inInclusiveRange(cell.width, 1.25 * cell.width));
    expect(flat.height, flat.width);
    expect(
      painter,
      paints
        ..something(mesh)
        ..save()
        ..transform(matrix4: MapProjection.isometric)
        ..drawImageRect(
            image: MapSprites.ready!.svg(faille), destination: flat)
        ..restore(),
    );
    // The hole alone: its glow pulses on the standing layer.
    expect(painter, paintsExactlyCountTimes(#drawImageRect, 1));
  });
}
