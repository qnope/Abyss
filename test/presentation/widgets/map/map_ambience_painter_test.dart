import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_ambience_painter.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String plain = TerrainType.plain.svgPath;

  MapCellVisual cell(AmbientMotion motion, {MapGlow glow = MapGlow.none}) =>
      MapCellVisual(
        terrainSprite: plain,
        contentSprite: playerBaseSvgPath,
        glow: glow,
        revealed: true,
        motion: motion,
      );

  /// A row of four cells: two bobbing, one still, one pulsing.
  final row = [
    cell(AmbientMotion.bob),
    cell(AmbientMotion.bob),
    cell(AmbientMotion.still),
    cell(AmbientMotion.pulse, glow: MapGlow.post),
  ];

  MapAmbiencePainter painterOf(
    List<MapCellVisual> visuals, {
    MapSprites? sprites,
    ValueNotifier<double>? clock,
    TransformationController? transform,
    Size viewport = const Size(4 * cellSize, cellSize),
  }) =>
      MapAmbiencePainter(
        visuals: visuals,
        columns: 4,
        sprites: sprites,
        clock: clock ?? ValueNotifier(1.3),
        transform: transform ?? TransformationController(),
        viewport: viewport,
      );

  void Function(Canvas) paintOf(MapAmbiencePainter painter) =>
      (canvas) => painter.paint(canvas, const Size(4 * cellSize, cellSize));

  group('MapAmbiencePainter', () {
    testWidgets('draws every moving content in view, not the still ones', (
      tester,
    ) async {
      final sprites = await tester.runAsync(MapSprites.load);
      final painter = painterOf(row, sprites: sprites);
      // Two bobbing sprites, then the pulsing glow and its sprite.
      expect(paintOf(painter), paintsExactlyCountTimes(#drawImageRect, 4));
    });

    testWidgets('only draws the cells inside the viewport', (tester) async {
      final sprites = await tester.runAsync(MapSprites.load);
      final left = painterOf(row,
          sprites: sprites, viewport: const Size(1.5 * cellSize, cellSize));
      expect(paintOf(left), paintsExactlyCountTimes(#drawImageRect, 2));
      final panned = TransformationController(
        Matrix4.translationValues(-3 * cellSize, 0, 0),
      );
      final right = painterOf(row,
          sprites: sprites,
          transform: panned,
          viewport: const Size(cellSize, cellSize));
      expect(paintOf(right), paintsExactlyCountTimes(#drawImageRect, 2));
    });

    test('draws nothing before the sprites are loaded', () {
      expect(paintOf(painterOf(row)), paintsNothing);
    });

    test('repaints when the clock ticks or the map is panned', () {
      final clock = ValueNotifier(0.0);
      final transform = TransformationController();
      final painter = painterOf(row, clock: clock, transform: transform);
      var heard = 0;
      painter.addListener(() => heard++);
      clock.value = 0.5;
      transform.value = Matrix4.translationValues(-10, 0, 0);
      expect(heard, 2);
    });

    test('a rebuild showing the same cells is not repainted', () {
      final clock = ValueNotifier(0.0);
      final transform = TransformationController();
      MapAmbiencePainter build({Size viewport = const Size(10, 10)}) =>
          painterOf([...row],
              clock: clock, transform: transform, viewport: viewport);
      expect(build().shouldRepaint(build()), isFalse);
      expect(build().shouldRepaint(build(viewport: const Size(20, 10))),
          isTrue);
      expect(build().shouldRepaint(painterOf(row, transform: transform)),
          isTrue);
    });
  });

  group('animatedCells', () {
    test('lists moving cells, those above the fog last', () {
      final beacon = MapCellVisual(
          terrainSprite: plain, aboveFog: true, motion: AmbientMotion.sway);
      final volcano = MapCellVisual(
          terrainSprite: plain, contentSpan: 2, motion: AmbientMotion.pulse);
      final cells = [beacon, volcano, cell(AmbientMotion.still), ...row];
      expect(animatedCells(cells), [3, 4, 6, 1, 0]);
    });
  });

  group('visibleMapRect', () {
    test('is the viewport seen through the inverse of the transform', () {
      final zoomed = Matrix4.translationValues(-48, -24, 0)
        ..scaleByDouble(2, 2, 1, 1);
      expect(visibleMapRect(zoomed, const Size(200, 100)),
          const Rect.fromLTWH(24, 12, 100, 50));
    });
  });
}
