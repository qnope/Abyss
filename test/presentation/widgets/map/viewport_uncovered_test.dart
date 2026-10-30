import 'package:abyss/presentation/widgets/map/viewport_cover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A diamond 200 wide and 100 tall, its top vertex at (100, 0).
  const diamond = [
    Offset(100, 0), Offset(200, 50), Offset(100, 100), Offset(0, 50)];
  const viewport = Size(40, 20);

  Matrix4 showing(Offset point, double scale) => Matrix4.translationValues(
      viewport.width / 2 - point.dx * scale,
      viewport.height / 2 - point.dy * scale, 0)
    ..scaleByDouble(scale, scale, 1, 1);

  void expectRect(Rect actual, Rect expected) {
    for (final (a, e) in [
      (actual.left, expected.left), (actual.top, expected.top),
      (actual.right, expected.right), (actual.bottom, expected.bottom),
    ]) {
      expect(a, closeTo(e, 1e-9), reason: '$actual');
    }
  }

  test('nothing shows past a shape covering the viewport', () {
    expect(uncoveredArea(diamond, showing(const Offset(100, 50), 1),
        viewport).isEmpty, isTrue);
  });

  test('bounds what shows past the shape, and only that', () {
    // The left vertex in the middle of the screen: all but a sliver.
    expectRect(uncoveredArea(diamond, showing(const Offset(0, 50), 1),
        viewport), const Rect.fromLTRB(0, 0, 40, 20));
    // Near the left vertex, the edges cross the screen's top and bottom.
    expectRect(uncoveredArea(diamond, showing(const Offset(20, 50), 1),
        viewport), const Rect.fromLTRB(0, 0, 20, 20));
    // Zoomed in twice as much, only a corner by the vertex shows.
    expectRect(uncoveredArea(diamond, showing(const Offset(10, 50), 2),
        viewport), const Rect.fromLTRB(0, 0, 20, 20));
  });

  test('the whole viewport when the shape is out of sight, or no shape', () {
    final all = Offset.zero & viewport;
    expect(uncoveredArea(diamond, showing(const Offset(500, 50), 1),
        viewport), all);
    expect(uncoveredArea(const [], Matrix4.identity(), viewport), all);
  });

  test('takes the shape\'s edges in by the margin', () {
    final near = showing(const Offset(100, 30), 1);
    expect(uncoveredArea(diamond, near, viewport).isEmpty, isTrue);
    final area = uncoveredArea(diamond, near, viewport, margin: 12);
    // Along the top edges, over the top corners of the screen.
    expect(area.isEmpty, isFalse);
    expect(area.top, 0);
    expect(area.bottom, lessThan(viewport.height));
  });

  test('agrees with whether the shape covers the viewport', () {
    for (var x = -40.0; x <= 240; x += 20) {
      for (var y = -20.0; y <= 120; y += 10) {
        final transform = showing(Offset(x, y), 1.5);
        expect(uncoveredArea(diamond, transform, viewport).isEmpty,
            coversViewport(diamond, transform, viewport),
            reason: '($x, $y)');
      }
    }
  });
}
