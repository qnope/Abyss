import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/presentation/extensions/cell_content_type_extensions.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/ambience/creature_sheet.dart';
import 'package:abyss/presentation/widgets/ambience/creature_undulation.dart';
import 'package:abyss/presentation/widgets/map/map_ambience_painter.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final _hard = MonsterDifficulty.hard.svgPath;

void main() {
  const seconds = 1.3;
  MapCellVisual bobbing(String sprite) => MapCellVisual(
        terrainSprite: TerrainType.plain.svgPath,
        contentSprite: sprite,
        revealed: true,
        motion: AmbientMotion.bob,
      );

  /// Paints one cell showing [sprite], the creature sheets being [sheets].
  Future<void Function(Canvas)> paintOf(WidgetTester tester, String sprite,
      Map<String, CreatureSheet> sheets) async {
    final sprites = await tester.runAsync(MapSprites.load);
    final painter = MapAmbiencePainter(
      visuals: [bobbing(sprite)],
      columns: 1,
      sprites: sprites,
      clock: ValueNotifier(seconds),
      transform: TransformationController(),
      viewport: const Size(cellSize, cellSize),
      creatureSheetOf: (path) => sheets[path],
    );
    return (canvas) => painter.paint(canvas, const Size(cellSize, cellSize));
  }

  Future<CreatureSheet> sheetOf(WidgetTester tester) async {
    final atlas = await tester.runAsync(() => createTestImage(
        width: 8, height: 6, cache: false));
    return CreatureSheet(atlas!, undulation: CreatureUndulation.standard);
  }

  testWidgets('a living creature plays the frame of the clock from its sheet',
      (tester) async {
    final sheet = await sheetOf(tester);
    final paint = await paintOf(tester, _hard, {_hard: sheet});
    final frame = sheet.undulation
        .frameAt(seconds, phase: AmbientMotion.phaseOf(0, 0));
    const body = Rect.fromLTWH(10, 10, 28, 28);
    expect(
      paint,
      paints
        ..drawImageRect(
          image: sheet.atlas,
          source: sheet.frameRect(frame),
          destination: sheet.frameDst(body),
        ),
    );
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 1));
  });

  testWidgets('until its sheet is ready, it bobs as its bitmap',
      (tester) async {
    final paint = await paintOf(tester, _hard, const {});
    expect(paint,
        paints..drawImageRect(image: MapSprites.ready!.svg(_hard)));
  });

  testWidgets('a content that is no living creature never uses a sheet',
      (tester) async {
    final sheet = await sheetOf(tester);
    final paint = await paintOf(
        tester, playerBaseSvgPath, {playerBaseSvgPath: sheet});
    expect(paint,
        paints..drawImageRect(image: MapSprites.ready!.svg(playerBaseSvgPath)));
  });
}

