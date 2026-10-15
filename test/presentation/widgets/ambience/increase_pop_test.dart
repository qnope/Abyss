import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/ambience/increase_pop.dart';
import 'package:abyss/presentation/widgets/ambience/rise_glow_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(40, 40);
  final child = find.byKey(const ValueKey('child'));

  Widget pop(int value, {bool reduced = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Center(
      child: IncreasePop(
        value: value,
        size: size,
        glowColor: const Color(0xFF00FFFF),
        child: const SizedBox.expand(key: ValueKey('child')),
      ),
    ),
  );

  testWidgets('stays at rest when first shown', (tester) async {
    await tester.pumpWidget(pop(3));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.getRect(child).size, size);
  });

  testWidgets('pops once when the value goes up', (tester) async {
    await tester.pumpWidget(pop(1));
    await tester.pumpWidget(pop(2));
    expect(tester.hasRunningAnimations, isTrue);
    expect(tester.getRect(child).width, lessThan(40));
    await tester.pump(AbyssMotion.emphasis ~/ 2);
    expect(tester.getRect(child).width, isNot(40));
    await tester.pumpAndSettle();
    expect(tester.getRect(child).size, size);
    await tester.pumpWidget(pop(2));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('does not pop when the value goes down', (tester) async {
    await tester.pumpWidget(pop(2));
    await tester.pumpWidget(pop(1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('shows the final state at once when animations are reduced', (
    tester,
  ) async {
    await tester.pumpWidget(pop(1, reduced: true));
    await tester.pumpWidget(pop(2, reduced: true));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.getRect(child).size, size);
  });

  group('RiseGlowPainter', () {
    void Function(Canvas) paintAt(double t) =>
        (canvas) => RiseGlowPainter(
          progress: AlwaysStoppedAnimation(t),
          color: const Color(0xFF00FFFF),
        ).paint(canvas, size);

    test('glows above the sprite while it rises', () {
      expect(
        paintAt(0.2),
        paints
          ..circle()
          ..circle(),
      );
    });

    test('draws nothing once risen', () {
      expect(paintAt(1), paintsNothing);
    });

    test('the glow drifts upward', () {
      final low = RiseGlowPainter.centerAt(0.1, size).dy;
      expect(RiseGlowPainter.centerAt(0.6, size).dy, lessThan(low));
    });
  });
}
