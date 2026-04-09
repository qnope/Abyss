import 'dart:math';

import 'combat_side.dart';
import 'combatant.dart';
import 'crit_roller.dart';
import 'damage_calculator.dart';
import 'fight_result.dart';
import 'fight_turn_summary.dart';
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

    final List<FightTurnSummary> summaries = <FightTurnSummary>[];
    int turnNumber = 0;

    while (_anyAlive(playerSide) && _anyAlive(monsterSide)) {
      turnNumber += 1;
      final _TurnStats stats = _runTurn(playerSide, monsterSide);
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

  _TurnStats _runTurn(
    List<Combatant> playerSide,
    List<Combatant> monsterSide,
  ) {
    final _TurnStats stats = _TurnStats();
    final List<Combatant> order =
        TurnOrder.shuffle(playerSide, monsterSide, _random);

    for (final Combatant attacker in order) {
      if (!attacker.isAlive) {
        continue;
      }
      final List<Combatant> pool =
          attacker.side == CombatSide.player ? monsterSide : playerSide;
      final Combatant? target = TargetPicker.pickRandom(pool, _random);
      if (target == null) {
        break;
      }
      final bool crit = _critRoller.roll();
      if (crit) {
        stats.crits += 1;
      }
      final int dmg = DamageCalculator.compute(
        atk: attacker.atk,
        def: target.def,
        crit: crit,
      );
      final int applied = target.applyDamage(dmg);
      stats.attacks += 1;
      if (attacker.side == CombatSide.player) {
        stats.dmgPlayer += applied;
      } else {
        stats.dmgMonster += applied;
      }
    }
    return stats;
  }

  static Combatant _cloneFresh(Combatant c) {
    return Combatant(
      side: c.side,
      typeKey: c.typeKey,
      maxHp: c.maxHp,
      atk: c.atk,
      def: c.def,
      currentHp: c.maxHp,
    );
  }

  static bool _anyAlive(List<Combatant> list) =>
      list.any((Combatant c) => c.isAlive);

  static int _countAlive(List<Combatant> list) =>
      list.where((Combatant c) => c.isAlive).length;

  static int _sumHp(List<Combatant> list) =>
      list.fold<int>(0, (int acc, Combatant c) => acc + c.currentHp);
}

class _TurnStats {
  int attacks = 0;
  int crits = 0;
  int dmgPlayer = 0;
  int dmgMonster = 0;
}
