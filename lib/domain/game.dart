import 'package:hive/hive.dart';
import 'player.dart';

part 'game.g.dart';

@HiveType(typeId: 1)
class Game extends HiveObject {
  @HiveField(0)
  final Player player;

  @HiveField(1)
  final int turn;

  @HiveField(2)
  final DateTime createdAt;

  Game({
    required this.player,
    this.turn = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
