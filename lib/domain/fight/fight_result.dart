import 'package:hive/hive.dart';
import 'combat_side.dart';
import 'combatant.dart';
import 'fight_turn_summary.dart';

part 'fight_result.g.dart';

@HiveType(typeId: 29)
class FightResult {
  @HiveField(0)
  final CombatSide winner;

  @HiveField(1)
  final int turnCount;

  @HiveField(2)
  final List<FightTurnSummary> turnSummaries;

  @HiveField(3)
  final List<Combatant> initialPlayerCombatants;

  @HiveField(4)
  final List<Combatant> finalPlayerCombatants;

  @HiveField(5)
  final int initialMonsterCount;

  @HiveField(6)
  final int finalMonsterCount;

  const FightResult({
    required this.winner,
    required this.turnCount,
    required this.turnSummaries,
    required this.initialPlayerCombatants,
    required this.finalPlayerCombatants,
    required this.initialMonsterCount,
    required this.finalMonsterCount,
  });

  bool get isVictory => winner == CombatSide.player;
}
