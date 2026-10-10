import 'package:abyss/presentation/widgets/guide/guide_halo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'guide_widget_helpers.dart';

void main() {
  Widget halo({required bool active, bool still = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: still),
      child: Center(
        child: GuideHalo(active: active, child: const Text('Caserne')),
      ),
    ),
  );

  CustomPaint paintOf(WidgetTester tester) => tester.widget<CustomPaint>(
    find
        .descendant(
          of: find.byType(GuideHalo),
          matching: find.byType(CustomPaint),
        )
        .first,
  );

  testWidgets('inactive, shows the child alone, without animating', (
    tester,
  ) async {
    await tester.pumpWidget(halo(active: false));

    expect(find.text('Caserne'), findsOneWidget);
    expect(paintOf(tester).painter, isNull);
    expect(paintOf(tester).foregroundPainter, isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('glows outside the child, a crisp outline alone in front', (
    tester,
  ) async {
    await tester.pumpWidget(halo(active: true));
    final render = tester.renderObject(
      find.descendant(
        of: find.byType(GuideHalo),
        matching: find.byType(CustomPaint),
      ).first,
    );

    expect(
      render,
      paints
        ..clipPath()
        ..rrect(hasMaskFilter: true)
        ..paragraph()
        ..rrect(hasMaskFilter: false, strokeWidth: 2),
    );
    expect(render, isNot(paints..paragraph()..rrect(hasMaskFilter: true)));
  });

  testWidgets('active, pulses a glow around the child', (tester) async {
    await tester.pumpWidget(halo(active: true));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Caserne'), findsOneWidget);
    expect(paintOf(tester).foregroundPainter, isNotNull);
    expect(tester.hasRunningAnimations, isTrue);
    expect(haloAround(find.text('Caserne')), findsOneWidget);
  });

  testWidgets('stops pulsing once inactive', (tester) async {
    await tester.pumpWidget(halo(active: true));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(halo(active: false));

    expect(paintOf(tester).painter, isNull);
    expect(paintOf(tester).foregroundPainter, isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('glows still when animations are disabled', (tester) async {
    await tester.pumpWidget(halo(active: true, still: true));

    expect(paintOf(tester).foregroundPainter, isNotNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('keeps the state of its child when it toggles', (tester) async {
    final key = GlobalKey();
    Widget app(bool active) =>
        MaterialApp(home: GuideHalo(active: active, child: SizedBox(key: key)));
    await tester.pumpWidget(app(false));
    final element = key.currentContext;

    await tester.pumpWidget(app(true));

    expect(key.currentContext, same(element));
  });

  testWidgets('is disposed while pulsing without error', (tester) async {
    await tester.pumpWidget(halo(active: true));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
