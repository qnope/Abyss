import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/fight_summary_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';
import 'package:abyss/presentation/widgets/history/history_sheet_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'history_integration_helper.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets(
    'tapping a combat history card pushes FightSummaryScreen with the '
    'original fight result',
    (tester) async {
      // 1. Arrange: produce a real CombatEntry by running a fight through
      //    the executor against the pre-placed lair at (2, 3).
      final game = buildHistoryScenarioGame();
      final player = game.humanPlayer;
      final executor = ActionExecutor();

      game.turn = 1;
      final result = executor.execute(
        FightMonsterAction(
          targetX: 2,
          targetY: 3,
          selectedUnits: const {UnitType.harpoonist: 15},
          random: Random(0),
        ),
        game,
        player,
      );
      expect(result.isSuccess, isTrue);
      expect(player.historyEntries, hasLength(1));
      final entry = player.historyEntries.single as CombatEntry;
      final expectedTurnCount = entry.fightResult.turnCount;

      // 2. Act: render the history sheet body and tap the single combat
      //    card.
      await tester.pumpWidget(
        _wrap(HistorySheetBody(entries: player.historyEntries)),
      );
      expect(find.byType(HistoryEntryCard), findsOneWidget);

      await tester.tap(find.byType(HistoryEntryCard));
      await tester.pumpAndSettle();

      // 3. Assert: FightSummaryScreen is pushed and shows the same
      //    turn-count as the recorded combat.
      expect(find.byType(FightSummaryScreen), findsOneWidget);
      final pushed = tester.widget<FightSummaryScreen>(
        find.byType(FightSummaryScreen),
      );
      expect(pushed.result.fight!.turnCount, expectedTurnCount);
      expect(pushed.lair, entry.lair);
      expect(pushed.targetX, entry.targetX);
      expect(pushed.targetY, entry.targetY);
    },
  );
}
