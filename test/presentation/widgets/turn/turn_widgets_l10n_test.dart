import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/exploration_result.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/turn/turn_confirmation_dialog.dart';
import 'package:abyss/presentation/widgets/turn/turn_summary_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

Future<void> _open(
  WidgetTester t,
  Locale locale,
  void Function(BuildContext) open,
) async {
  await t.pumpWidget(localizedApp(
    Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => open(ctx),
          child: const Text('Open'),
        ),
      ),
    ),
    locale: locale,
  ));
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

TurnResult _result({
  List<TurnResourceChange> changes = const [],
  bool hadRecruitedUnits = false,
}) => TurnResult(
  changes: changes,
  previousTurn: 3,
  newTurn: 4,
  hadRecruitedUnits: hadRecruitedUnits,
  deactivatedBuildings: const [BuildingType.laboratory],
  lostUnits: const {UnitType.scout: 2},
  explorations: [
    ExplorationResult(target: GridPosition(x: 1, y: 2), newCellsRevealed: 1),
  ],
  event: RandomEventType.storm,
  defaultedEvent: RandomEventType.caravan,
);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('the end of turn to confirm in English', (t) async {
    await _open(t, AbyssLocale.en, (ctx) => showTurnConfirmationDialog(
      ctx,
      currentTurn: 4,
      production: const {},
      buildingsToDeactivate: const [BuildingType.laboratory],
      unitsToLose: const {UnitType.scout: 1},
      pendingExplorationCount: 2,
    ));
    expect(find.text('Turn 4 → Turn 5'), findsOneWidget);
    expect(find.text('Buildings deactivated'), findsOneWidget);
    expect(find.text('Units lost'), findsOneWidget);
    expect(find.text('2 pending explorations'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('nothing to produce in Spanish', (t) async {
    await _open(t, AbyssLocale.es, (ctx) => showTurnConfirmationDialog(
      ctx,
      currentTurn: 1,
      production: const {},
    ));
    expect(find.text('Ninguna producción este turno.'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('the turn summary in English', (t) async {
    final change = TurnResourceChange(
      type: ResourceType.algae,
      produced: 5,
      consumed: 0,
      wasCapped: true,
      beforeAmount: 0,
      afterAmount: 5,
    );
    await _open(t, AbyssLocale.en, (ctx) => showTurnSummaryDialog(
      ctx,
      result: _result(changes: [change], hadRecruitedUnits: true),
    ));
    expect(find.text('Turn 3 → Turn 4'), findsOneWidget);
    expect(find.text('(max reached)'), findsOneWidget);
    expect(find.text('Exploration: 1 new cell'), findsOneWidget);
    expect(find.text('(1, 2) → 1 cell'), findsOneWidget);
    expect(find.textContaining(': cautious option applied'), findsOneWidget);
    expect(find.textContaining('Event: '), findsOneWidget);
    expect(find.text('Recruitment available'), findsOneWidget);
  });

  testWidgets('the turn summary in Spanish', (t) async {
    await _open(t, AbyssLocale.es, (ctx) => showTurnSummaryDialog(
      ctx,
      result: _result(),
    ));
    expect(find.text('Turno 3 → Turno 4'), findsOneWidget);
    expect(find.text('Edificios desactivados'), findsOneWidget);
    expect(find.text('Unidades perdidas'), findsOneWidget);
    expect(find.text('Exploración: 1 casilla nueva'), findsOneWidget);
  });

  testWidgets('no change in Spanish', (t) async {
    await _open(t, AbyssLocale.es, (ctx) => showTurnSummaryDialog(
      ctx,
      result: const TurnResult(
        changes: [],
        previousTurn: 1,
        newTurn: 2,
        hadRecruitedUnits: false,
      ),
    ));
    expect(find.text('Ningún cambio este turno.'), findsOneWidget);
  });
}
