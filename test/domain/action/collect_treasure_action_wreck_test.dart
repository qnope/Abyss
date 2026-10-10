import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/collect_treasure_result.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/event/effects/wreck_effect.dart';
import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';
import '../event/effects/wreck_test_helper.dart';
import 'collect_treasure_action_helper.dart';

/// Sinks a wreck at the end of turn 12 and lets the player see it.
GridPosition _sinkInSight(Game game, Player player) {
  const WreckEffect().onDraw(game, player, turn: 12, random: Random(4));
  final at = player.eventState.wreckPosition!;
  player.addRevealedCell(1, at);
  return at;
}

CollectTreasureResult _collect(Game game, Player player, GridPosition at) =>
    ActionExecutor().execute(
          CollectTreasureAction(targetX: at.x, targetY: at.y),
          game,
          player,
        )
        as CollectTreasureResult;

void main() {
  test('a scout explores the wreck, then searching it gives its loot', () {
    final player = wreckPlayer();
    final game = wreckGame(player, turn: 13);
    const WreckEffect().onDraw(game, player, turn: 12, random: Random(4));
    final at = player.eventState.wreckPosition!;
    final executor = ActionExecutor();
    final explore = ExploreAction(targetX: at.x, targetY: at.y);
    expect(executor.execute(explore, game, player).isSuccess, isTrue);
    ExplorationResolver.resolve(game);
    final noise = player.raidState.noise;

    final result = _collect(game, player, at);

    expect(result.isSuccess, isTrue);
    expect(result.deltas, {
      ResourceType.coral: EventRules.wreckCoral,
      ResourceType.ore: EventRules.wreckOre,
      ResourceType.pearl: EventRules.wreckPearls,
    });
    expect(player.raidState.noise, noise + EventRules.wreckNoise);
    expect(game.currentMap.cellAt(at.x, at.y).collectedBy, player.id);
    expect(player.eventState.wreckPosition, isNull);
    // Kept until the end of the turn, to tell the search from a sinking.
    expect(player.eventState.wreckSearched, isTrue);
    expect(player.eventState.wreckUntilTurn, 12 + EventRules.wreckTurns);
    final entry = player.historyEntries.whereType<CollectEntry>().single;
    expect(entry.gains, result.deltas);
  });

  test("the wreck raiders' bonus lifts the loot of a wreck", () {
    final player = wreckPlayer()
      ..techBranches.addAll(
        techBranchesWith([
          researchedBranch(
            TechBranch.explorer,
            4,
            options: [TechOption.a, TechOption.a],
          ),
        ]),
      );
    final game = wreckGame(player, turn: 13);
    final result = _collect(game, player, _sinkInSight(game, player));
    expect(result.deltas[ResourceType.coral], EventRules.wreckCoral * 3 ~/ 2);
    expect(result.deltas[ResourceType.ore], EventRules.wreckOre * 3 ~/ 2);
    expect(result.deltas[ResourceType.pearl], EventRules.wreckPearls * 3 ~/ 2);
  });

  test('the loot of a wreck stops at the storage cap', () {
    final player = wreckPlayer();
    final coral = player.resources[ResourceType.coral]!;
    coral.amount = coral.maxStorage - 10;
    final game = wreckGame(player, turn: 13);
    final result = _collect(game, player, _sinkInSight(game, player));
    expect(result.deltas[ResourceType.coral], 10);
    expect(coral.amount, coral.maxStorage);
  });

  test('searching ruins still makes no noise', () {
    final scenario = createCollectScenario(content: CellContentType.ruins);
    final collect = CollectTreasureAction(targetX: 1, targetY: 1);
    ActionExecutor().execute(collect, scenario.game, scenario.player);
    expect(scenario.player.raidState.noise, 0);
  });

  test('a wreck can be searched through the end of turn 17, not after', () {
    final player = wreckPlayer();
    final game = wreckGame(player, turn: 17);
    final at = _sinkInSight(game, player);
    EventResolver.resolve(game, player, 16, random: Random(1));
    expect(_collect(game, player, at).isSuccess, isTrue);

    final late = wreckPlayer();
    final lateGame = wreckGame(late, turn: 17);
    final lost = _sinkInSight(lateGame, late);
    EventResolver.resolve(lateGame, late, 17, random: Random(1));
    lateGame.turn = 18;
    final result = _collect(lateGame, late, lost);
    expect(result.isSuccess, isFalse);
    expect(result.reason, 'Rien à collecter');
  });

  test('a searched wreck stays searched once its time is over', () {
    final player = wreckPlayer();
    final game = wreckGame(player, turn: 14);
    final at = _sinkInSight(game, player);
    _collect(game, player, at);
    EventResolver.resolve(game, player, 17, random: Random(1));
    final cell = game.currentMap.cellAt(at.x, at.y);
    expect(cell.content, CellContentType.wreck);
    expect(cell.collectedBy, player.id);
  });
}
