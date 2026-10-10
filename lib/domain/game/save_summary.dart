import '../building/building_type.dart';
import '../resource/resource_type.dart';
import 'difficulty.dart';
import 'game.dart';
import 'game_status.dart';
import 'save_outcome.dart';

/// What a save card tells about a game without opening it.
class SaveSummary {
  final String playerName;

  /// The turn being played, or the turn the base fell on for a lost game.
  final int turn;
  final Difficulty difficulty;
  final SaveOutcome outcome;

  /// The deepest map generated: 1 surface, 2 depths, 3 core.
  final int deepestLevel;
  final int headquartersLevel;

  /// Every resource amount, in [ResourceType] order.
  final Map<ResourceType, int> resources;
  final DateTime lastPlayedAt;

  const SaveSummary({
    required this.playerName,
    required this.turn,
    required this.difficulty,
    required this.outcome,
    required this.deepestLevel,
    required this.headquartersLevel,
    required this.resources,
    required this.lastPlayedAt,
  });

  factory SaveSummary.of(Game game) {
    final player = game.humanPlayer;
    return SaveSummary(
      playerName: player.name,
      // A lost game already moved past the turn the base fell on.
      turn: game.status == GameStatus.defeat ? game.turn - 1 : game.turn,
      difficulty: game.difficulty,
      outcome: SaveOutcome.of(game.status),
      deepestLevel: game.levels.keys.fold(1, (a, b) => a > b ? a : b),
      headquartersLevel:
          player.buildings[BuildingType.headquarters]?.level ?? 0,
      resources: Map.unmodifiable({
        for (final type in ResourceType.values)
          type: player.resources[type]?.amount ?? 0,
      }),
      lastPlayedAt: game.lastPlayedAt,
    );
  }
}
