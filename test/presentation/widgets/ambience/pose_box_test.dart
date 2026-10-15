import 'package:abyss/presentation/widgets/ambience/pose_box.dart';
import 'package:abyss/presentation/widgets/ambience/sprite_motion.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(40, 40);
  final child = find.byKey(const ValueKey('child'));

  /// Pumps a box posed by [scale]'s value, counting the child's builds.
  Future<List<int>> pumpBox(
    WidgetTester tester,
    ValueNotifier<double> scale,
  ) async {
    final builds = [0];
    await tester.pumpWidget(
      Center(
        child: PoseBox(
          size: size,
          repaint: scale,
          pose: () => SpriteMotion(scale: scale.value),
          child: Builder(
            key: const ValueKey('child'),
            builder: (context) {
              builds[0]++;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    return builds;
  }

  testWidgets('takes its size and paints its child in the pose', (
    tester,
  ) async {
    final scale = ValueNotifier(1.5);
    await pumpBox(tester, scale);
    expect(tester.getSize(find.byType(PoseBox)), size);
    final box = tester.getRect(find.byType(PoseBox));
    expect(
      tester.getRect(child),
      Rect.fromCenter(center: box.center, width: 60, height: 60),
    );
  });

  testWidgets('follows its listenable by repainting, never rebuilding', (
    tester,
  ) async {
    final scale = ValueNotifier(1.0);
    final builds = await pumpBox(tester, scale);
    scale.value = 2;
    await tester.pump();
    expect(tester.getRect(child).size, const Size(80, 80));
    scale.value = 0.5;
    await tester.pump();
    expect(tester.getRect(child).size, const Size(20, 20));
    expect(builds.single, 1);
  });

  testWidgets('lets its child overflow without clipping', (tester) async {
    await pumpBox(tester, ValueNotifier(2));
    final flow = tester.renderObject<RenderFlow>(find.byType(Flow));
    expect(flow.clipBehavior, Clip.none);
  });
}
