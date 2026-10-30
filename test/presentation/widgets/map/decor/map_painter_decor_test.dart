import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/decor/map_decor_cells.dart';
import 'package:abyss/presentation/widgets/map/decor/map_decor_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const side = 8;
  final tile = TerrainType.plain.tileSvgPaths.first;
  // The front half of the map hidden.
  final visuals = [
    for (var y = 0; y < side; y++)
      for (var x = 0; x < side; x++)
        MapCellVisual(terrainSprite: tile, revealed: x + y < side),
  ];
  final fog = AbyssColors.abyssBlack.withValues(alpha: AbyssColors.fogOpacity);
  const size = Size(800, 600);

  testWidgets('stands the decor of hidden cells under the fog, the rest '
      'over it, back to front', (tester) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    final painter = MapPainter(
        visuals: visuals, columns: side, sprites: sprites, decorSalt: 2);
    final decor = mapDecorOf(visuals, side, salt: 2);
    final hidden = decor.where((d) => d.hidden).toList();
    final seen = decor.where((d) => !d.hidden).toList();
    expect(hidden, isNotEmpty);
    expect(seen, isNotEmpty);
    PaintPattern decorIn(PaintPattern pattern, List<MapDecor> items) {
      for (final item in items) {
        pattern.drawImageRect(
            image: sprites.shadow, destination: MapDecorDrawer.shadowOf(item));
      }
      for (final item in items) {
        pattern.drawImageRect(
            image: sprites.svg(item.sprite), destination: item.box);
      }
      return pattern;
    }

    // The tiles, the exploration markers, then the decor and the fog.
    final tiles = paints;
    for (var i = 0; i < visuals.length; i++) {
      tiles.drawImageRect(image: sprites.svg(tile));
    }
    final pattern = decorIn(tiles..path(), hidden)..path(color: fog);
    expect((Canvas canvas) => painter.paint(canvas, size),
        decorIn(pattern, seen));
  });

  testWidgets('stands no decor without a salt, nor before the sprites load',
      (tester) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    final bare = MapPainter(visuals: visuals, columns: side, sprites: sprites);
    expect((Canvas canvas) => bare.paint(canvas, size),
        paintsExactlyCountTimes(#drawImageRect, visuals.length));
    final loading =
        MapPainter(visuals: visuals, columns: side, decorSalt: 2);
    expect((Canvas canvas) => loading.paint(canvas, size),
        paintsExactlyCountTimes(#drawImageRect, 0));
  });

  test('repaints for another salt', () {
    MapPainter painter(int? salt) =>
        MapPainter(visuals: visuals, columns: side, decorSalt: salt);
    expect(painter(1).shouldRepaint(painter(1)), isFalse);
    expect(painter(1).shouldRepaint(painter(2)), isTrue);
    expect(painter(null).shouldRepaint(painter(2)), isTrue);
  });

  test('lays the decor on the projection of the map', () {
    final decor = mapDecorOf(visuals, side, salt: 2);
    final map = MapProjection.sizeOf(side, side);
    final origin = MapProjection.originOf(side);
    for (final item in decor) {
      expect((Offset.zero & map).contains(item.foot + origin), isTrue);
    }
  });
}
