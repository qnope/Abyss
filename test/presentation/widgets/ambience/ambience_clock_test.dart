import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/ambience/ambience_clock.dart';
import 'package:abyss/presentation/widgets/ambience/ambience_clock_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a scope and records each value the clock announces.
Future<(AmbienceClock, List<double>)> _pumpScope(
  WidgetTester tester, {
  bool ticking = true,
  bool reduced = false,
  bool animate = true,
}) async {
  late AmbienceClock clock;
  final heard = <double>[];
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: TickerMode(
        enabled: ticking,
        child: AmbienceClockScope(
          animate: animate,
          builder: (context, c) {
            clock = c;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  clock.addListener(() => heard.add(clock.value));
  return (clock, heard);
}

Future<void> _frames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('tells the elapsed seconds', (tester) async {
    final (clock, _) = await _pumpScope(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(clock.value, closeTo(2, 0.05));
    expect(clock.isTicking, isTrue);
  });

  testWidgets('notifies at most about 30 times per second', (tester) async {
    final (_, heard) = await _pumpScope(tester);
    await _frames(tester, 60 + 2);
    expect(heard.length, inInclusiveRange(25, 31));
    for (var i = 1; i < heard.length; i++) {
      expect(
        heard[i] - heard[i - 1],
        greaterThanOrEqualTo(
          AbyssMotion.ambientFrame.inMicroseconds / 1e6 - 1e-6,
        ),
      );
    }
  });

  testWidgets('pauses while TickerMode is off', (tester) async {
    final (clock, heard) = await _pumpScope(tester, ticking: false);
    await _frames(tester, 30);
    expect(heard, isEmpty);
    expect(clock.value, 0);
  });

  testWidgets('freezes when animations are disabled', (tester) async {
    final (clock, heard) = await _pumpScope(tester, reduced: true);
    await _frames(tester, 30);
    expect(heard, isEmpty);
    expect(clock.isTicking, isFalse);
  });

  testWidgets('holds still when animate is false', (tester) async {
    final (clock, heard) = await _pumpScope(tester, animate: false);
    await _frames(tester, 30);
    expect(heard, isEmpty);
    expect(clock.isTicking, isFalse);
  });

  testWidgets('resumes from where it froze', (tester) async {
    final (clock, _) = await _pumpScope(tester);
    await _frames(tester, 40);
    final frozenAt = clock.value;
    await _pumpScope(tester, reduced: true);
    await _frames(tester, 40);
    expect(clock.value, frozenAt);
    await _pumpScope(tester);
    await _frames(tester, 40);
    expect(clock.value, greaterThan(frozenAt));
    expect(clock.value, lessThan(frozenAt + 0.8));
  });

  testWidgets('descendants find the clock of the scope', (tester) async {
    final (clock, _) = await _pumpScope(tester);
    final context = tester.element(find.byType(SizedBox));
    expect(AmbienceClockScope.maybeOf(context), same(clock));
  });

  testWidgets('a bare clock ticks once started and stops cleanly', (
    tester,
  ) async {
    final clock = AmbienceClock(vsync: const TestVSync());
    expect(clock.isTicking, isFalse);
    clock.start();
    expect(clock.isTicking, isTrue);
    clock.stop();
    expect(clock.isTicking, isFalse);
    clock.dispose();
  });
}
