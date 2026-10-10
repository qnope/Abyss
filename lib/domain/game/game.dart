import 'package:hive_ce/hive.dart';

import '../faction/faction.dart';
import '../faction/faction_personality.dart';
import '../map/cell_content_type.dart';
import '../map/game_map.dart';
import '../map/transition_base_type.dart';
import '../replay/replay_journal.dart';
import 'difficulty.dart';
import 'game_status.dart';
import 'player.dart';

part 'game.g.dart';

@HiveType(typeId: 1)
class Game extends HiveObject {
  @HiveField(0)
  final Map<String, Player> players;

  @HiveField(1)
  final String humanPlayerId;

  @HiveField(2)
  int turn;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  Map<int, GameMap> levels;

  @HiveField(5)
  GameStatus status;

  /// Every move played so far, to export the game as a replay; `null` for
  /// games saved before the journal existed.
  @HiveField(6)
  ReplayJournal? replay;

  /// Picked when the game started; `null` for games saved before the
  /// difficulty existed, which play in normal.
  @HiveField(7)
  Difficulty? savedDifficulty;

  /// Stamped by the repository on every save; `null` for games saved before
  /// the stamp existed, which were last played when they were created.
  @HiveField(8)
  DateTime? savedLastPlayedAt;

  /// Personalities of the factions, in the order they play; `null` for
  /// games saved before the factions, and for single-player games.
  @HiveField(9)
  List<FactionPersonality>? savedFactions;

  Game({
    required this.humanPlayerId,
    required this.players,
    this.turn = 1,
    DateTime? createdAt,
    this.levels = const {},
    this.status = GameStatus.playing,
    this.replay,
    Difficulty difficulty = Difficulty.normal,
    DateTime? lastPlayedAt,
  }) : savedDifficulty = difficulty,
       savedLastPlayedAt = lastPlayedAt,
       createdAt = createdAt ?? DateTime.now();

  factory Game.singlePlayer(
    Player human, {
    Difficulty difficulty = Difficulty.normal,
  }) => Game(
        humanPlayerId: human.id,
        players: {human.id: human},
        difficulty: difficulty,
      );

  /// The factions of the game, in the order they play; each one is the
  /// player of the same [Faction.id].
  List<Faction> get factions => [
    for (final FactionPersonality p in savedFactions ?? const [])
      Faction(p),
  ];

  Difficulty get difficulty => savedDifficulty ?? Difficulty.normal;

  DateTime get lastPlayedAt => savedLastPlayedAt ?? createdAt;

  Player get humanPlayer => players[humanPlayerId]!;

  GameMap? mapForLevel(int level) => levels[level];

  GameMap get currentMap => levels[1]!;

  Set<TransitionBaseType> capturedBaseTypesOf(String playerId) {
    final types = <TransitionBaseType>{};
    for (final map in levels.values) {
      for (final cell in map.cells) {
        if (cell.transitionBase?.capturedBy == playerId) {
          types.add(cell.transitionBase!.type);
        }
      }
    }
    return types;
  }

  bool isVolcanicKernelCapturedBy(String playerId) {
    final map = levels[3];
    if (map == null) return false;
    for (final cell in map.cells) {
      if (cell.content == CellContentType.volcanicKernel &&
          cell.collectedBy == playerId) {
        return true;
      }
    }
    return false;
  }
}
