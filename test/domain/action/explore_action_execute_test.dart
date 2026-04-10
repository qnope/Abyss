import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'explore_action_helper.dart';

void main() {
  group('ExploreAction execute', () {
    test('consumes 1 scout', () {
      final scenario = createExploreScenario(scoutCount: 3);
      final action = ExploreAction(targetX: 2, targetY: 2);
      final result = action.execute(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
      expect(scenario.player.unitsOnLevel(1)[UnitType.scout]!.count, 2);
    });

    test('adds exploration order with correct target', () {
      final scenario = createExploreScenario();
      final action = ExploreAction(targetX: 4, targetY: 3);
      action.execute(scenario.game, scenario.player);
      expect(scenario.player.pendingExplorations, hasLength(1));
      final order = scenario.player.pendingExplorations.first;
      expect(order.target.x, 4);
      expect(order.target.y, 3);
    });

    test('multiple executions consume scouts and add orders', () {
      final scenario = createExploreScenario(scoutCount: 3);
      ExploreAction(targetX: 2, targetY: 2)
          .execute(scenario.game, scenario.player);
      ExploreAction(targetX: 4, targetY: 4)
          .execute(scenario.game, scenario.player);
      expect(scenario.player.unitsOnLevel(1)[UnitType.scout]!.count, 1);
      expect(scenario.player.pendingExplorations, hasLength(2));
      expect(scenario.player.pendingExplorations[0].target.x, 2);
      expect(scenario.player.pendingExplorations[0].target.y, 2);
      expect(scenario.player.pendingExplorations[1].target.x, 4);
      expect(scenario.player.pendingExplorations[1].target.y, 4);
    });
  });
}
