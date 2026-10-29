import 'dart:ui';

import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _near(Offset expected) => isA<Offset>()
    .having((o) => o.dx, 'dx', closeTo(expected.dx, 1e-9))
    .having((o) => o.dy, 'dy', closeTo(expected.dy, 1e-9));

void main() {
  test('a tile is a diamond twice as wide as tall, as large as a cell', () {
    expect(MapProjection.tileWidth, 2 * cellSize);
    expect(MapProjection.tileHeight, cellSize);
    expect(
      MapProjection.tileWidth * MapProjection.tileHeight / 2,
      cellSize * cellSize,
    );
  });

  test('the flat axes run down to the right and down to the left', () {
    expect(MapProjection.toScreen(Offset.zero), Offset.zero);
    expect(MapProjection.toScreen(const Offset(48, 0)), const Offset(48, 24));
    expect(MapProjection.toScreen(const Offset(0, 48)), const Offset(-48, 24));
    expect(MapProjection.toScreen(const Offset(48, 48)), const Offset(0, 48));
  });

  test('toFlat undoes toScreen and the other way round', () {
    const points = [
      Offset(0, 0),
      Offset(13.5, 200),
      Offset(-7, 3.25),
      Offset(480, 96),
    ];
    for (final p in points) {
      expect(MapProjection.toFlat(MapProjection.toScreen(p)), _near(p));
      expect(MapProjection.toScreen(MapProjection.toFlat(p)), _near(p));
    }
  });

  test('the centre of a cell is the projection of its flat centre', () {
    expect(MapProjection.centreOf((0, 0)), const Offset(0, 24));
    expect(
      MapProjection.centreOf((3, 1)),
      MapProjection.toScreen(const Offset(3.5 * 48, 1.5 * 48)),
    );
  });

  test('the centre of a 2 by 2 block is its shared corner', () {
    expect(
      MapProjection.centreOf((4, 2), span: 2),
      MapProjection.toScreen(const Offset(5 * 48, 3 * 48)),
    );
  });

  test('the tile box of a cell bounds its diamond', () {
    expect(
      MapProjection.tileRectOf((0, 0)),
      const Rect.fromLTWH(-48, 0, 96, 48),
    );
    final box = MapProjection.tileRectOf((2, 5));
    expect(box.center, MapProjection.centreOf((2, 5)));
    expect(box.size, const Size(96, 48));
  });

  group('the diamond of a cell', () {
    final diamond = MapProjection.diamondOf((2, 1));
    final box = MapProjection.tileRectOf((2, 1));

    test('has the tile box for bounds', () {
      expect(diamond.getBounds(), box);
    });

    test('holds its centre and points near its four vertices', () {
      expect(diamond.contains(box.center), isTrue);
      expect(diamond.contains(box.topCenter.translate(0, 1)), isTrue);
      expect(diamond.contains(box.bottomCenter.translate(0, -1)), isTrue);
      expect(diamond.contains(box.centerLeft.translate(1, 0)), isTrue);
      expect(diamond.contains(box.centerRight.translate(-1, 0)), isTrue);
    });

    test('leaves out the corners of its box', () {
      expect(diamond.contains(box.topLeft.translate(2, 2)), isFalse);
      expect(diamond.contains(box.topRight.translate(-2, 2)), isFalse);
      expect(diamond.contains(box.bottomLeft.translate(2, -2)), isFalse);
      expect(diamond.contains(box.bottomRight.translate(-2, -2)), isFalse);
    });

    test('shrinks around its centre by a flat inset', () {
      final inset = MapProjection.diamondOf((2, 1), inset: 4).getBounds();
      expect(inset.center, box.center);
      expect(inset.width, box.width - 16);
      expect(inset.height, box.height - 8);
    });
  });

  test('a flat box stands up on screen around its projected centre', () {
    const flat = Rect.fromLTWH(100, 40, 20, 30);
    final up = MapProjection.upright(flat);
    expect(up.size, flat.size);
    expect(up.center, _near(MapProjection.toScreen(flat.center)));
  });
}
