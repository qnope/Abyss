class GameStatistics {
  final int turnsPlayed;
  final int monstersDefeated;
  final int basesCaptured;
  final int totalResourcesCollected;
  final int raidsRepelled;
  final int raidsLost;

  const GameStatistics({
    required this.turnsPlayed,
    required this.monstersDefeated,
    required this.basesCaptured,
    required this.totalResourcesCollected,
    this.raidsRepelled = 0,
    this.raidsLost = 0,
  });
}
