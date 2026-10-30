import 'dart:ui';

import 'package:abyss/presentation/widgets/map/decor/decor_scatter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'decor_probe.dart';

void main() {
  const side = 20;

  test('never touches a blocked cell', () {
    bool blocked(int x, int y) => (x + 2 * y) % 5 == 0;
    final free = scatterDecor(columns: side, rows: side, salt: 1);
    final decor = scatterDecor(
        columns: side, rows: side, salt: 1, isBlocked: blocked);
    expect(decor, isNotEmpty);
    expect(decor.length, lessThan(free.length));
    for (final item in decor) {
      for (final (x, y) in cellsTouchedBy(item)) {
        expect(blocked(x, y), isFalse, reason: '$item on ($x, $y)');
      }
    }
    // What stays is what the free map had there.
    expect(free, containsAll(decor));
  });

  test('stands under the fog only among hidden cells', () {
    bool hidden(int x, int y) => x + y > side;
    final decor = scatterDecor(
        columns: side, rows: side, salt: 1, isHidden: hidden);
    expect(decor.where((d) => d.hidden), isNotEmpty);
    expect(decor.where((d) => !d.hidden), isNotEmpty);
    for (final item in decor) {
      for (final (x, y) in cellsTouchedBy(item)) {
        expect(hidden(x, y), item.hidden, reason: '$item on ($x, $y)');
      }
    }
  });

  test('keeps out of the way of what it is told to', () {
    final boxes = [
      for (var i = 2; i < side - 2; i += 4)
        MapProjection.standingOf((i, side - i), span: 2).inflate(8),
      const Rect.fromLTWH(-200, 100, 400, 150),
    ];
    final keepOut = boxes.map(DecorKeepOut.box).toList();
    final free = scatterDecor(columns: side, rows: side, salt: 3);
    final decor = scatterDecor(
        columns: side, rows: side, salt: 3, keepOut: keepOut);
    expect(decor, isNotEmpty);
    expect(decor.length, lessThan(free.length));
    for (final item in decor) {
      for (final box in boxes) {
        expect(item.body.overlaps(box), isFalse, reason: '$item in $box');
      }
    }
  });

  test('draws nothing on an empty map', () {
    expect(scatterDecor(columns: 0, rows: 0, salt: 1), isEmpty);
    expect(scatterDecor(columns: 1, rows: 1, salt: 1), isEmpty);
  });
}
