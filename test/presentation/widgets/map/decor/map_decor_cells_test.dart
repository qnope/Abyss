import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/post_holder_extensions.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/decor/map_decor_cells.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_standing_hit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'decor_probe.dart';

void main() {
  const side = 16;
  final tile = TerrainType.plain.tileSvgPaths.first;
  final faille = TransitionBaseType.faille.svgPathFor(PostHolder.guardians);
  const volcano = 'assets/icons/terrain/volcanic_kernel.svg';
  // Contents every few cells, a volcano, a hole; the last rows hidden.
  final contents = <(int, int), MapCellVisual>{
    for (var y = 1; y < side; y += 3)
      for (var x = (y % 2) * 2; x < side; x += 4)
        (x, y): MapCellVisual(terrainSprite: tile,
            contentSprite: playerBaseSvgPath, revealed: true),
    (9, 9): MapCellVisual(terrainSprite: tile, contentSprite: volcano,
        contentSpan: 2, revealed: true),
    (12, 7): MapCellVisual(terrainSprite: tile, contentSprite: faille,
        revealed: true),
  };
  final visuals = [
    for (var y = 0; y < side; y++)
      for (var x = 0; x < side; x++)
        contents[(x, y)] ??
            MapCellVisual(terrainSprite: tile, revealed: y < side - 4),
  ];
  final decor = mapDecorOf(visuals, side, salt: 1);

  test('scatters the decor of the free cells by the salt', () {
    expect(decor, isNotEmpty);
    expect(mapDecorOf(visuals, side, salt: 1), decor);
    expect(mapDecorOf(visuals, side, salt: 2), isNot(decor));
    final free = scatterDecor(columns: side, rows: side, salt: 1);
    expect(free.map((d) => d.foot), containsAll(decor.map((d) => d.foot)));
  });

  test('never touches a cell holding a content, nor the volcano', () {
    final blocked = {
      ...contents.keys,
      (10, 9), (9, 10), (10, 10), // The rest of the volcano's block.
    };
    for (final item in decor) {
      expect(cellsTouchedBy(item).intersection(blocked), isEmpty,
          reason: '$item');
    }
  });

  test('keeps out of a tap box, and of a content it stands in front of',
      () {
    for (final item in decor) {
      for (final MapEntry(key: cell, value: visual) in contents.entries) {
        if (visual.contentSprite == faille) {
          expect(item.body.overlaps(MapProjection.floorOf(cell)), isFalse);
          continue;
        }
        final span = visual.contentSpan;
        final area = MapProjection.standingOf(cell, span: span);
        expect(item.body.overlaps(standingHitBox(area)), isFalse,
            reason: '$item $cell');
        if (item.foot.dy > MapProjection.centreOf(cell, span: span).dy) {
          expect(item.body.overlaps(area), isFalse, reason: '$item $cell');
        }
      }
      // A tap on a decor picks the cell under it, as if it were not there.
      for (final point in [item.foot, item.body.center, item.body.topLeft]) {
        expect(standingCellAt(point, visuals: visuals, columns: side),
            isNull, reason: '$item');
      }
    }
  });

  test('lies under the fog among hidden cells only', () {
    expect(decor.where((d) => d.hidden), isNotEmpty);
    for (final item in decor) {
      final hidden = cellsTouchedBy(item).map((c) => c.$2 >= side - 4);
      expect(hidden, everyElement(item.hidden), reason: '$item');
    }
  });
}
