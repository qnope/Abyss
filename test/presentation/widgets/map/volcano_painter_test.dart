import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_spot.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'map_standing_probe.dart';

const _kernelSvg = 'assets/icons/terrain/volcanic_kernel.svg';

void main() {
  final plain = TerrainType.plain.tileSvgPaths.first;
  final whole = MapProjection.standingOf((0, 0), span: 2);

  MapCellVisual volcano(Color? sealColor) => MapCellVisual(
        terrainSprite: plain,
        contentSprite: _kernelSvg,
        glow: MapGlow.volcano,
        contentSpan: 2,
        sealColor: sealColor,
        revealed: true,
        motion: AmbientMotion.pulse,
      );

  Future<void Function(Canvas)> painterOf(
    WidgetTester tester,
    Color? sealColor,
  ) async {
    final sprites = await tester.runAsync(MapSprites.load);
    return paintOf(standingPainterOf([
      volcano(sealColor),
      for (var i = 0; i < 3; i++)
        MapCellVisual(terrainSprite: plain, revealed: true),
    ], columns: 2, sprites: sprites));
  }

  testWidgets('the volcano stands on its 2x2 block, its glow pooled on it',
      (tester) async {
    final paint = await painterOf(tester, null);
    final spot = MapContentSpot.of(volcano(null), 0, 2);
    final sprites = MapSprites.ready!;
    expect(spot.glow.center, MapProjection.centreOf((0, 0), span: 2));
    expect(
      paint,
      paints
        ..drawImageRect(
            image: sprites.pool(MapGlow.volcano), destination: spot.glow)
        ..drawImageRect(image: sprites.shadow, destination: spot.shadow)
        ..drawImageRect(image: sprites.svg(_kernelSvg), destination: whole),
    );
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 3));
  });

  testWidgets('a held volcano adds one seal tinted with its colour',
      (tester) async {
    final paint = await painterOf(tester, AbyssColors.biolumCyan);
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 4));
    expect(
      paint,
      paints
        ..drawImageRect() // its glow
        ..drawImageRect() // its shadow
        ..drawImageRect(image: MapSprites.ready!.svg(_kernelSvg),
            destination: whole)
        ..drawImageRect(
            image: MapSprites.ready!.svg(volcanoSealSvgPath),
            destination: whole),
    );
  });

  test('the volcano, never on the first row, fits in the headroom', () {
    final top = MapProjection.standingOf((5, 1), span: 2).top;
    expect(top, greaterThanOrEqualTo(-MapProjection.headroom));
  });
}
