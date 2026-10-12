import 'package:abyss/domain/game/game_status.dart';
import 'package:flutter_test/flutter_test.dart';

import 'game_statistics_helper.dart';

void main() {
  group('GameStatisticsCalculator', () {
    test('empty history returns zeroes and turnsPlayed', () {
      final game = gameWith(turn: 7);
      final stats = statsCalculator.compute(game);

      expect(stats.turnsPlayed, 7);
      expect(stats.monstersDefeated, 0);
      expect(stats.basesCaptured, 0);
    });

    test('a lost game counts the turn the base fell on as the last', () {
      final game = gameWith(turn: 28)..status = GameStatus.defeat;
      expect(statsCalculator.compute(game).turnsPlayed, 27);
    });

    test('raid outcomes come from the raid state', () {
      final game = gameWith();
      game.humanPlayer.raidState
        ..recordOutcome(victory: true)
        ..recordOutcome(victory: false)
        ..recordOutcome(victory: false);
      final stats = statsCalculator.compute(game);
      expect(stats.raidsRepelled, 1);
      expect(stats.raidsLost, 2);
    });

    test('combat victories count initial monsters', () {
      final game = gameWith(
        history: [
          combatOf(victory: true, monsters: 5),
          combatOf(victory: true, monsters: 3),
        ],
      );
      final stats = statsCalculator.compute(game);
      expect(stats.monstersDefeated, 8);
    });

    test('combat defeats do not count monsters', () {
      final game = gameWith(
        history: [
          combatOf(victory: false, monsters: 4),
        ],
      );
      final stats = statsCalculator.compute(game);
      expect(stats.monstersDefeated, 0);
    });
  });
}
