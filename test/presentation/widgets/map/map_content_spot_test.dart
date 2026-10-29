import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_spot.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = 6;
  const base = MapCellVisual(
      terrainSprite: 'plain.svg', contentSprite: playerBaseSvgPath);
  const volcano = MapCellVisual(
      terrainSprite: 'plain.svg', contentSprite: 'v.svg', contentSpan: 2);
  final spot = MapContentSpot.of(base, 2 * columns + 3, columns);
  final centre = MapProjection.centreOf((3, 2));

  /// Whether [rect] lies flat on the floor: twice as wide as tall.
  bool flattened(Rect rect) => (rect.width - 2 * rect.height).abs() < 1e-9;

  test('stands in the whole standing box of its cell', () {
    expect(spot.index, 2 * columns + 3);
    expect(spot.area, MapProjection.standingOf((3, 2)));
  });

  test('pools its glow on the floor, wider than its cell', () {
    expect(spot.glow.center, centre);
    expect(flattened(spot.glow), isTrue);
    expect(spot.glow.width, greaterThan(MapProjection.tileWidth));
  });

  test('rings its base on the floor, inside its cell', () {
    expect(spot.ring.center, centre);
    expect(flattened(spot.ring), isTrue);
    expect(spot.ring.width, lessThan(MapProjection.tileWidth));
  });

  test('casts its shadow on the floor, away from the upper left light', () {
    expect(flattened(spot.shadow), isTrue);
    expect(spot.shadow.center.dx, greaterThan(centre.dx));
    expect(spot.shadow.center.dy, greaterThan(centre.dy));
    expect(spot.shadow.width, lessThan(spot.area.width));
    expect(spot.area.contains(spot.shadow.center), isTrue);
  });

  test('is culled by a box holding all it draws', () {
    for (final part in [spot.area, spot.glow, spot.shadow, spot.ring]) {
      expect(spot.bounds.expandToInclude(part), spot.bounds);
    }
  });

  test('of the volcano covers its 2 by 2 block', () {
    final wide = MapContentSpot.of(volcano, columns + 2, columns);
    final block = MapProjection.centreOf((2, 1), span: 2);
    expect(wide.area, MapProjection.standingOf((2, 1), span: 2));
    expect(wide.glow.center, block);
    expect(wide.glow.width, closeTo(2 * spot.glow.width, 1e-9));
    expect(wide.ring.center, block);
    expect(wide.shadow.width, closeTo(2 * spot.shadow.width, 1e-9));
  });
}
