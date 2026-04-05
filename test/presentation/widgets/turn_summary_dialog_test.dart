import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/turn_result.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn_summary_dialog.dart';
import '../../helpers/test_svg_helper.dart';

Widget _app(TurnResult result) {
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

TurnResult _result({
  List<TurnResourceChange> changes = const [],
  int previousTurn = 3,
  int newTurn = 4,
  bool hadRecruitedUnits = false,
}) => TurnResult(
  changes: changes,
  previousTurn: previousTurn,
  newTurn: newTurn,
  hadRecruitedUnits: hadRecruitedUnits,
);

TurnResourceChange _change({
  ResourceType type = ResourceType.algae,
  int produced = 50,
  bool wasCapped = false,
  int beforeAmount = 100,
  int afterAmount = 150,
}) => TurnResourceChange(
  type: type,
  produced: produced,
  wasCapped: wasCapped,
  beforeAmount: beforeAmount,
  afterAmount: afterAmount,
);

Future<void> _open(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void main() {
  group('TurnSummaryDialog', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows turn transition title', (t) async {
      await t.pumpWidget(_app(_result(changes: [_change()])));
      await _open(t);
      expect(find.text('Tour 3 → Tour 4'), findsOneWidget);
    });

    testWidgets('shows resource progression', (t) async {
      await t.pumpWidget(_app(_result(changes: [
        _change(beforeAmount: 100, produced: 50, afterAmount: 150),
      ])));
      await _open(t);
      expect(find.text('100 (+50) → 150'), findsOneWidget);
    });

    testWidgets('shows capping indicator with MAX', (t) async {
      await t.pumpWidget(_app(_result(changes: [
        _change(
          wasCapped: true,
          beforeAmount: 490,
          produced: 50,
          afterAmount: 500,
        ),
      ])));
      await _open(t);
      expect(find.text('(MAX)'), findsOneWidget);
    });

    testWidgets('no capping indicator when not capped', (t) async {
      await t.pumpWidget(_app(_result(changes: [_change()])));
      await _open(t);
      expect(find.text('(MAX)'), findsNothing);
    });

    testWidgets('shows negative net in red', (t) async {
      await t.pumpWidget(_app(_result(changes: [
        _change(produced: -10, beforeAmount: 100, afterAmount: 90),
      ])));
      await _open(t);
      expect(find.text('100 (-10) → 90'), findsOneWidget);
    });

    testWidgets('shows army section when recruited', (t) async {
      await t.pumpWidget(_app(_result(
        changes: [_change()],
        hadRecruitedUnits: true,
      )));
      await _open(t);
      expect(find.text('Recrutement disponible'), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('hides army section when no recruitment', (t) async {
      await t.pumpWidget(_app(_result(changes: [_change()])));
      await _open(t);
      expect(find.text('Recrutement disponible'), findsNothing);
    });

    testWidgets('empty changes with no recruitment shows message', (t) async {
      await t.pumpWidget(_app(_result()));
      await _open(t);
      expect(find.text('Aucun changement ce tour.'), findsOneWidget);
    });

    testWidgets('empty changes with recruitment shows army', (t) async {
      await t.pumpWidget(_app(_result(hadRecruitedUnits: true)));
      await _open(t);
      expect(find.text('Recrutement disponible'), findsOneWidget);
      expect(find.text('Aucun changement ce tour.'), findsNothing);
    });

    testWidgets('OK closes dialog', (t) async {
      await t.pumpWidget(_app(_result(changes: [_change()])));
      await _open(t);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(find.text('Tour 3 → Tour 4'), findsNothing);
    });
  });
}
