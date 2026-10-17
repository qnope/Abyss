import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/faction/base_intel.dart';
import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/faction_personality_extensions.dart';
import 'package:abyss/presentation/widgets/common/lore_text.dart';
import 'package:abyss/presentation/widgets/faction/faction_base_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/sheet_opener.dart';

BaseIntel _intel({int turn = 3}) => BaseIntel(
  turn: turn,
  headquartersLevel: 2,
  rampartLevel: 1,
  army: {UnitType.guardian: 4},
  stocks: {ResourceType.coral: 120},
);

/// Opens the sheet of the first faction of a new game, and returns it.
Future<Faction> _open(
  WidgetTester tester, {
  BaseIntel? intel,
  int turn = 4,
  ActionFailure? spyRefusal,
  VoidCallback? onSpy,
}) async {
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: 7,
    factionCount: 1,
  );
  final faction = game.factions.first;
  await openSheet(
    tester,
    const Locale('fr'),
    (context) => showFactionBaseSheet(
      context,
      faction: faction,
      headquartersLevel: 2,
      refusal: null,
      intel: intel,
      turn: turn,
      spyRefusal: spyRefusal,
      onSpy: onSpy ?? () {},
      onAttack: () {},
    ),
  );
  return faction;
}

void main() {
  testWidgets('tells where the faction comes from, under its name', (
    tester,
  ) async {
    final faction = await _open(tester);
    final origin = faction.personality.origin(fr);
    expect(find.widgetWithText(LoreText, origin), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(origin)).dy,
      greaterThan(tester.getTopLeft(find.text(faction.name)).dy),
    );
  });

  testWidgets('without a report, it says so and offers to spy', (tester) async {
    await _open(tester);
    expect(find.textContaining('Aucun rapport'), findsOneWidget);
    expect(find.text('Espionner'), findsOneWidget);
  });

  testWidgets('a fresh report shows the army, the rampart and the stocks', (
    tester,
  ) async {
    await _open(tester, intel: _intel());
    expect(find.text('Rapport d\'éclaireur'), findsOneWidget);
    expect(find.textContaining('4 gardiens'), findsOneWidget);
    expect(find.text('Rempart'), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget);
    expect(find.textContaining('Valable encore 4 tours'), findsOneWidget);
  });

  testWidgets('a stale report is marked as such', (tester) async {
    await _open(tester, intel: _intel(turn: 1), turn: 20);
    expect(find.textContaining('périmé'), findsOneWidget);
  });

  testWidgets('spying is off, with the reason, when refused', (tester) async {
    await _open(tester, spyRefusal: ActionFailure.notEnoughUnits);
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Espionner'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('tapping Spy closes the sheet and spies', (tester) async {
    var spied = 0;
    await _open(tester, onSpy: () => spied++);
    await tester.tap(find.text('Espionner'));
    await tester.pumpAndSettle();
    expect(spied, 1);
    expect(find.byType(FactionBaseSheet), findsNothing);
  });
}
