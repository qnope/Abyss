import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_statistics_calculator.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';

// What the tests of the GameStatisticsCalculator share.

const statsCalculator = GameStatisticsCalculator();

FightResult fightOf({required CombatSide winner, required int monsters}) {
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

CombatEntry combatOf({
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
    fightResult: fightOf(
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

Game gameWith({
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
