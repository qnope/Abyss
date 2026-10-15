import 'package:abyss/presentation/widgets/ambience/bubbles_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(40, 40);

  void Function(Canvas) paintOf(BubblesPainter painter, [Size s = size]) =>
      (canvas) => painter.paint(canvas, s);

  BubblesPainter painterOf({int seed = 1, double seconds = 0.7}) =>
      BubblesPainter(clock: ValueNotifier(seconds), seed: seed);

  test('draws a few bubbles inside its box', () {
    final painter = painterOf();
    expect(
      paintOf(painter),
      paintsExactlyCountTimes(#drawCircle, BubblesPainter.defaultCount),
    );
    for (final b in painter.bubblesAt(0.7, size)) {
      expect((Offset.zero & size).contains(b.center), isTrue);
      expect(b.radius, inInclusiveRange(0.5, 4));
    }
  });

  test('places bubbles from its seed alone', () {
    final again = painterOf().bubblesAt(0.7, size);
    expect(painterOf().bubblesAt(0.7, size), again);
    expect(painterOf(seed: 2).bubblesAt(0.7, size), isNot(again));
  });

  test('bubbles rise as time passes', () {
    final painter = painterOf();
    final before = painter.bubblesAt(1, size).first.center.dy;
    final after = painter.bubblesAt(1.2, size).first.center.dy;
    expect(after, lessThan(before));
  });

  test('draws nothing in an empty box', () {
    expect(paintOf(painterOf(), Size.zero), paintsNothing);
  });

  test('repaints when the clock ticks, not on an equal rebuild', () {
    final clock = ValueNotifier(0.0);
    final painter = BubblesPainter(clock: clock, seed: 3);
    var heard = 0;
    painter.addListener(() => heard++);
    clock.value = 0.1;
    expect(heard, 1);
    expect(
      BubblesPainter(clock: clock, seed: 3).shouldRepaint(painter),
      isFalse,
    );
    expect(
      BubblesPainter(clock: clock, seed: 4).shouldRepaint(painter),
      isTrue,
    );
    expect(painter.hitTest(Offset.zero), isFalse);
  });
}
