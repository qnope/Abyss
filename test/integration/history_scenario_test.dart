import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/action/unlock_branch_action.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'history_integration_helper.dart';

void main() {
  group('End-to-end history scenario', () {
    test('seven actions via ActionExecutor produce seven history entries',
        () {
      final game = buildHistoryScenarioGame();
      final player = game.humanPlayer;
      final executor = ActionExecutor();

      // Turn 1: upgrade the hatchery/algae farm (cheapest available upgrade).
      game.turn = 1;
      final r1 = executor.execute(
        UpgradeBuildingAction(buildingType: BuildingType.headquarters),
        game,
        player,
      );
      expect(r1.isSuccess, isTrue, reason: 'Step 1 (upgrade) must succeed');

      // Turn 2: unlock the military branch.
      game.turn = 2;
      final r2 = executor.execute(
        UnlockBranchAction(branch: TechBranch.military),
        game,
        player,
      );
      expect(r2.isSuccess, isTrue, reason: 'Step 2 (unlock) must succeed');

      // Turn 3: recruit a scout.
      game.turn = 3;
      final r3 = executor.execute(
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1),
        game,
        player,
      );
      expect(r3.isSuccess, isTrue, reason: 'Step 3 (recruit) must succeed');

      // Turn 4: explore a revealed, eligible cell (not the base).
      game.turn = 4;
      final r4 = executor.execute(
        ExploreAction(targetX: 5, targetY: 3),
        game,
        player,
      );
      expect(r4.isSuccess, isTrue, reason: 'Step 4 (explore) must succeed');

      // Turn 5: collect the pre-placed resourceBonus at (4, 3).
      game.turn = 5;
      final r5 = executor.execute(
        CollectTreasureAction(targetX: 4, targetY: 3, random: Random(0)),
        game,
        player,
      );
      expect(r5.isSuccess, isTrue, reason: 'Step 5 (collect) must succeed');

      // Turn 6: fight the pre-placed monster lair at (2, 3) with
      // deterministic RNG (seed 0).
      game.turn = 6;
      final r6 = executor.execute(
        FightMonsterAction(
          targetX: 2,
          targetY: 3,
          level: 1,
          selectedUnits: const {UnitType.harpoonist: 15},
          random: Random(0),
        ),
        game,
        player,
      );
      expect(r6.isSuccess, isTrue, reason: 'Step 6 (fight) must succeed');

      // Turn 7: end the turn.
      game.turn = 7;
      final r7 = executor.execute(EndTurnAction(), game, player);
      expect(r7.isSuccess, isTrue, reason: 'Step 7 (endTurn) must succeed');

      // Final assertions: exactly seven history entries, in insertion order,
      // each category matches the action kind and each turn value matches.
      expect(player.historyEntries.length, 7);

      final expectedCategories = <HistoryEntryCategory>[
        HistoryEntryCategory.building,
        HistoryEntryCategory.research,
        HistoryEntryCategory.recruit,
        HistoryEntryCategory.explore,
        HistoryEntryCategory.collect,
        HistoryEntryCategory.combat,
        HistoryEntryCategory.turnEnd,
      ];

      for (var i = 0; i < expectedCategories.length; i++) {
        final entry = player.historyEntries[i];
        expect(
          entry.category,
          expectedCategories[i],
          reason: 'Entry $i should be ${expectedCategories[i]}',
        );
        expect(
          entry.turn,
          i + 1,
          reason: 'Entry $i should carry turn ${i + 1}',
        );
      }

      // Spot-check concrete subtypes.
      expect(player.historyEntries[0], isA<BuildingEntry>());
      expect(player.historyEntries[1], isA<ResearchEntry>());
      expect(player.historyEntries[2], isA<RecruitEntry>());
      expect(player.historyEntries[3], isA<ExploreEntry>());
      expect(player.historyEntries[4], isA<CollectEntry>());
      expect(player.historyEntries[5], isA<CombatEntry>());
      expect(player.historyEntries[6], isA<TurnEndEntry>());
    });
  });
}
