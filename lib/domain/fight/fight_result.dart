import 'combat_side.dart';
import 'combatant.dart';
import 'fight_turn_summary.dart';

class FightResult {
  final CombatSide winner;
  final int turnCount;
  final List<FightTurnSummary> turnSummaries;
  final List<Combatant> initialPlayerCombatants;
  final List<Combatant> finalPlayerCombatants;
  final int initialMonsterCount;
  final int finalMonsterCount;

  const FightResult(
    this.winner,
    this.turnCount,
    this.turnSummaries,
    this.initialPlayerCombatants,
    this.finalPlayerCombatants,
    this.initialMonsterCount,
    this.finalMonsterCount,
  );

  bool get isVictory => winner == CombatSide.player;
}
