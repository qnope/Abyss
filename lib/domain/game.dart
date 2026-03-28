import 'player.dart';

class Game {
  final Player player;
  final int turn;
  final DateTime createdAt;

  Game({
    required this.player,
    this.turn = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
