import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects_layer.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _length = Duration(milliseconds: 500);

class _Run implements MapEffectRun {
  @override
  Duration get duration => _length;

  @override
  Offset shakeAt(Duration elapsed) => Offset.zero;

  @override
  void paint(Canvas canvas, Duration elapsed) {}
}

class _Effect extends MapEffect {
  const _Effect();

  @override
  MapEffectRun stage(MapStage stage) => _Run();
}

/// Skipping, and effects played as the map opens for them: what the
/// story of a turn relies on.
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

  testWidgets('skipping ends the effect playing and counts the skip', (
    tester,
  ) async {
    await pumpLayer(tester);
    final done = <bool>[];
    effects.play(const _Effect()).then((_) => done.add(true));
    await tester.pump();
    final skips = effects.skips;
    effects.skip();
    await tester.pump();
    expect(done, [true]);
    expect(effects.skips, skips + 1);
  });

  testWidgets('an effect waiting for a stage plays on the layer shown next', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    final done = <bool>[];
    effects.play(const _Effect(), awaitStage: true).then((_) => done.add(true));
    await pumpLayer(tester);
    expect(effects.current, isA<_Effect>());
    expect(find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MapEffectPainter),
        findsOneWidget);
    await tester.pump(_length ~/ 2);
    expect(done, isEmpty);
    await tester.pump(_length);
    await tester.pump();
    expect(done, [true]);
  });

  testWidgets('an effect waiting for a stage is over when none comes', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    final done = <bool>[];
    effects.play(const _Effect(), awaitStage: true).then((_) => done.add(true));
    await tester.pump();
    await tester.pump();
    expect(done, [true]);
    expect(effects.isPlaying, isFalse);
  });
}
