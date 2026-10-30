import 'package:abyss/presentation/widgets/backdrop/trench/parallax_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A tile counting how often, and at what size, it is painted.
class _CountingTile extends CustomPainter {
  final sizes = <Size>[];

  @override
  void paint(Canvas canvas, Size size) => sizes.add(size);

  @override
  bool shouldRepaint(_CountingTile oldDelegate) => false;
}

void main() {
  const viewport = Size(300, 500);
  late TransformationController transform;
  late _CountingTile tile;

  setUp(() {
    transform = TransformationController();
    tile = _CountingTile();
  });
  tearDown(() => transform.dispose());

  Future<void> pumpLayer(WidgetTester tester, {double rate = 0.35}) =>
      tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: viewport,
            child: ParallaxLayer(
                transform: transform, content: viewport, rate: rate,
                tile: tile),
          ),
        ),
      ));

  Finder painted() => find.descendant(
      of: find.byType(ParallaxLayer), matching: find.byType(CustomPaint));

  Offset shiftOf(WidgetTester tester) {
    final transform = tester
        .widget<Transform>(find.descendant(
            of: find.byType(ParallaxLayer), matching: find.byType(Transform)))
        .transform;
    return Offset(transform.storage[12], transform.storage[13]);
  }

  testWidgets('paints its tile once, side by side, at the viewport size', (
    tester,
  ) async {
    await pumpLayer(tester);
    expect(tile.sizes, [viewport, viewport]);
    expect(find.ancestor(of: painted(), matching: find.byType(RepaintBoundary)),
        findsWidgets);
  });

  testWidgets('slides at its rate as the content pans, never repainted', (
    tester,
  ) async {
    await pumpLayer(tester);
    final before = shiftOf(tester);
    transform.value = Matrix4.translationValues(40, -20, 0);
    await tester.pump();
    final moved = shiftOf(tester) - before;
    expect(moved.dx, closeTo(0.35 * 40, 1e-9));
    expect(moved.dy, closeTo(0.35 * -20, 1e-9));
    transform.value = Matrix4.translationValues(-90, 30, 0);
    await tester.pump();
    expect(tile.sizes, hasLength(2));
  });

  testWidgets('always covers the viewport, however far it pans', (
    tester,
  ) async {
    await pumpLayer(tester, rate: 1);
    for (final (dx, dy) in [
      (0.0, 0.0), (-1000.0, 0.0), (299.0, 0.0), (5000.0, 9000.0),
      (-7.0, -9000.0),
    ]) {
      transform.value = Matrix4.translationValues(dx, dy, 0);
      await tester.pump();
      final shown = tester.getRect(painted().first);
      expect(shown.contains(Offset.zero), isTrue, reason: '$dx, $dy');
      expect(shown.contains(const Offset(299.9, 499.9)), isTrue,
          reason: '$dx, $dy');
    }
  });

  testWidgets('never takes a tap', (tester) async {
    await pumpLayer(tester);
    expect(find.ancestor(of: painted(), matching: find.byType(IgnorePointer)),
        findsWidgets);
  });
}
