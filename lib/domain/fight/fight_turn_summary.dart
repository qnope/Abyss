import 'package:hive/hive.dart';

part 'fight_turn_summary.g.dart';

@HiveType(typeId: 28)
class FightTurnSummary {
  @HiveField(0)
  final int turnNumber;

  @HiveField(1)
  final int attacksPlayed;

  @HiveField(2)
  final int critCount;

  @HiveField(3)
  final int damageDealtByPlayer;

  @HiveField(4)
  final int damageDealtByMonster;

  @HiveField(5)
  final int playerAliveAtEnd;

  @HiveField(6)
  final int monsterAliveAtEnd;

  @HiveField(7)
  final int playerHpAtEnd;

  @HiveField(8)
  final int monsterHpAtEnd;

  const FightTurnSummary({
    required this.turnNumber,
    required this.attacksPlayed,
    required this.critCount,
    required this.damageDealtByPlayer,
    required this.damageDealtByMonster,
    required this.playerAliveAtEnd,
    required this.monsterAliveAtEnd,
    required this.playerHpAtEnd,
    required this.monsterHpAtEnd,
  });
}
