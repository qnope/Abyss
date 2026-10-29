import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_standing_order.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const plain = 'plain.svg';
  const empty = MapCellVisual(terrainSprite: plain, revealed: true);
  const still = MapCellVisual(
      terrainSprite: plain, contentSprite: playerBaseSvgPath, revealed: true);
  const bobbing = MapCellVisual(
    terrainSprite: plain,
    contentSprite: playerBaseSvgPath,
    revealed: true,
    motion: AmbientMotion.bob,
  );

  group('standingCells', () {
    test('lists still and moving contents back to front, then left to right',
        () {
      // A map 3 cells wide: (x, y) is at y * 3 + x.
      final cells = [
        bobbing, empty, still, //
        still, bobbing, empty, //
        empty, still, bobbing,
      ];
      // Depths x + y: (0,0) 0; (0,1) 1; (1,1) and (2,0) 2; (1,2) 3; (2,2) 4.
      expect(standingCells(cells, 3), [0, 3, 4, 2, 7, 8]);
    });

    test('leaves out cells with nothing above the floor', () {
      expect(standingCells([empty, empty], 2), isEmpty);
    });

    test('lists a content seen through the fog in its depth', () {
      const beacon = MapCellVisual(
          terrainSprite: plain, contentSprite: 'wreck.svg', aboveFog: true);
      expect(standingCells([beacon, still, still, empty], 2), [0, 2, 1]);
    });

    test('ranks the volcano by the centre of its block', () {
      const volcano = MapCellVisual(
          terrainSprite: plain, contentSprite: 'v.svg', contentSpan: 2);
      // A map 4 cells wide, the volcano on (1, 1) to (2, 2).
      final cells = List.filled(16, empty);
      cells[1 * 4 + 1] = volcano;
      cells[0 * 4 + 3] = still; // (3, 0): on the right, depth 3
      cells[3 * 4 + 0] = still; // (0, 3): on the left, depth 3
      cells[2 * 4 + 0] = still; // (0, 2): behind on the left, depth 2
      cells[1 * 4 + 3] = still; // (3, 1): in front on the right, depth 4
      expect(standingCells(cells, 4), [8, 12, 5, 3, 7]);
    });
  });

  test('a rank orders by depth, then from left to right', () {
    expect(standingRankOf((2, 1)), (3, 4));
    expect(standingRankOf((1, 1), span: 2), (3, 3));
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
