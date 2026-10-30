import 'dart:ui';

import 'package:abyss/presentation/widgets/map/decor/decor_scatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A content drawn in 100 x 100 around (0, -40), tapped in its middle,
  // its floor's middle at 0.
  const content = DecorKeepOut(
    core: Rect.fromLTRB(-30, -70, 30, 10),
    drawn: Rect.fromLTRB(-50, -90, 50, 10),
    depth: 0,
  );
  MapDecor standingAt(double x, double y) =>
      MapDecor(sprite: 'decor.svg', foot: Offset(x, y), size: 40);

  test('keeps every decor out of its core', () {
    for (final foot in [const Offset(0, -40), const Offset(10, 30)]) {
      final decor = standingAt(foot.dx, foot.dy);
      expect(decor.body.overlaps(content.core), isTrue);
      expect(content.blocks(decor), isTrue, reason: '$decor');
    }
  });

  test('keeps a decor in front out of all it draws', () {
    final decor = standingAt(60, 20);
    expect(decor.body.overlaps(content.drawn), isTrue);
    expect(decor.body.overlaps(content.core), isFalse);
    expect(content.blocks(decor), isTrue);
  });

  test('lets a decor behind hide behind its edges', () {
    final decor = standingAt(60, -10);
    expect(decor.body.overlaps(content.drawn), isTrue);
    expect(decor.body.overlaps(content.core), isFalse);
    expect(content.blocks(decor), isFalse);
  });

  test('a box lying on the floor keeps every decor out', () {
    const hole = DecorKeepOut.box(Rect.fromLTRB(-50, -25, 50, 25));
    expect(hole.blocks(standingAt(0, -20)), isTrue);
    expect(hole.blocks(standingAt(0, 45)), isTrue);
    expect(hole.blocks(standingAt(100, 0)), isFalse);
  });
}
