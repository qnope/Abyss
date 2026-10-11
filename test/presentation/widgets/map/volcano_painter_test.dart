import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _kernelSvg = 'assets/icons/terrain/volcanic_kernel.svg';

void main() {
  final plain = TerrainType.plain.svgPath;
  const whole = Rect.fromLTWH(0, 0, 2 * cellSize, 2 * cellSize);

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
    return (canvas) => painter.paint(canvas, const Size(2 * cellSize, 2 * cellSize));
  }

  testWidgets('the volcano is drawn over the whole 2x2, after every terrain',
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
