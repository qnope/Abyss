import '../history/history_entry.dart';
import 'game.dart';
import 'game_status.dart';
import 'game_statistics.dart';
import 'player.dart';

class GameStatisticsCalculator {
  const GameStatisticsCalculator();

  GameStatistics compute(Game game, {Player? player}) {
    final who = player ?? game.humanPlayer;
    final entries = who.historyEntries;

    var monstersDefeated = 0;
    var basesCaptured = 0;
    var collectedResources = 0;

    for (final entry in entries) {
      switch (entry) {
        case CombatEntry(:final fightResult) when fightResult.isVictory:
          monstersDefeated += fightResult.initialMonsterCount;
        case CaptureEntry():
          basesCaptured++;
        case CollectEntry(:final gains):
          collectedResources += gains.values.fold(0, (a, b) => a + b);
        default:
          break;
      }
    }

    final currentResources = who.resources.values
        .fold(0, (sum, r) => sum + r.amount);

    return GameStatistics(
      // A lost game already moved past the turn the base fell on.
      turnsPlayed:
          game.status == GameStatus.defeat ? game.turn - 1 : game.turn,
      monstersDefeated: monstersDefeated,
      basesCaptured: basesCaptured,
      totalResourcesCollected: collectedResources + currentResources,
      raidsRepelled: game.humanPlayer.raidState.raidsRepelled,
      raidsLost: game.humanPlayer.raidState.raidsLost,
    );
  }
}
