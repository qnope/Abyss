import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/presentation/extensions/cell_content_type_extensions.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_spot.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:abyss/presentation/widgets/map/map_standing_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'map_standing_probe.dart';

void main() {
  /// A row of four cells: two bobbing, one still, one pulsing.
  final row = [
    standingCell(AmbientMotion.bob),
    standingCell(AmbientMotion.bob),
    standingCell(AmbientMotion.still),
    standingCell(AmbientMotion.pulse, glow: MapGlow.post),
  ];

  MapStandingPainter painterOf(
    List<MapCellVisual> visuals, {
    MapSprites? sprites,
    ValueNotifier<double>? clock,
    TransformationController? transform,
    Size? viewport,
  }) =>
      standingPainterOf(visuals,
          columns: 4,
          sprites: sprites,
          clock: clock,
          transform: transform,
          viewport: viewport);

  /// What the content of the cell at [x] draws over, in the map's box.
  Rect boundsOf(int x) => MapContentSpot.of(row[x], x, 4)
      .bounds
      .shift(MapProjection.originOf(1));

  testWidgets('draws every standing content in view, still and moving', (
    tester,
  ) async {
    final sprites = await tester.runAsync(MapSprites.load);
    final painter = paintOf(painterOf(row, sprites: sprites));
    // Four shadows, the pulsing glow, then the four sprites.
    expect(painter, paintsExactlyCountTimes(#drawImageRect, 9));
  });

  testWidgets('lays every shadow and glow before any sprite stands', (
    tester,
  ) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    PaintPattern floor(int x) => paints
      ..drawImageRect(
          image: sprites.shadow,
          destination: MapContentSpot.of(row[x], x, 4).shadow);
    final base = sprites.svg(playerBaseSvgPath);
    expect(
      paintOf(painterOf(row, sprites: sprites)),
      floor(0)
        ..drawImageRect(image: sprites.shadow)
        ..drawImageRect(image: sprites.shadow)
        ..drawImageRect(image: sprites.pool(MapGlow.post))
        ..drawImageRect(image: sprites.shadow)
        ..drawImageRect(
            image: base, destination: MapProjection.standingOf((0, 0)))
        ..drawImageRect(image: base)
        ..drawImageRect(image: base)
        ..drawImageRect(
            image: base, destination: MapProjection.standingOf((3, 0))),
    );
  });

  testWidgets('a moving content behind a still one is drawn before it', (
    tester,
  ) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    final lair = MonsterDifficulty.easy.svgPath;
    const empty = MapCellVisual(terrainSprite: 'plain.svg', revealed: true);
    final visuals = [
      standingCell(AmbientMotion.bob, sprite: lair), empty, //
      empty, standingCell(AmbientMotion.still),
    ];
    final paint = paintOf(standingPainterOf(visuals,
        columns: 2, sprites: sprites));
    expect(
      paint,
      paints
        ..drawImageRect(image: sprites.shadow)
        ..drawImageRect(image: sprites.shadow)
        ..drawImageRect(
            image: sprites.svg(lair),
            destination: MapProjection.standingOf((0, 0)))
        ..drawImageRect(
            image: sprites.svg(playerBaseSvgPath),
            destination: MapProjection.standingOf((1, 1))),
    );
    // Two shadows and two sprites, nothing drawn twice.
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 4));
  });

  testWidgets('only draws the contents inside the viewport', (tester) async {
    final sprites = await tester.runAsync(MapSprites.load);
    // The viewport ends before the second content of the row.
    final left = painterOf(row,
        sprites: sprites, viewport: Size(boundsOf(1).left - 1, 400));
    expect(paintOf(left), paintsExactlyCountTimes(#drawImageRect, 2));
    // Panned past the third content, onto the pulsing last one.
    final panned = TransformationController(
      Matrix4.translationValues(-(boundsOf(2).right + 1), 0, 0),
    );
    final right = painterOf(row,
        sprites: sprites, transform: panned, viewport: const Size(100, 400));
    expect(paintOf(right), paintsExactlyCountTimes(#drawImageRect, 3));
  });

  test('draws nothing before the sprites are loaded', () {
    expect(paintOf(painterOf(row)), paintsNothing);
  });
}
