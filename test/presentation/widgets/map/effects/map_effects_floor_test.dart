import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects_layer.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _length = Duration(milliseconds: 500);
const _cells = {(2, 2), (3, 2)};

/// A run fading in the contents of [_cells] as it plays, from 0 to 1.
class _Run extends MapEffectRun {
  @override
  Duration get duration => _length;

  @override
  Offset shakeAt(Duration elapsed) => Offset.zero;

  @override
  void paint(Canvas canvas, Duration elapsed) {}

  @override
  Set<(int, int)> get fadedCells => _cells;

  @override
  double contentOpacityAt(Duration elapsed) =>
      elapsed.inMicroseconds / _length.inMicroseconds;
}

class _Effect extends MapEffect {
  final List<MapStage> stages;

  const _Effect(this.stages);

  @override
  MapEffectRun stage(MapStage stage) {
    stages.add(stage);
    return _Run();
  }
}

void main() {
  late MapEffects effects;
  final stages = <MapStage>[];
  setUp(() {
    effects = MapEffects();
    stages.clear();
  });
  tearDown(() => effects.dispose());

  Future<void> pumpLayer(WidgetTester tester) => tester.pumpWidget(
        MapEffectsLayer(
          effects: effects,
          size: const Size(10 * cellSize, 10 * cellSize),
          originOf: (target) => (0, 0),
          columns: 10,
          rows: 8,
          child: const SizedBox(key: Key('between')),
        ),
      );

  /// What the layer shows, back to front.
  List<Widget> shown(WidgetTester tester) => [
        for (final element in find
            .byWidgetPredicate((w) =>
                w.key == const Key('between') ||
                (w is CustomPaint && w.painter != null))
            .evaluate())
          element.widget,
      ];

  testWidgets('paints the floor of an effect under what it wraps, the '
      'rest over it', (tester) async {
    await pumpLayer(tester);
    effects.play(_Effect(stages));
    await tester.pump();
    final [floor, between, over] = shown(tester);
    expect((floor as CustomPaint).painter, isA<MapEffectFloorPainter>());
    expect(between.key, const Key('between'));
    expect((over as CustomPaint).painter, isA<MapEffectPainter>());
    effects.finish();
  });

  testWidgets('tells the map which contents fade, and how much, as the '
      'effect plays', (tester) async {
    await pumpLayer(tester);
    effects.play(_Effect(stages));
    await tester.pump();
    expect(effects.fade.cells, _cells);
    expect(effects.fade.opacity, 0);
    await tester.pump(_length ~/ 2);
    expect(effects.fade.opacity, closeTo(0.5, 0.01));
    await tester.pump(_length);
    await tester.pump();
    expect(effects.fade.cells, isEmpty);
    expect(effects.fade.opacity, 1);
  });

  testWidgets('shows every content whole once an effect is ended or its '
      'layer gone', (tester) async {
    await pumpLayer(tester);
    effects.play(_Effect(stages));
    await tester.pump();
    effects.finish();
    expect(effects.fade.cells, isEmpty);
    effects.play(_Effect(stages));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    expect(effects.fade.cells, isEmpty);
  });

  testWidgets('stages an effect on a map of its size', (tester) async {
    await pumpLayer(tester);
    effects.play(_Effect(stages));
    await tester.pump();
    expect((stages.single.columns, stages.single.rows), (10, 8));
    effects.finish();
  });
}
