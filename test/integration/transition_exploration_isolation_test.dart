import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

import 'transition_test_helper.dart';

void main() {
  group('Exploration highlight isolation across levels', () {
    test('pending explorations are filtered by level', () {
      final player = buildRichPlayer();
      player.pendingExplorations.addAll([
        ExplorationOrder(
          target: GridPosition(x: 1, y: 2),
          level: 1,
        ),
        ExplorationOrder(
          target: GridPosition(x: 3, y: 4),
          level: 1,
        ),
        ExplorationOrder(
          target: GridPosition(x: 5, y: 6),
          level: 2,
        ),
      ]);

      final level1Targets = _pendingTargetsOnLevel(player, 1);
      final level2Targets = _pendingTargetsOnLevel(player, 2);

      expect(level1Targets, {(1, 2), (3, 4)});
      expect(level2Targets, {(5, 6)});
    });

    test('level with no explorations has empty pending targets', () {
      final player = buildRichPlayer();
      player.pendingExplorations.add(
        ExplorationOrder(
          target: GridPosition(x: 0, y: 0),
          level: 1,
        ),
      );

      final level3Targets = _pendingTargetsOnLevel(player, 3);

      expect(level3Targets, isEmpty);
    });
  });
}

Set<(int, int)> _pendingTargetsOnLevel(Player player, int level) {
  return player.pendingExplorations
      .where((e) => e.level == level)
      .map((e) => (e.target.x, e.target.y))
      .toSet();
}
