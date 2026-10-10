import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import 'faction_personality.dart';

/// What the human knows of a player in the ranking: only public facts,
/// the headquarters level and how deep the player holds a post.
class FactionStanding {
  final String name;

  /// `null` for the human player.
  final FactionPersonality? personality;
  final int headquartersLevel;

  /// Deepest level where the player holds a post (1 when none).
  final int deepestLevel;
  final bool holdsKernel;
  final bool hasFallen;

  const FactionStanding({
    required this.name,
    this.personality,
    required this.headquartersLevel,
    required this.deepestLevel,
    required this.holdsKernel,
    required this.hasFallen,
  });

  bool get isHuman => personality == null;

  factory FactionStanding.of(Game game, Player player) {
    final holdsKernel = game.isVolcanicKernelCapturedBy(player.id);
    var deepest = holdsKernel ? 3 : 1;
    for (final map in game.levels.values) {
      for (final cell in map.cells) {
        final base = cell.transitionBase;
        if (base?.capturedBy == player.id && base!.targetLevel > deepest) {
          deepest = base.targetLevel;
        }
      }
    }
    return FactionStanding(
      name: player.name,
      personality: [
        for (final f in game.factions)
          if (f.id == player.id) f.personality,
      ].firstOrNull,
      headquartersLevel: player.buildings[BuildingType.headquarters]!.level,
      deepestLevel: deepest,
      holdsKernel: holdsKernel,
      hasFallen: player.hasFallen,
    );
  }

  /// The human and the factions, the most advanced first (kernel, depth,
  /// headquarters); the fallen last. Empty in a game without factions.
  static List<FactionStanding> ranking(Game game) {
    if (game.factions.isEmpty) return const [];
    final standings = [
      FactionStanding.of(game, game.humanPlayer),
      for (final faction in game.factions)
        if (game.players[faction.id] != null)
          FactionStanding.of(game, game.players[faction.id]!),
    ];
    int score(FactionStanding s) =>
        (s.hasFallen ? 0 : 1000) +
        (s.holdsKernel ? 100 : 0) +
        s.deepestLevel * 20 +
        s.headquartersLevel;
    // Stable: equal scores keep the playing order, the human first.
    final indexed = standings.asMap().entries.toList()
      ..sort((a, b) {
        final byScore = score(b.value).compareTo(score(a.value));
        return byScore != 0 ? byScore : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }
}
