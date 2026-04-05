import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'explore_action_helper.dart';

void main() {
  group('ExploreAction execute', () {
    test('consumes 1 scout', () {
      final game = createExploreGame(scoutCount: 3);
      final action = ExploreAction(targetX: 2, targetY: 2);
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      expect(game.units[UnitType.scout]!.count, 2);
    });

    test('adds exploration order with correct target', () {
      final game = createExploreGame();
      final action = ExploreAction(targetX: 4, targetY: 3);
      action.execute(game);
      expect(game.pendingExplorations, hasLength(1));
      final order = game.pendingExplorations.first;
      expect(order.target.x, 4);
      expect(order.target.y, 3);
    });

    test('multiple executions consume scouts and add orders', () {
      final game = createExploreGame(scoutCount: 3);
      ExploreAction(targetX: 2, targetY: 2).execute(game);
      ExploreAction(targetX: 4, targetY: 4).execute(game);
      expect(game.units[UnitType.scout]!.count, 1);
      expect(game.pendingExplorations, hasLength(2));
      expect(game.pendingExplorations[0].target.x, 2);
      expect(game.pendingExplorations[0].target.y, 2);
      expect(game.pendingExplorations[1].target.x, 4);
      expect(game.pendingExplorations[1].target.y, 4);
    });
  });
}
