import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/turn_result.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn_summary_dialog.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  Widget createApp(TurnResult result) {
    return MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showTurnSummaryDialog(ctx, result: result),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester t) async {
    await t.tap(find.text('Open'));
    await t.pumpAndSettle();
  }

  group('TurnSummaryDialog', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows title', (t) async {
      final result = TurnResult(changes: [
        TurnResourceChange(
          type: ResourceType.algae,
          produced: 5,
          wasCapped: false,
        ),
      ]);
      await t.pumpWidget(createApp(result));
      await openDialog(t);
      expect(find.text('Resume du tour'), findsOneWidget);
    });

    testWidgets('shows gained resources', (t) async {
      final result = TurnResult(changes: [
        TurnResourceChange(
          type: ResourceType.algae,
          produced: 5,
          wasCapped: false,
        ),
        TurnResourceChange(
          type: ResourceType.coral,
          produced: 8,
          wasCapped: false,
        ),
      ]);
      await t.pumpWidget(createApp(result));
      await openDialog(t);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('+8'), findsOneWidget);
      expect(find.text('Algues'), findsOneWidget);
      expect(find.text('Corail'), findsOneWidget);
    });

    testWidgets('shows capping indicator', (t) async {
      final result = TurnResult(changes: [
        TurnResourceChange(
          type: ResourceType.algae,
          produced: 5,
          wasCapped: true,
        ),
      ]);
      await t.pumpWidget(createApp(result));
      await openDialog(t);
      expect(find.text('(max atteint)'), findsOneWidget);
    });

    testWidgets('no capping indicator when not capped', (t) async {
      final result = TurnResult(changes: [
        TurnResourceChange(
          type: ResourceType.algae,
          produced: 5,
          wasCapped: false,
        ),
      ]);
      await t.pumpWidget(createApp(result));
      await openDialog(t);
      expect(find.text('(max atteint)'), findsNothing);
    });

    testWidgets('empty changes shows message', (t) async {
      final result = TurnResult(changes: []);
      await t.pumpWidget(createApp(result));
      await openDialog(t);
      expect(find.text('Aucun changement ce tour.'), findsOneWidget);
    });

    testWidgets('OK closes dialog', (t) async {
      final result = TurnResult(changes: [
        TurnResourceChange(
          type: ResourceType.algae,
          produced: 5,
          wasCapped: false,
        ),
      ]);
      await t.pumpWidget(createApp(result));
      await openDialog(t);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(find.text('Resume du tour'), findsNothing);
    });
  });
}
