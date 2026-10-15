import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects_layer.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/reduced_motion.dart';

const _length = Duration(milliseconds: 500);

class _Run implements MapEffectRun {
  @override
  Duration get duration => _length;

  @override
  Offset shakeAt(Duration elapsed) => const Offset(2, 0);

  @override
  void paint(Canvas canvas, Duration elapsed) {}
}

class _Effect extends MapEffect {
  const _Effect();

  @override
  MapEffectRun stage(MapStage stage) => _Run();
}

void main() {
  late MapEffects effects;
  setUp(() => effects = MapEffects());
  tearDown(() => effects.dispose());

  Future<void> pumpLayer(WidgetTester tester) => tester.pumpWidget(
        MapEffectsLayer(
          effects: effects,
          size: const Size(10 * cellSize, 10 * cellSize),
          originOf: (target) => (0, 0),
        ),
      );

  Future<bool> playAndWatch(WidgetTester tester, List<bool> done) async {
    effects.play(const _Effect()).then((_) => done.add(true));
    await tester.pump();
    return done.isNotEmpty;
  }

  test('an effect played with no layer to show it is over at once',
      () async {
    await effects.play(const _Effect());
    expect(effects.isPlaying, isFalse);
  });

  testWidgets('an effect is over once the layer has played it', (
    tester,
  ) async {
    await pumpLayer(tester);
    final done = <bool>[];
    expect(await playAndWatch(tester, done), isFalse);
    expect(effects.current, isA<_Effect>());
    expect(effects.shake.value, const Offset(2, 0));
    await tester.pump(_length ~/ 2);
    expect(done, isEmpty);
    await tester.pump(_length);
    await tester.pump();
    expect(done, [true]);
    expect(effects.isPlaying, isFalse);
    expect(effects.shake.value, Offset.zero);
  });

  testWidgets('with reduced motion, an effect is over at once', (
    tester,
  ) async {
    reduceMotion(tester);
    await pumpLayer(tester);
    expect(await playAndWatch(tester, <bool>[]), isTrue);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('finishing an effect ends it at once', (tester) async {
    await pumpLayer(tester);
    final done = <bool>[];
    await playAndWatch(tester, done);
    effects.finish();
    await tester.pump();
    expect(done, [true]);
    expect(effects.shake.value, Offset.zero);
  });

  testWidgets('an effect is over when its layer leaves the screen', (
    tester,
  ) async {
    await pumpLayer(tester);
    final done = <bool>[];
    await playAndWatch(tester, done);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(done, [true]);
    await effects.play(const _Effect());
  });

  testWidgets('the effects never catch a tap', (tester) async {
    await pumpLayer(tester);
    effects.play(const _Effect());
    await tester.pump();
    final painter = tester
        .widget<CustomPaint>(find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is MapEffectPainter))
        .painter!;
    expect(painter.hitTest(const Offset(40, 40)), isFalse);
    expect(find.byType(IgnorePointer), findsWidgets);
    effects.finish();
  });
}
