import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String plain = TerrainType.plain.svgPath;
  const String home = playerBaseSvgPath;

  /// A fresh list of the same two cells, as each rebuild of the map makes.
  List<MapCellVisual> cells() => [
        MapCellVisual(terrainSprite: plain, revealed: true),
        MapCellVisual(terrainSprite: plain, glow: MapGlow.passage),
      ];

  MapPainter painter(List<MapCellVisual> visuals, {int columns = 2}) =>
      MapPainter(visuals: visuals, columns: columns);

  group('MapCellVisual', () {
    test('visuals of the same cell are equal and hash alike', () {
      final a = cells(), b = cells();
      for (var i = 0; i < a.length; i++) {
        expect(a[i], b[i]);
        expect(a[i].hashCode, b[i].hashCode);
      }
      expect({...a, ...b}, hasLength(2));
    });

    test('any drawn difference makes visuals differ', () {
      final plainCell = MapCellVisual(terrainSprite: plain);
      final others = [
        MapCellVisual(terrainSprite: home),
        MapCellVisual(terrainSprite: plain, contentSprite: home),
        MapCellVisual(terrainSprite: plain, glow: MapGlow.wreck),
        MapCellVisual(terrainSprite: plain, dimmed: true),
        MapCellVisual(terrainSprite: plain, revealed: true),
        MapCellVisual(terrainSprite: plain, pending: true),
        MapCellVisual(terrainSprite: plain, aboveFog: true),
      ];
      for (final other in others) {
        expect(other, isNot(plainCell));
      }
    });
  });

  group('MapPainter.shouldRepaint', () {
    test('a rebuilt map showing the same cells is not repainted', () {
      expect(painter(cells()).shouldRepaint(painter(cells())), isFalse);
    });

    test('the map is repainted when a cell changes', () {
      final changed = cells()..[1] = MapCellVisual(terrainSprite: home);
      expect(painter(changed).shouldRepaint(painter(cells())), isTrue);
    });

    test('the map is repainted when its width changes', () {
      expect(
        painter(cells(), columns: 1).shouldRepaint(painter(cells())),
        isTrue,
      );
    });

    testWidgets('the map is repainted once its sprites are loaded', (
      tester,
    ) async {
      final sprites = await tester.runAsync(MapSprites.load);
      final loaded =
          MapPainter(visuals: cells(), columns: 2, sprites: sprites);
      expect(loaded.shouldRepaint(painter(cells())), isTrue);
    });
  });
}
