import 'dart:math';

import 'alive_index.dart';
import 'combat_side.dart';
import 'combatant.dart';
import 'attack_damage.dart';
import 'crit_roller.dart';
import 'fight_result.dart';
import 'fight_turn_stats.dart';
import 'fight_turn_summary.dart';
import 'monster_rules.dart';
import 'target_picker.dart';
import 'turn_order.dart';

/// Turn-by-turn fight resolver.
///
/// Given two camps of [Combatant]s, loops turn by turn until one camp
/// has no alive combatant left, then returns a [FightResult].
class FightEngine {
  final Random _random;
  final CritRoller _critRoller;

  FightEngine({Random? random, double critChance = 0.05})
      : _random = random ?? Random(),
        _critRoller = CritRoller(critChance: critChance, random: random);

  FightResult resolve({
    required List<Combatant> playerSide,
    required List<Combatant> monsterSide,
  }) {
    final List<Combatant> initialPlayerCombatants =
        playerSide.map(_cloneFresh).toList();
    final int initialMonsterCount = monsterSide.length;
    final AliveIndex players = AliveIndex(playerSide);
    final AliveIndex monsters = AliveIndex(monsterSide);

    final List<FightTurnSummary> summaries = <FightTurnSummary>[];
    int turnNumber = 0;

    while (_anyAlive(playerSide) && _anyAlive(monsterSide)) {
      turnNumber += 1;
      final FightTurnStats stats = _runTurn(players, monsters);
      summaries.add(
        FightTurnSummary(
          turnNumber: turnNumber,
          attacksPlayed: stats.attacks,
          critCount: stats.crits,
          damageDealtByPlayer: stats.dmgPlayer,
          damageDealtByMonster: stats.dmgMonster,
          playerAliveAtEnd: _countAlive(playerSide),
          monsterAliveAtEnd: _countAlive(monsterSide),
          playerHpAtEnd: _sumHp(playerSide),
          monsterHpAtEnd: _sumHp(monsterSide),
        ),
      );
    }

    final CombatSide winner =
        _anyAlive(playerSide) ? CombatSide.player : CombatSide.monster;
    final int finalMonsterCount = _countAlive(monsterSide);

    return FightResult(
      winner: winner,
      turnCount: turnNumber,
      turnSummaries: summaries,
      initialPlayerCombatants: initialPlayerCombatants,
      finalPlayerCombatants: playerSide,
      initialMonsterCount: initialMonsterCount,
      finalMonsterCount: finalMonsterCount,
    );
  }

  FightTurnStats _runTurn(AliveIndex players, AliveIndex monsters) {
    final FightTurnStats stats = FightTurnStats();
    final List<Combatant> order =
        TurnOrder.shuffle(players.pool, monsters.pool, _random);

    for (final Combatant attacker in order) {
      if (!attacker.isAlive) {
        continue;
      }
      final AliveIndex pool =
          attacker.side == CombatSide.player ? monsters : players;
      final Combatant? target =
          TargetPicker.pickFrom(pool, _random, attacker: attacker);
      if (target == null) {
        break;
      }
      final bool crit = _critRoller.roll();
      if (crit) {
        stats.crits += 1;
      }
      final int dmg = AttackDamage.compute(
        attacker: attacker,
        target: target,
        crit: crit,
      );
      int applied = _hit(target, dmg, pool);
      final Combatant? swept =
          MonsterRules.secondTargetIn(attacker, target, pool, _random);
      if (swept != null) {
        applied += _hit(
            swept, AttackDamage.compute(attacker: attacker, target: swept), pool);
      }
      stats.attacks += 1;
      if (attacker.side == CombatSide.player) {
        stats.dmgPlayer += applied;
      } else {
        stats.dmgMonster += applied;
      }
    }
    return stats;
  }

  /// Deals [damage] to [target] and buries it in [pool] if it falls.
  static int _hit(Combatant target, int damage, AliveIndex pool) {
    final int applied = target.applyDamage(damage);
    if (!target.isAlive) {
      pool.bury(target);
    }
    return applied;
  }

  static Combatant _cloneFresh(Combatant c) {
    return Combatant(
      side: c.side,
      typeKey: c.typeKey,
      maxHp: c.maxHp,
      atk: c.atk,
      def: c.def,
      currentHp: c.maxHp,
      isBoss: c.isBoss,
    );
  }

  static bool _anyAlive(List<Combatant> list) =>
      list.any((Combatant c) => c.isAlive);

  static int _countAlive(List<Combatant> list) =>
      list.where((Combatant c) => c.isAlive).length;

  static int _sumHp(List<Combatant> list) =>
      list.fold<int>(0, (int acc, Combatant c) => acc + c.currentHp);
}
