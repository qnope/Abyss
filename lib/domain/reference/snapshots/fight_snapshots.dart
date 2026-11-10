import '../../fight/combatant.dart';
import '../../fight/fight_result.dart';
import '../../fight/fight_turn_summary.dart';
import '../class_snapshot.dart';

/// Snapshots of a fight as the history keeps it.
abstract final class FightSnapshots {
  static final ClassSnapshot<Combatant> combatant =
      ClassSnapshot<Combatant>('Combatant', {
        'side': (c, _) => c.side.name,
        'typeKey': (c, _) => c.typeKey,
        'maxHp': (c, _) => c.maxHp,
        'atk': (c, _) => c.atk,
        'def': (c, _) => c.def,
        'currentHp': (c, _) => c.currentHp,
        'isBoss': (c, _) => c.isBoss,
      });

  static final ClassSnapshot<FightTurnSummary> turn =
      ClassSnapshot<FightTurnSummary>('FightTurnSummary', {
        'turnNumber': (t, _) => t.turnNumber,
        'attacksPlayed': (t, _) => t.attacksPlayed,
        'critCount': (t, _) => t.critCount,
        'damageDealtByPlayer': (t, _) => t.damageDealtByPlayer,
        'damageDealtByMonster': (t, _) => t.damageDealtByMonster,
        'playerAliveAtEnd': (t, _) => t.playerAliveAtEnd,
        'monsterAliveAtEnd': (t, _) => t.monsterAliveAtEnd,
        'playerHpAtEnd': (t, _) => t.playerHpAtEnd,
        'monsterHpAtEnd': (t, _) => t.monsterHpAtEnd,
      });

  static final ClassSnapshot<FightResult> result =
      ClassSnapshot<FightResult>('FightResult', {
        'winner': (f, _) => f.winner.name,
        'turnCount': (f, _) => f.turnCount,
        'turnSummaries': (f, ids) => turn.listOf(f.turnSummaries, ids),
        'initialPlayerCombatants':
            (f, ids) => combatant.listOf(f.initialPlayerCombatants, ids),
        'finalPlayerCombatants':
            (f, ids) => combatant.listOf(f.finalPlayerCombatants, ids),
        'initialMonsterCount': (f, _) => f.initialMonsterCount,
        'finalMonsterCount': (f, _) => f.finalMonsterCount,
      });
}
