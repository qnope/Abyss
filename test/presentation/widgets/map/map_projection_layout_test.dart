import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('a standing content', () {
    test('is a square about a tile wide, planted below the centre', () {
      final centre = MapProjection.centreOf((3, 2));
      final box = MapProjection.standingOf((3, 2));
      expect(box.width, box.height);
      expect(box.width, closeTo(0.9 * MapProjection.tileWidth, 1e-9));
      expect(box.center.dx, centre.dx);
      expect(box.bottom, greaterThan(centre.dy));
      expect(box.bottom, lessThan(centre.dy + MapProjection.tileHeight / 2));
    });

    test('over a 2 by 2 block is twice as large, on the block centre', () {
      final one = MapProjection.standingOf((4, 4));
      final two = MapProjection.standingOf((4, 4), span: 2);
      final centre = MapProjection.centreOf((4, 4), span: 2);
      expect(two.width, closeTo(2 * one.width, 1e-9));
      expect(two.center.dx, centre.dx);
      expect(two.bottom, greaterThan(centre.dy));
    });

    test('of the first row stays within the headroom', () {
      for (var x = 0; x < 10; x++) {
        final top = MapProjection.standingOf((x, 0)).top;
        expect(top, greaterThanOrEqualTo(-MapProjection.headroom));
      }
    });
  });

  test('the origin shifts the left corner of the map to x = 0', () {
    expect(
      MapProjection.originOf(10),
      const Offset(10 * cellSize, MapProjection.headroom),
    );
    final leftmost = MapProjection.tileRectOf((0, 9)).left;
    expect(leftmost + MapProjection.originOf(10).dx, 0);
  });

  test('the map box holds every tile, the headroom and the slab', () {
    const columns = 12, rows = 8;
    final size = MapProjection.sizeOf(columns, rows);
    final origin = MapProjection.originOf(rows);
    expect(size.width, (columns + rows) * cellSize);
    final right = MapProjection.tileRectOf((columns - 1, 0)).right;
    expect(right + origin.dx, size.width);
    final bottom = MapProjection.tileRectOf((columns - 1, rows - 1)).bottom;
    expect(bottom + origin.dy + MapProjection.slabDepth, size.height);
    expect(MapProjection.slabDepth, closeTo(0.6 * MapProjection.tileHeight, 3));
  });

  group('the cell at a projection point', () {
    (int, int)? at(Offset p) => MapProjection.cellAt(p, columns: 6, rows: 4);

    test('is the cell whose diamond holds it', () {
      for (final cell in [(0, 0), (5, 0), (0, 3), (5, 3), (2, 1)]) {
        final box = MapProjection.tileRectOf(cell);
        expect(at(box.center), cell);
        expect(at(box.topCenter.translate(0, 1)), cell);
        expect(at(box.bottomCenter.translate(0, -1)), cell);
        expect(at(box.centerLeft.translate(1, 0)), cell);
        expect(at(box.centerRight.translate(-1, 0)), cell);
      }
    });

    test('is a neighbour in the corners of a tile box', () {
      final box = MapProjection.tileRectOf((2, 1));
      expect(at(box.topLeft.translate(2, 2)), (1, 1));
      expect(at(box.topRight.translate(-2, 2)), (2, 0));
      expect(at(box.bottomLeft.translate(2, -2)), (2, 2));
      expect(at(box.bottomRight.translate(-2, -2)), (3, 1));
    });

    test('is null outside the map', () {
      final topLeft = MapProjection.tileRectOf((0, 0)).topLeft;
      expect(at(topLeft.translate(2, 2)), isNull);
      expect(at(const Offset(0, -1)), isNull);
      final last = MapProjection.tileRectOf((5, 3));
      expect(at(last.bottomCenter.translate(0, 1)), isNull);
      expect(
        at(MapProjection.tileRectOf((5, 0)).centerRight.translate(1, 0)),
        isNull,
      );
      expect(
        at(MapProjection.tileRectOf((0, 3)).centerLeft.translate(-1, 0)),
        isNull,
      );
    });
  });
}
