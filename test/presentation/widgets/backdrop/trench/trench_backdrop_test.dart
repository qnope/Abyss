import 'package:abyss/presentation/theme/abyss_trench_theme.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/depth_haze.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/parallax_layer.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/trench_backdrop.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the trench lays its water far behind, its ridges nearer', (
    tester,
  ) async {
    final transform = TransformationController();
    addTearDown(transform.dispose);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: TrenchBackdrop(
          transform: transform, content: const Size(2000, 1000)),
    ));
    final layers = tester
        .widgetList<ParallaxLayer>(find.byType(ParallaxLayer))
        .toList();
    expect([for (final l in layers) l.rate],
        [TrenchBackdrop.farRate, TrenchBackdrop.midRate]);
    expect((TrenchBackdrop.farRate, TrenchBackdrop.midRate), (0.15, 0.35));
    expect(layers.first.tile, isA<TrenchWaterPainter>());
    expect(layers.last.tile, isA<TrenchRidgesPainter>());
    for (final layer in layers) {
      expect(layer.transform, same(transform));
      expect(layer.content, const Size(2000, 1000));
    }
    expect(find.ancestor(
        of: find.byType(ParallaxLayer).first,
        matching: find.byType(RepaintBoundary)), findsWidgets);
  });

  group('the depth haze', () {
    testWidgets('lies still over its box, painted once, never tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const DepthHaze());
      final haze = find.descendant(
          of: find.byType(DepthHaze), matching: find.byType(DecoratedBox));
      final box = tester.widget<DecoratedBox>(haze).decoration as BoxDecoration;
      expect(box.gradient, AbyssTrenchTheme.haze);
      expect(tester.getSize(haze), tester.view.physicalSize /
          tester.view.devicePixelRatio);
      expect(find.ancestor(of: haze, matching: find.byType(RepaintBoundary)),
          findsWidgets);
      expect(find.ancestor(of: haze, matching: find.byType(IgnorePointer)),
          findsWidgets);
    });

    test('is bluish high on the screen, clear in the middle, darker low',
        () {
      final colours = AbyssTrenchTheme.haze.colors;
      final stops = AbyssTrenchTheme.haze.stops!;
      expect(stops.first, 0);
      expect(stops.last, 1);
      final (top, middle, bottom) =
          (colours.first, colours[2], colours.last);
      expect(top.b, greaterThan(top.r));
      expect(top.a, greaterThan(bottom.a));
      expect(middle.a, 0);
      expect(bottom.a, greaterThan(middle.a));
      expect(bottom.computeLuminance(), lessThan(top.computeLuminance()));
    });
  });
}
