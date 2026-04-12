import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_statistics_calculator.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

const _calculator = GameStatisticsCalculator();

FightResult _result({required CombatSide winner, required int monsters}) {
  return FightResult(
    winner: winner,
    turnCount: 1,
    turnSummaries: const [],
    initialPlayerCombatants: const [],
    finalPlayerCombatants: const [],
    initialMonsterCount: monsters,
    finalMonsterCount: 0,
  );
}

CombatEntry _combat({
  required bool victory,
  required int monsters,
}) {
  return CombatEntry(
    turn: 1,
    victory: victory,
    targetX: 0,
    targetY: 0,
    lair: const MonsterLair(
      difficulty: MonsterDifficulty.easy,
      unitCount: 3,
    ),
    fightResult: _result(
      winner: victory ? CombatSide.player : CombatSide.monster,
      monsters: monsters,
    ),
    loot: const {},
    sent: const {},
    survivorsIntact: const {},
    wounded: const {},
    dead: const {},
  );
}

Game _gameWith({
  int turn = 1,
  List<HistoryEntry> history = const [],
}) {
  final player = Player(
    id: 'p1',
    name: 'Test',
    baseX: 0,
    baseY: 0,
    historyEntries: history,
  );
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    turn: turn,
  );
}

void main() {
  group('GameStatisticsCalculator', () {
    test('empty history returns zeroes and turnsPlayed', () {
      final game = _gameWith(turn: 7);
      final stats = _calculator.compute(game);

      expect(stats.turnsPlayed, 7);
      expect(stats.monstersDefeated, 0);
      expect(stats.basesCaptured, 0);
    });

    test('combat victories count initial monsters', () {
      final game = _gameWith(
        history: [
          _combat(victory: true, monsters: 5),
          _combat(victory: true, monsters: 3),
        ],
      );
      final stats = _calculator.compute(game);
      expect(stats.monstersDefeated, 8);
    });

    test('combat defeats do not count monsters', () {
      final game = _gameWith(
        history: [
          _combat(victory: false, monsters: 4),
        ],
      );
      final stats = _calculator.compute(game);
      expect(stats.monstersDefeated, 0);
    });

    test('capture entries are counted', () {
      final game = _gameWith(
        history: [
          CaptureEntry(
            turn: 1,
            transitionBaseName: 'Base A',
            fightResult: _result(
              winner: CombatSide.player,
              monsters: 2,
            ),
          ),
          CaptureEntry(
            turn: 2,
            transitionBaseName: 'Base B',
            fightResult: _result(
              winner: CombatSide.player,
              monsters: 1,
            ),
          ),
        ],
      );
      final stats = _calculator.compute(game);
      expect(stats.basesCaptured, 2);
    });

    test('collect entries sum resources', () {
      final game = _gameWith(
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
      final stats = _calculator.compute(game);
      // 10 + 5 + 20 from history + current resources from defaults
      final defaultSum =
          game.humanPlayer.resources.values.fold(0, (s, r) => s + r.amount);
      expect(stats.totalResourcesCollected, 35 + defaultSum);
    });

    test('mixed history computes all fields', () {
      final game = _gameWith(
        turn: 12,
        history: [
          _combat(victory: true, monsters: 3),
          _combat(victory: false, monsters: 2),
          CaptureEntry(
            turn: 5,
            transitionBaseName: 'X',
            fightResult: _result(
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
      final stats = _calculator.compute(game);
      expect(stats.turnsPlayed, 12);
      expect(stats.monstersDefeated, 3);
      expect(stats.basesCaptured, 1);
      final defaultSum =
          game.humanPlayer.resources.values.fold(0, (s, r) => s + r.amount);
      expect(stats.totalResourcesCollected, 7 + defaultSum);
    });
  });
}
