import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/turn_result.dart';
import 'package:abyss/domain/unit_type.dart';
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
  List<BuildingType> deactivatedBuildings = const [],
  Map<UnitType, int> lostUnits = const {},
}) => TurnResult(
  changes: changes,
  previousTurn: previousTurn,
  newTurn: newTurn,
  hadRecruitedUnits: hadRecruitedUnits,
  deactivatedBuildings: deactivatedBuildings,
  lostUnits: lostUnits,
);

TurnResourceChange _change({
  ResourceType type = ResourceType.algae,
  int produced = 50,
  int consumed = 0,
  bool wasCapped = false,
  int beforeAmount = 100,
  int afterAmount = 150,
}) => TurnResourceChange(
  type: type,
  produced: produced,
  consumed: consumed,
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
      expect(find.text('Tour 3 \u2192 Tour 4'), findsOneWidget);
    });

    testWidgets('shows gained resources', (t) async {
      await t.pumpWidget(_app(_result(changes: [
        _change(type: ResourceType.algae, produced: 5),
        _change(type: ResourceType.coral, produced: 8),
      ])));
      await _open(t);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('+8'), findsOneWidget);
      expect(find.text('Algues'), findsOneWidget);
      expect(find.text('Corail'), findsOneWidget);
    });

    testWidgets('shows capping indicator', (t) async {
      await t.pumpWidget(_app(_result(changes: [
        _change(wasCapped: true),
      ])));
      await _open(t);
      expect(find.text('(max atteint)'), findsOneWidget);
    });

    testWidgets('no capping indicator when not capped', (t) async {
      await t.pumpWidget(_app(_result(changes: [_change()])));
      await _open(t);
      expect(find.text('(max atteint)'), findsNothing);
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

    testWidgets('empty changes shows message', (t) async {
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
      expect(find.text('Tour 3 \u2192 Tour 4'), findsNothing);
    });
  });

  group('consumption display', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows consumed amount', (t) async {
      await t.pumpWidget(_app(_result(changes: [
        _change(type: ResourceType.energy, produced: 18, consumed: 8),
      ])));
      await _open(t);
      expect(find.text('+18/-8'), findsOneWidget);
    });

    testWidgets('shows deactivated buildings', (t) async {
      await t.pumpWidget(_app(_result(
        changes: [_change()],
        deactivatedBuildings: [BuildingType.coralMine],
      )));
      await _open(t);
      expect(find.text('Batiments desactives'), findsOneWidget);
      expect(find.text('Mine de corail'), findsOneWidget);
    });

    testWidgets('shows lost units', (t) async {
      await t.pumpWidget(_app(_result(
        changes: [_change()],
        lostUnits: {UnitType.guardian: 3},
      )));
      await _open(t);
      expect(find.text('Unites perdues'), findsOneWidget);
      expect(find.text('Gardien: -3'), findsOneWidget);
    });

    testWidgets('no consumption sections when none', (t) async {
      await t.pumpWidget(_app(_result(changes: [_change()])));
      await _open(t);
      expect(find.text('Batiments desactives'), findsNothing);
      expect(find.text('Unites perdues'), findsNothing);
    });
  });
}
