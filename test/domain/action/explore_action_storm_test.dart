import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/event/effects/storm_effect.dart';
import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'explore_action_helper.dart';

void main() {
  test(
    'a storm drawn at the end of turn 12 forbids exploring on 13 and 14',
    () {
      final scenario = createExploreScenario();
      final game = scenario.game..turn = 12;
      final player = scenario.player..eventState.schedule(100);
      const StormEffect().apply(
        game,
        player,
        accept: true,
        turn: game.turn + 1,
      );

      final reasons = <ActionFailure?>[];
      for (var turn = 13; turn <= 15; turn++) {
        game.turn = turn;
        reasons.add(
          ExploreAction(targetX: 2, targetY: 2).validate(game, player).reason,
        );
        EventResolver.resolve(game, player, turn);
      }

      expect(reasons, [
        ActionFailure.stormBlocksExploration,
        ActionFailure.stormBlocksExploration,
        null,
      ]);
    },
  );

  test('an exploration ordered before the storm still resolves', () {
    final scenario = createExploreScenario();
    final game = scenario.game..turn = 12;
    final player = scenario.player;
    ExploreAction(targetX: 2, targetY: 1).execute(game, player);
    const StormEffect().apply(game, player, accept: true, turn: 13);

    final results = ExplorationResolver.resolve(game);

    expect(results, hasLength(1));
    expect(player.pendingExplorations, isEmpty);
  });
}
