import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _kernelSvg = 'assets/icons/terrain/volcanic_kernel.svg';

void main() {
  final plain = TerrainType.plain.tileSvgPaths.first;
  final whole = MapProjection.standingOf((0, 0), span: 2);

  Future<void Function(Canvas)> painterOf(
    WidgetTester tester,
    Color? sealColor,
  ) async {
    final sprites = await tester.runAsync(MapSprites.load);
    final painter = MapPainter(
      visuals: [
        MapCellVisual(
          terrainSprite: plain,
          contentSprite: _kernelSvg,
          contentSpan: 2,
          sealColor: sealColor,
          revealed: true,
        ),
        for (var i = 0; i < 3; i++)
          MapCellVisual(terrainSprite: plain, revealed: true),
      ],
      columns: 2,
      sprites: sprites,
    );
    return (canvas) => painter.paint(canvas, MapProjection.sizeOf(2, 2));
  }

  testWidgets('the volcano stands on its 2x2 block, after every terrain',
      (tester) async {
    final paint = await painterOf(tester, null);
    expect(
      paint,
      paints
        ..drawImageRect() // four terrains
        ..drawImageRect()
        ..drawImageRect()
        ..drawImageRect()
        ..drawImageRect(destination: whole),
    );
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 5));
  });

  testWidgets('a held volcano adds one seal tinted with its colour',
      (tester) async {
    final paint = await painterOf(tester, AbyssColors.biolumCyan);
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 6));
    expect(
      paint,
      paints
        ..drawImageRect() // four terrains
        ..drawImageRect()
        ..drawImageRect()
        ..drawImageRect()
        ..drawImageRect(destination: whole) // the volcano
        ..drawImageRect(destination: whole), // its seal
    );
  });
}
