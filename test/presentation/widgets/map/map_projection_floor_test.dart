import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the floor of a cell is the box of its diamond', () {
    for (final cell in [(0, 0), (3, 1), (0, 4)]) {
      expect(MapProjection.floorOf(cell), MapProjection.tileRectOf(cell));
    }
  });

  test('the floor of a 2 by 2 block is twice as large, on its centre', () {
    final floor = MapProjection.floorOf((4, 4), span: 2);
    expect(floor.center, MapProjection.centreOf((4, 4), span: 2));
    expect(floor.width, 2 * MapProjection.tileWidth);
    expect(floor.height, 2 * MapProjection.tileHeight);
    expect(floor.top, MapProjection.tileRectOf((4, 4)).top);
    expect(floor.bottom, MapProjection.tileRectOf((5, 5)).bottom);
  });

  test('the isometric transform lays a flat cell onto its diamond', () {
    final matrix = Matrix4.fromFloat64List(MapProjection.isometric);
    Offset project(Offset flat) => MatrixUtils.transformPoint(matrix, flat);
    final square = MapContentDrawer.cellRect(2 * 10 + 3, 10);
    final tile = MapProjection.tileRectOf((3, 2));
    expect(project(square.topLeft), tile.topCenter);
    expect(project(square.topRight), tile.centerRight);
    expect(project(square.bottomRight), tile.bottomCenter);
    expect(project(square.bottomLeft), tile.centerLeft);
    expect(project(square.center), MapProjection.centreOf((3, 2)));
  });

  test('the isometric transform is the projection of any flat point', () {
    final matrix = Matrix4.fromFloat64List(MapProjection.isometric);
    for (final p in const [Offset(13.5, 200), Offset(-7, 3.25)]) {
      final projected = MatrixUtils.transformPoint(matrix, p);
      expect((projected - MapProjection.toScreen(p)).distance,
          lessThan(1e-9));
    }
  });
}
