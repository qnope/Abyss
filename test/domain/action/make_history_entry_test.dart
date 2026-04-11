import 'dart:math';

import 'package:abyss/domain/action/action.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/action/research_tech_action.dart';
import 'package:abyss/domain/action/unlock_branch_action.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'collect_treasure_action_helper.dart';
import 'explore_action_helper.dart';
import 'fight_monster_action_helper.dart';

class _NoEntryAction extends Action {
  @override
  ActionType get type => ActionType.upgradeBuilding;

  @override
  String get description => 'noop';

  @override
  ActionResult validate(Game game, Player player) =>
      const ActionResult.success();

  @override
  ActionResult execute(Game game, Player player) =>
      const ActionResult.success();
}

void main() {
  group('Action.makeHistoryEntry base default', () {
    test('returns null on a subclass that does not override', () {
      final player = Player(id: 'test', name: 'Test');
      final game = Game(
        humanPlayerId: player.id,
        players: {player.id: player},
      );
      final action = _NoEntryAction();
      final result = action.execute(game, player);
      expect(action.makeHistoryEntry(game, player, result, 1), isNull);
    });
  });

  group('UpgradeBuildingAction.makeHistoryEntry', () {
    test('returns BuildingEntry with post-execute level', () {
      final player = Player(
        id: 'test',
        name: 'Test',
        resources: {
          ResourceType.algae: Resource(type: ResourceType.algae, amount: 200),
          ResourceType.coral: Resource(type: ResourceType.coral, amount: 200),
          ResourceType.ore: Resource(type: ResourceType.ore, amount: 200),
          ResourceType.energy: Resource(type: ResourceType.energy, amount: 200),
          ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 20),
        },
        buildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 0),
        },
      );
      final game =
          Game(humanPlayerId: player.id, players: {player.id: player});
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);
      final result = action.execute(game, player);
      expect(result.isSuccess, isTrue);
      final entry = action.makeHistoryEntry(game, player, result, 3);
      expect(entry, isA<BuildingEntry>());
      final building = entry! as BuildingEntry;
      expect(building.turn, 3);
      expect(building.category, HistoryEntryCategory.building);
      expect(building.buildingType, BuildingType.headquarters);
      expect(building.newLevel, 1);
    });
  });

  group('UnlockBranchAction.makeHistoryEntry', () {
    test('returns ResearchEntry with isUnlock true', () {
      final player = Player(
        id: 'test',
        name: 'Test',
        resources: {
          ResourceType.algae: Resource(type: ResourceType.algae, amount: 500),
          ResourceType.coral: Resource(type: ResourceType.coral, amount: 500),
          ResourceType.ore: Resource(type: ResourceType.ore, amount: 500),
          ResourceType.energy: Resource(type: ResourceType.energy, amount: 500),
          ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 50),
        },
        buildings: {
          BuildingType.laboratory:
              Building(type: BuildingType.laboratory, level: 1),
        },
        techBranches: {
          TechBranch.military: TechBranchState(branch: TechBranch.military),
          TechBranch.resources: TechBranchState(branch: TechBranch.resources),
          TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
        },
      );
      final game =
          Game(humanPlayerId: player.id, players: {player.id: player});
      final action = UnlockBranchAction(branch: TechBranch.military);
      final result = action.execute(game, player);
      expect(result.isSuccess, isTrue);
      final entry = action.makeHistoryEntry(game, player, result, 5);
      expect(entry, isA<ResearchEntry>());
      final research = entry! as ResearchEntry;
      expect(research.turn, 5);
      expect(research.category, HistoryEntryCategory.research);
      expect(research.branch, TechBranch.military);
      expect(research.isUnlock, isTrue);
      expect(research.newLevel, isNull);
    });
  });

  group('ResearchTechAction.makeHistoryEntry', () {
    test('returns ResearchEntry with post-execute research level', () {
      final player = Player(
        id: 'test',
        name: 'Test',
        resources: {
          ResourceType.algae: Resource(type: ResourceType.algae, amount: 500),
          ResourceType.coral: Resource(type: ResourceType.coral, amount: 500),
          ResourceType.ore: Resource(type: ResourceType.ore, amount: 500),
          ResourceType.energy: Resource(type: ResourceType.energy, amount: 500),
          ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 50),
        },
        buildings: {
          BuildingType.laboratory:
              Building(type: BuildingType.laboratory, level: 1),
        },
        techBranches: {
          TechBranch.military: TechBranchState(
            branch: TechBranch.military,
            unlocked: true,
          ),
          TechBranch.resources: TechBranchState(branch: TechBranch.resources),
          TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
        },
      );
      final game =
          Game(humanPlayerId: player.id, players: {player.id: player});
      final action = ResearchTechAction(branch: TechBranch.military);
      final result = action.execute(game, player);
      expect(result.isSuccess, isTrue);
      final entry = action.makeHistoryEntry(game, player, result, 7);
      expect(entry, isA<ResearchEntry>());
      final research = entry! as ResearchEntry;
      expect(research.turn, 7);
      expect(research.category, HistoryEntryCategory.research);
      expect(research.branch, TechBranch.military);
      expect(research.isUnlock, isFalse);
      expect(research.newLevel, 1);
    });
  });

  group('RecruitUnitAction.makeHistoryEntry', () {
    test('returns RecruitEntry with unit type and quantity', () {
      final player = Player(
        id: 'test',
        name: 'Test',
        resources: {
          ResourceType.algae: Resource(type: ResourceType.algae, amount: 500),
          ResourceType.coral: Resource(type: ResourceType.coral, amount: 500),
          ResourceType.ore: Resource(type: ResourceType.ore, amount: 500),
          ResourceType.energy: Resource(type: ResourceType.energy, amount: 500),
          ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 50),
        },
        buildings: {
          BuildingType.barracks:
              Building(type: BuildingType.barracks, level: 1),
        },
      );
      final game =
          Game(humanPlayerId: player.id, players: {player.id: player});
      final action =
          RecruitUnitAction(unitType: UnitType.scout, quantity: 4);
      final result = action.execute(game, player);
      expect(result.isSuccess, isTrue);
      final entry = action.makeHistoryEntry(game, player, result, 9);
      expect(entry, isA<RecruitEntry>());
      final recruit = entry! as RecruitEntry;
      expect(recruit.turn, 9);
      expect(recruit.category, HistoryEntryCategory.recruit);
      expect(recruit.unitType, UnitType.scout);
      expect(recruit.quantity, 4);
    });
  });

  group('ExploreAction.makeHistoryEntry', () {
    test('returns ExploreEntry with target coordinates', () {
      final scenario = createExploreScenario();
      final action = ExploreAction(targetX: 4, targetY: 3);
      final result = action.execute(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
      final entry = action.makeHistoryEntry(
        scenario.game,
        scenario.player,
        result,
        11,
      );
      expect(entry, isA<ExploreEntry>());
      final explore = entry! as ExploreEntry;
      expect(explore.turn, 11);
      expect(explore.category, HistoryEntryCategory.explore);
      expect(explore.targetX, 4);
      expect(explore.targetY, 3);
    });
  });

  group('CollectTreasureAction.makeHistoryEntry', () {
    test('returns CollectEntry with gains from result', () {
      final scenario = createCollectScenario(
        content: CellContentType.resourceBonus,
      );
      final action = CollectTreasureAction(
        targetX: 1,
        targetY: 1,
        random: Random(0),
      );
      final result = action.execute(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
      final entry = action.makeHistoryEntry(
        scenario.game,
        scenario.player,
        result,
        13,
      );
      expect(entry, isA<CollectEntry>());
      final collect = entry! as CollectEntry;
      expect(collect.turn, 13);
      expect(collect.category, HistoryEntryCategory.collect);
      expect(collect.targetX, 1);
      expect(collect.targetY, 1);
      expect(collect.gains, isNotEmpty);
      expect(collect.gains.keys, contains(ResourceType.algae));
    });
  });

  group('FightMonsterAction.makeHistoryEntry', () {
    test('returns CombatEntry mirroring the FightMonsterResult', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.easy,
        unitCount: 1,
        stock: {UnitType.harpoonist: 20},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 1,
        selectedUnits: {UnitType.harpoonist: 20},
        random: Random(0),
      );
      final result = action.execute(scenario.game, scenario.player);
      expect(result, isA<FightMonsterResult>());
      final fight = result as FightMonsterResult;
      expect(fight.isSuccess, isTrue);

      final entry = action.makeHistoryEntry(
        scenario.game,
        scenario.player,
        result,
        17,
      );
      expect(entry, isA<CombatEntry>());
      final combat = entry! as CombatEntry;
      expect(combat.turn, 17);
      expect(combat.category, HistoryEntryCategory.combat);
      expect(combat.victory, fight.victory);
      expect(combat.targetX, 1);
      expect(combat.targetY, 1);
      expect(combat.lair.difficulty, MonsterDifficulty.easy);
      expect(combat.lair.unitCount, 1);
      expect(identical(combat.fightResult, fight.fight), isTrue);
      expect(combat.loot, fight.loot);
      expect(combat.sent, fight.sent);
      expect(combat.survivorsIntact, fight.survivorsIntact);
      expect(combat.wounded, fight.wounded);
      expect(combat.dead, fight.dead);
    });

    test('returns null when fight has not been executed', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.easy,
        unitCount: 1,
        stock: {UnitType.harpoonist: 20},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 1,
        selectedUnits: {UnitType.harpoonist: 20},
        random: Random(0),
      );
      // No execute: captured lair is still null, and the result we fabricate
      // is a failure. Expect null.
      const result = FightMonsterResult.failure('not run');
      final entry = action.makeHistoryEntry(
        scenario.game,
        scenario.player,
        result,
        1,
      );
      expect(entry, isNull);
    });
  });
}
