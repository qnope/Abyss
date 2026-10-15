import 'package:abyss/presentation/widgets/ambience/ambience_clock_scope.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_pose.dart';
import 'package:abyss/presentation/widgets/ambience/pose_box.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(40, 40);
  final child = find.byKey(const ValueKey('child'));

  Widget pose(AmbientMotion motion, {double phase = 0}) => Center(
    child: AmbientPose(
      motion: motion,
      phase: phase,
      size: size,
      child: const SizedBox.square(key: ValueKey('child'), dimension: 40),
    ),
  );

  Widget scoped(Widget child, {bool reduced = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: AmbienceClockScope(builder: (_, _) => child),
  );

  testWidgets('moves its child with the clock of the scope', (tester) async {
    await tester.pumpWidget(scoped(pose(AmbientMotion.breathe)));
    final start = tester.getRect(child).width;
    await tester.pump(const Duration(milliseconds: 1250));
    final later = tester.getRect(child).width;
    expect(later, greaterThan(start));
    expect(later, closeTo(40 * AmbientMotion.breathe.at(1.25).scale, 0.1));
  });

  testWidgets('shifts the motion by its phase', (tester) async {
    await tester.pumpWidget(scoped(pose(AmbientMotion.breathe, phase: 0.5)));
    expect(
      tester.getRect(child).width,
      closeTo(40 * AmbientMotion.breathe.at(0, phase: 0.5).scale, 0.1),
    );
  });

  testWidgets('stays still without a scope', (tester) async {
    await tester.pumpWidget(pose(AmbientMotion.breathe));
    expect(find.byType(PoseBox), findsNothing);
    expect(tester.getSize(child), size);
  });

  testWidgets('a still motion adds nothing', (tester) async {
    await tester.pumpWidget(scoped(pose(AmbientMotion.still)));
    expect(find.byType(PoseBox), findsNothing);
  });

  testWidgets('freezes when animations are reduced', (tester) async {
    await tester.pumpWidget(scoped(pose(AmbientMotion.breathe), reduced: true));
    final start = tester.getRect(child);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.getRect(child), start);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
