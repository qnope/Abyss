import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/screens/game/fight/fight_summary_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';
import 'package:abyss/presentation/widgets/history/history_sheet_body.dart';

FightResult _fakeFightResult({required bool victory}) {
  final combatant = Combatant(
    side: CombatSide.player,
    typeKey: 'scout',
    maxHp: 10,
    atk: 3,
    def: 1,
  );
  return FightResult(
    winner: victory ? CombatSide.player : CombatSide.monster,
    turnCount: 1,
    turnSummaries: const [
      FightTurnSummary(
        turnNumber: 1,
        attacksPlayed: 2,
        critCount: 0,
        damageDealtByPlayer: 5,
        damageDealtByMonster: 3,
        playerAliveAtEnd: 1,
        monsterAliveAtEnd: 0,
        playerHpAtEnd: 7,
        monsterHpAtEnd: 0,
      ),
    ],
    initialPlayerCombatants: [combatant],
    finalPlayerCombatants: [combatant],
    initialMonsterCount: 1,
    finalMonsterCount: 0,
  );
}

CombatEntry _combatEntry({int turn = 5}) => CombatEntry(
  turn: turn,
  victory: true,
  targetX: 3,
  targetY: 4,
  lair: const MonsterLair(
    difficulty: MonsterDifficulty.easy,
    unitCount: 1,
  ),
  fightResult: _fakeFightResult(victory: true),
  loot: const {},
  sent: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
);

BuildingEntry _buildingEntry({int turn = 3}) => BuildingEntry(
  turn: turn,
  buildingType: BuildingType.algaeFarm,
  newLevel: 2,
);

ResearchEntry _researchEntry({int turn = 2}) => ResearchEntry(
  turn: turn,
  branch: TechBranch.military,
  isUnlock: false,
  newLevel: 1,
);

Widget _wrap(Widget child) => MaterialApp(
  theme: AbyssTheme.create(),
  home: Scaffold(body: child),
);

void main() {
  group('HistorySheetBody', () {
    testWidgets('empty history shows empty-state text', (tester) async {
      await tester.pumpWidget(_wrap(const HistorySheetBody(entries: [])));

      expect(
        find.text('Aucune action enregistrée pour l\'instant.'),
        findsOneWidget,
      );
      expect(find.byType(HistoryEntryCard), findsNothing);
    });

    testWidgets('renders cards in reverse order (newest first)',
        (tester) async {
      final entries = <HistoryEntry>[
        _buildingEntry(turn: 1),
        _researchEntry(turn: 2),
        _combatEntry(turn: 3),
      ];

      await tester.pumpWidget(_wrap(HistorySheetBody(entries: entries)));

      final cards = tester.widgetList<HistoryEntryCard>(
        find.byType(HistoryEntryCard),
      );
      expect(cards.length, 3);
      expect(cards.elementAt(0).entry.turn, 3);
      expect(cards.elementAt(1).entry.turn, 2);
      expect(cards.elementAt(2).entry.turn, 1);
    });

    testWidgets('tapping a combat card pushes FightSummaryScreen',
        (tester) async {
      final entries = <HistoryEntry>[_combatEntry(turn: 7)];

      await tester.pumpWidget(_wrap(HistorySheetBody(entries: entries)));
      await tester.tap(find.byType(HistoryEntryCard));
      await tester.pumpAndSettle();

      expect(find.byType(FightSummaryScreen), findsOneWidget);
    });

    testWidgets('tapping a non-combat card does not navigate',
        (tester) async {
      final entries = <HistoryEntry>[_buildingEntry(turn: 4)];

      await tester.pumpWidget(_wrap(HistorySheetBody(entries: entries)));
      await tester.tap(find.byType(HistoryEntryCard));
      await tester.pumpAndSettle();

      expect(find.byType(FightSummaryScreen), findsNothing);
      expect(find.byType(HistorySheetBody), findsOneWidget);
    });

    testWidgets('changing the filter narrows the list', (tester) async {
      final entries = <HistoryEntry>[
        _buildingEntry(turn: 1),
        _researchEntry(turn: 2),
        _combatEntry(turn: 3),
      ];

      await tester.pumpWidget(_wrap(HistorySheetBody(entries: entries)));
      expect(find.byType(HistoryEntryCard), findsNWidgets(3));

      await tester.tap(find.text('Combats'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryEntryCard), findsOneWidget);
      final card = tester.widget<HistoryEntryCard>(
        find.byType(HistoryEntryCard),
      );
      expect(card.entry, isA<CombatEntry>());
    });

    testWidgets('rebuilding the body resets the filter to all',
        (tester) async {
      final entries = <HistoryEntry>[
        _buildingEntry(turn: 1),
        _combatEntry(turn: 2),
      ];

      // First "open": apply Combats filter.
      await tester.pumpWidget(
        _wrap(HistorySheetBody(key: const ValueKey('first'), entries: entries)),
      );
      await tester.tap(find.text('Combats'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryEntryCard), findsOneWidget);

      // Rebuild with a different key to simulate closing and reopening
      // the sheet (new State instance → default filter).
      await tester.pumpWidget(
        _wrap(HistorySheetBody(key: const ValueKey('second'), entries: entries)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HistoryEntryCard), findsNWidgets(2));
    });
  });
}
