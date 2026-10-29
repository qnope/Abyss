import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_standing_hit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const side = 5;
  const empty = MapCellVisual(terrainSprite: 'plain.svg', revealed: true);
  const base = MapCellVisual(
    terrainSprite: 'plain.svg',
    contentSprite: playerBaseSvgPath,
    revealed: true,
    motion: AmbientMotion.breathe,
  );

  /// A map [side] cells wide, empty but for [contents] by cell.
  List<MapCellVisual> mapOf(Map<(int, int), MapCellVisual> contents) => [
        for (var y = 0; y < side; y++)
          for (var x = 0; x < side; x++) contents[(x, y)] ?? empty,
      ];

  (int, int)? hit(Offset point, Map<(int, int), MapCellVisual> contents) =>
      standingCellAt(point, visuals: mapOf(contents), columns: side);

  Rect hitBoxOf((int, int) cell, {int span = 1}) =>
      standingHitBox(MapProjection.standingOf(cell, span: span));

  test('a hit box is the middle 60% of a sprite, its bottom 80%', () {
    const area = Rect.fromLTWH(0, 0, 100, 100);
    expect(standingHitBox(area), const Rect.fromLTRB(20, 20, 80, 100));
  });

  test('the upper part of a tall sprite picks its cell', () {
    final point = hitBoxOf((2, 2)).topCenter.translate(0, 2);
    expect(MapProjection.cellAt(point, columns: side, rows: side),
        isNot((2, 2)));
    expect(hit(point, {(2, 2): base}), (2, 2));
  });

  test('where two sprites overlap, the one in front is picked', () {
    final back = hitBoxOf((1, 1)), front = hitBoxOf((2, 2));
    final point = Offset(front.center.dx, (back.bottom + front.top) / 2);
    expect(back.contains(point) && front.contains(point), isTrue);
    expect(hit(point, {(1, 1): base, (2, 2): base}), (2, 2));
    expect(hit(point, {(1, 1): base}), (1, 1));
  });

  test('the transparent sides of a sprite let the tap through', () {
    final area = MapProjection.standingOf((2, 2));
    final side = area.bottomLeft.translate(0.1 * area.width, -2);
    expect(hit(side, {(2, 2): base}), isNull);
  });

  test('hidden, flat and empty cells are never picked', () {
    final point = hitBoxOf((2, 2)).topCenter.translate(0, 2);
    const beacon = MapCellVisual(
        terrainSprite: 'plain.svg', contentSprite: 'wreck.svg', aboveFog: true);
    const faille = MapCellVisual(
      terrainSprite: 'plain.svg',
      contentSprite: 'assets/icons/posts/faille_guarded.svg',
      revealed: true,
    );
    expect(hit(point, {(2, 2): beacon}), isNull);
    expect(hit(point, {(2, 2): faille}), isNull);
    expect(hit(point, const {}), isNull);
  });

  test('the volcano is picked high above its block', () {
    const volcano = MapCellVisual(
      terrainSprite: 'plain.svg',
      contentSprite: 'volcano.svg',
      contentSpan: 2,
      revealed: true,
    );
    final point = hitBoxOf((1, 1), span: 2).topCenter.translate(0, 4);
    expect(hit(point, {(1, 1): volcano}), (1, 1));
  });

  test('a sprite of the first row is picked in the headroom', () {
    final point = hitBoxOf((2, 0)).topCenter.translate(0, 2);
    expect(MapProjection.cellAt(point, columns: side, rows: side), isNull);
    expect(hit(point, {(2, 0): base}), (2, 0));
  });
}
