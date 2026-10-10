import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_node_state.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/tech/dashed_ring_painter.dart';
import 'package:abyss/presentation/widgets/tech/tech_node_widget.dart';

import '../../../helpers/test_svg_helper.dart';

const _icon = 'assets/icons/tech/military_2a.svg';

void main() {
  group('TechNodeWidget', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget build(TechNodeState state, {VoidCallback? onTap}) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Center(
            child: TechNodeWidget(
              color: Colors.pink,
              state: state,
              iconPath: _icon,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    Finder painted(bool Function(CustomPainter?) test) => find.descendant(
        of: find.byType(TechNodeWidget),
        matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && test(w.foregroundPainter)));

    Finder dashedRing() => painted((p) => p is DashedRingPainter);

    BoxDecoration decoration(WidgetTester t) =>
        t.widget<Container>(find.byType(Container).first).decoration!
            as BoxDecoration;

    RasterSvg icon(WidgetTester t) => t.widget<RasterSvg>(find.byType(RasterSvg));

    testWidgets('displays its icon', (t) async {
      await t.pumpWidget(build(TechNodeState.researched));
      expect(icon(t).assetPath, _icon);
      expect(icon(t).greyscale, isFalse);
      expect(icon(t).opacity, 1);
    });

    testWidgets('accessible node shows its icon in colour', (t) async {
      await t.pumpWidget(build(TechNodeState.accessible));
      expect(icon(t).greyscale, isFalse);
    });

    testWidgets('locked node shows its icon faded in greyscale', (t) async {
      await t.pumpWidget(build(TechNodeState.locked));
      expect(icon(t).greyscale, isTrue);
      expect(icon(t).opacity, AbyssColors.unavailableOpacity);
    });

    testWidgets('accessible node is ringed with dashes', (t) async {
      await t.pumpWidget(build(TechNodeState.accessible));
      expect(dashedRing(), findsOneWidget);
    });

    testWidgets('researched and locked nodes have no dashed ring',
        (t) async {
      await t.pumpWidget(build(TechNodeState.researched));
      expect(dashedRing(), findsNothing);
      await t.pumpWidget(build(TechNodeState.locked));
      expect(dashedRing(), findsNothing);
    });

    testWidgets('discarded node is struck through and greyed', (t) async {
      await t.pumpWidget(build(TechNodeState.discarded));
      expect(dashedRing(), findsNothing);
      expect(painted((p) => p != null && p is! DashedRingPainter),
          findsOneWidget);
      expect(icon(t).greyscale, isTrue);
      expect(icon(t).opacity, 1);
    });

    testWidgets('researched node glows with its colour', (t) async {
      await t.pumpWidget(build(TechNodeState.researched));
      expect((decoration(t).border! as Border).top.color, Colors.pink);
    });

    testWidgets('onTap callback fires', (t) async {
      var tapped = false;
      await t.pumpWidget(
        build(TechNodeState.locked, onTap: () => tapped = true));
      await t.tap(find.byType(TechNodeWidget));
      expect(tapped, isTrue);
    });
  });
}
