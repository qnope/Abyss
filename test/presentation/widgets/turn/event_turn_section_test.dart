import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/raid/raid_report.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn/turn_summary_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/event/effects/predators_test_helper.dart';
import '../../../helpers/fight_result_helpers.dart';

RaidReport _predators({required bool victory}) => RaidReport(
  turn: 12,
  victory: victory,
  wave: predatorTestWave,
  fight: oneTurnFightResult(victory: victory),
  rampartLevel: 0,
  defenders: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
  loot: const {},
  pillaged: const {},
  surprise: true,
);

TurnResult _result({
  RandomEventType? event,
  RandomEventType? defaulted,
  RaidReport? predators,
}) => TurnResult(
  changes: const [],
  previousTurn: 12,
  newTurn: 13,
  hadRecruitedUnits: false,
  event: event,
  defaultedEvent: defaulted,
  predators: predators,
);

void main() {
  Future<void> open(WidgetTester tester, TurnResult result) async {
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTurnSummaryDialog(context, result: result),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('names the event drawn this turn', (tester) async {
    await open(tester, _result(event: RandomEventType.storm));
    expect(find.text('Événement : Tempête'), findsOneWidget);
    expect(find.text('Aucun changement ce tour.'), findsNothing);
  });

  testWidgets('says the prudent option applied to a forgotten event', (
    tester,
  ) async {
    await open(tester, _result(defaulted: RandomEventType.caravan));
    expect(
      find.text('Caravane de tortues : option prudente appliquée'),
      findsOneWidget,
    );
  });

  testWidgets('tells how the predators fight ended', (tester) async {
    await open(tester, _result(predators: _predators(victory: true)));
    expect(find.text('Banc de prédateurs repoussé'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await open(tester, _result(predators: _predators(victory: false)));
    expect(
      find.text('Le banc de prédateurs a pillé la base'),
      findsOneWidget,
    );
  });
}
