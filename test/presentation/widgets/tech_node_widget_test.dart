import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech_node_state.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech_node_widget.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  group('TechNodeWidget', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget build(TechNodeState state, {int? level, VoidCallback? onTap}) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: TechNodeWidget(
            iconPath: 'assets/icons/buildings/barracks.svg',
            color: Colors.pink,
            state: state,
            level: level,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('researched state has full opacity', (t) async {
      await t.pumpWidget(build(TechNodeState.researched));
      final opacity = t.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });

    testWidgets('locked state has reduced opacity', (t) async {
      await t.pumpWidget(build(TechNodeState.locked));
      final opacity = t.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.3);
    });

    testWidgets('accessible state has intermediate opacity', (t) async {
      await t.pumpWidget(build(TechNodeState.accessible));
      final opacity = t.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.7);
    });

    testWidgets('displays level badge when level is set', (t) async {
      await t.pumpWidget(build(TechNodeState.researched, level: 3));
      expect(find.text('Niv. 3'), findsOneWidget);
    });

    testWidgets('hides level badge when level is null', (t) async {
      await t.pumpWidget(build(TechNodeState.researched));
      expect(find.textContaining('Niv.'), findsNothing);
    });

    testWidgets('onTap callback fires', (t) async {
      var tapped = false;
      await t.pumpWidget(
        build(TechNodeState.researched, onTap: () => tapped = true),
      );
      await t.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });
  });
}
