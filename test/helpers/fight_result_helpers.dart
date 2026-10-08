import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';

/// Minimal one-turn [FightResult] won by the player when [victory] is true
/// and by the monsters otherwise.
FightResult oneTurnFightResult({required bool victory}) {
  final combatant = Combatant(
    side: CombatSide.player,
    typeKey: 'scout',
    maxHp: 10,
    atk: 3,
    def: 1,
  );
  return FightResult(
    winner: victory ? CombatSide.player : CombatSide.monster,
    turnCount: 1,
    turnSummaries: const [
      FightTurnSummary(
        turnNumber: 1,
        attacksPlayed: 2,
        critCount: 0,
        damageDealtByPlayer: 5,
        damageDealtByMonster: 3,
        playerAliveAtEnd: 1,
        monsterAliveAtEnd: 0,
        playerHpAtEnd: 7,
        monsterHpAtEnd: 0,
      ),
    ],
    initialPlayerCombatants: [combatant],
    finalPlayerCombatants: [combatant],
    initialMonsterCount: 1,
    finalMonsterCount: 0,
  );
}
