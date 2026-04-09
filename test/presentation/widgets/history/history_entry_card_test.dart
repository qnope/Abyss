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
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';

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

CombatEntry _combatEntry({
  required bool victory,
  int turn = 5,
  String? subtitle,
}) => CombatEntry(
  turn: turn,
  victory: victory,
  targetX: 0,
  targetY: 0,
  lair: const MonsterLair(
    difficulty: MonsterDifficulty.easy,
    unitCount: 1,
  ),
  fightResult: _fakeFightResult(victory: victory),
  loot: const {},
  sent: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
  subtitle: subtitle,
);

BuildingEntry _buildingEntry({int turn = 3}) => BuildingEntry(
  turn: turn,
  buildingType: BuildingType.algaeFarm,
  newLevel: 2,
  subtitle: 'Production accrue',
);

Widget _wrap(Widget child) => MaterialApp(
  theme: AbyssTheme.create(),
  home: Scaffold(body: child),
);

void main() {
  group('HistoryEntryCard', () {
    testWidgets('BuildingEntry renders icon, title, subtitle and Tour N',
        (tester) async {
      final entry = _buildingEntry(turn: 4);

      await tester.pumpWidget(_wrap(HistoryEntryCard(entry: entry)));

      expect(find.byIcon(Icons.build), findsOneWidget);
      expect(find.text(entry.title), findsOneWidget);
      expect(find.text('Production accrue'), findsOneWidget);
      expect(find.text('Tour 4'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);

      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.onTap, isNull);
    });

    testWidgets('BuildingEntry tap does nothing when no handler provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(HistoryEntryCard(entry: _buildingEntry())),
      );

      // Tapping must not throw even without a handler.
      await tester.tap(find.byType(ListTile));
      await tester.pump();
    });

    testWidgets('CombatEntry victory shows chevron and fires onTap',
        (tester) async {
      var tapped = 0;
      final entry = _combatEntry(victory: true, turn: 7);

      await tester.pumpWidget(
        _wrap(
          HistoryEntryCard(
            entry: entry,
            onTap: () => tapped++,
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      // The turn number is moved into the subtitle on tappable entries.
      expect(find.textContaining('Tour 7'), findsOneWidget);

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('CombatEntry with null onTap is not tappable visually',
        (tester) async {
      final entry = _combatEntry(victory: false);

      await tester.pumpWidget(
        _wrap(HistoryEntryCard(entry: entry)),
      );

      // Chevron is still drawn (it is based on isTappable, not onTap).
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.onTap, isNull);

      // Tapping without a handler must not throw.
      await tester.tap(find.byType(ListTile));
      await tester.pump();
    });
  });
}
