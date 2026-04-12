import '../history/history_entry.dart';
import 'game.dart';
import 'game_statistics.dart';

class GameStatisticsCalculator {
  const GameStatisticsCalculator();

  GameStatistics compute(Game game) {
    final entries = game.humanPlayer.historyEntries;

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

    final currentResources = game.humanPlayer.resources.values
        .fold(0, (sum, r) => sum + r.amount);

    return GameStatistics(
      turnsPlayed: game.turn,
      monstersDefeated: monstersDefeated,
      basesCaptured: basesCaptured,
      totalResourcesCollected: collectedResources + currentResources,
    );
  }
}
