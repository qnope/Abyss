import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_node_state.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech/dashed_ring_painter.dart';
import 'package:abyss/presentation/widgets/tech/tech_node_widget.dart';

void main() {
  group('TechNodeWidget', () {
    Widget build(TechNodeState state, {VoidCallback? onTap}) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Center(
            child: TechNodeWidget(
              color: Colors.pink,
              state: state,
              label: '+40%',
              caption: 'Niv. 2',
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    Finder dashedRing() => find.byWidgetPredicate((w) =>
        w is CustomPaint && w.foregroundPainter is DashedRingPainter);

    testWidgets('displays bonus label and caption', (t) async {
      await t.pumpWidget(build(TechNodeState.researched));
      expect(find.text('+40%'), findsOneWidget);
      expect(find.text('Niv. 2'), findsOneWidget);
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

    testWidgets('researched node glows', (t) async {
      await t.pumpWidget(build(TechNodeState.researched));
      final box = t.widget<Container>(find.byType(Container).first);
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('onTap callback fires', (t) async {
      var tapped = false;
      await t.pumpWidget(
        build(TechNodeState.locked, onTap: () => tapped = true));
      await t.tap(find.text('+40%'));
      expect(tapped, isTrue);
    });
  });
}
