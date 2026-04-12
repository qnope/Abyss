import 'package:hive/hive.dart';

import '../map/game_map.dart';
import '../map/transition_base_type.dart';
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

  Game({
    required this.humanPlayerId,
    required this.players,
    this.turn = 1,
    DateTime? createdAt,
    this.levels = const {},
    this.status = GameStatus.playing,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Game.singlePlayer(Player human) => Game(
        humanPlayerId: human.id,
        players: {human.id: human},
      );

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
}
