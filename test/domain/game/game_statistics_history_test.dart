import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'game_statistics_helper.dart';

void main() {
  group('GameStatisticsCalculator history', () {
    test('capture entries are counted', () {
      final game = gameWith(
        history: [
          CaptureEntry(
            turn: 1,
            transitionBaseName: 'Base A',
            fightResult: fightOf(
              winner: CombatSide.player,
              monsters: 2,
            ),
          ),
          CaptureEntry(
            turn: 2,
            transitionBaseName: 'Base B',
            fightResult: fightOf(
              winner: CombatSide.player,
              monsters: 1,
            ),
          ),
        ],
      );
      final stats = statsCalculator.compute(game);
      expect(stats.basesCaptured, 2);
    });

    test('a victory where the admiral fell captures nothing', () {
      final game = gameWith(
        history: [
          CaptureEntry(
            turn: 1,
            transitionBaseName: 'Base A',
            fightResult: fightOf(winner: CombatSide.player, monsters: 2),
            captured: false,
          ),
        ],
      );
      expect(statsCalculator.compute(game).basesCaptured, 0);
    });

    test('collect entries sum resources', () {
      final game = gameWith(
        history: [
          CollectEntry(
            turn: 1,
            targetX: 0,
            targetY: 0,
            gains: const {ResourceType.algae: 10, ResourceType.coral: 5},
          ),
          CollectEntry(
            turn: 2,
            targetX: 1,
            targetY: 1,
            gains: const {ResourceType.ore: 20},
          ),
        ],
      );
      final stats = statsCalculator.compute(game);
      // 10 + 5 + 20 from history + current resources from defaults
      final defaultSum =
          game.humanPlayer.resources.values.fold(0, (s, r) => s + r.amount);
      expect(stats.totalResourcesCollected, 35 + defaultSum);
    });

    test('mixed history computes all fields', () {
      final game = gameWith(
        turn: 12,
        history: [
          combatOf(victory: true, monsters: 3),
          combatOf(victory: false, monsters: 2),
          CaptureEntry(
            turn: 5,
            transitionBaseName: 'X',
            fightResult: fightOf(
              winner: CombatSide.player,
              monsters: 1,
            ),
          ),
          CollectEntry(
            turn: 6,
            targetX: 0,
            targetY: 0,
            gains: const {ResourceType.energy: 7},
          ),
        ],
      );
      final stats = statsCalculator.compute(game);
      expect(stats.turnsPlayed, 12);
      expect(stats.monstersDefeated, 3);
      expect(stats.basesCaptured, 1);
      final defaultSum =
          game.humanPlayer.resources.values.fold(0, (s, r) => s + r.amount);
      expect(stats.totalResourcesCollected, 7 + defaultSum);
    });
  });
}
