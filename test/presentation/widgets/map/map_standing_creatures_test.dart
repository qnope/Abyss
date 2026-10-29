import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/presentation/extensions/cell_content_type_extensions.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/ambience/creature_sheet.dart';
import 'package:abyss/presentation/widgets/ambience/creature_undulation.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'map_standing_probe.dart';

final _hard = MonsterDifficulty.hard.svgPath;

void main() {
  const seconds = 1.3;

  /// Paints one cell showing [sprite], the creature sheets being [sheets].
  Future<void Function(Canvas)> paintCell(WidgetTester tester, String sprite,
      Map<String, CreatureSheet> sheets) async {
    final sprites = await tester.runAsync(MapSprites.load);
    return paintOf(standingPainterOf(
      [standingCell(AmbientMotion.bob, sprite: sprite)],
      columns: 1,
      sprites: sprites,
      clock: ValueNotifier(seconds),
      creatureSheetOf: (path) => sheets[path],
    ));
  }

  Future<CreatureSheet> sheetOf(WidgetTester tester) async {
    final atlas = await tester.runAsync(() => createTestImage(
        width: 8, height: 6, cache: false));
    return CreatureSheet(atlas!, undulation: CreatureUndulation.standard);
  }

  testWidgets('a living creature plays the frame of the clock from its sheet',
      (tester) async {
    final sheet = await sheetOf(tester);
    final paint = await paintCell(tester, _hard, {_hard: sheet});
    final frame = sheet.undulation
        .frameAt(seconds, phase: AmbientMotion.phaseOf(0, 0));
    final body = MapProjection.standingOf((0, 0));
    expect(
      paint,
      paints
        ..drawImageRect(image: MapSprites.ready!.shadow)
        ..drawImageRect(
          image: sheet.atlas,
          source: sheet.frameRect(frame),
          destination: sheet.frameDst(body),
        ),
    );
    // Its shadow, then the creature in its whole standing box.
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 2));
  });

  testWidgets('until its sheet is ready, it bobs as its bitmap',
      (tester) async {
    final paint = await paintCell(tester, _hard, const {});
    expect(
        paint,
        paints
          ..drawImageRect(image: MapSprites.ready!.shadow)
          ..drawImageRect(image: MapSprites.ready!.svg(_hard)));
  });

  testWidgets('a content that is no living creature never uses a sheet',
      (tester) async {
    final sheet = await sheetOf(tester);
    final paint = await paintCell(
        tester, playerBaseSvgPath, {playerBaseSvgPath: sheet});
    expect(
        paint,
        paints
          ..drawImageRect(image: MapSprites.ready!.shadow)
          ..drawImageRect(image: MapSprites.ready!.svg(playerBaseSvgPath)));
  });
}

