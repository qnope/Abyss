import 'package:hive/hive.dart';

import '../map/game_map.dart';
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
  GameMap? gameMap;

  Game({
    required this.humanPlayerId,
    required this.players,
    this.turn = 1,
    DateTime? createdAt,
    this.gameMap,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Game.singlePlayer(Player human) => Game(
        humanPlayerId: human.id,
        players: {human.id: human},
      );

  Player get humanPlayer => players[humanPlayerId]!;
}
