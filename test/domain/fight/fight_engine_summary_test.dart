import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_engine.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';

List<Combatant> _side(
  CombatSide side,
  int count, {
  required int hp,
  required int atk,
  required int def,
}) {
  return List<Combatant>.generate(
    count,
    (int i) => Combatant(
      side: side,
      typeKey: '${side.name}$i',
      maxHp: hp,
      atk: atk,
      def: def,
    ),
  );
}

int _aliveOf(List<Combatant> side) =>
    side.where((Combatant c) => c.isAlive).length;

int _hpOf(List<Combatant> side) =>
    side.fold<int>(0, (int acc, Combatant c) => acc + c.currentHp);

void main() {
  group('FightEngine turn summaries', () {
    late List<Combatant> players;
    late List<Combatant> monsters;
    late int initialPlayerHp;
    late int initialMonsterHp;
    late FightResult result;

    setUp(() {
      players = _side(CombatSide.player, 6, hp: 40, atk: 9, def: 3);
      players[2].currentHp = 10;
      monsters = _side(CombatSide.monster, 7, hp: 35, atk: 8, def: 2);
      initialPlayerHp = _hpOf(players);
      initialMonsterHp = _hpOf(monsters);
      result = FightEngine(random: Random(2024)).resolve(
        playerSide: players,
        monsterSide: monsters,
      );
    });

    test('the fight lasts several turns', () {
      expect(result.turnCount, greaterThan(3));
      expect(result.turnSummaries.length, result.turnCount);
    });

    test('the last turn counters match the final combatants', () {
      final FightTurnSummary last = result.turnSummaries.last;

      expect(last.playerAliveAtEnd, _aliveOf(players));
      expect(last.monsterAliveAtEnd, _aliveOf(monsters));
      expect(last.playerHpAtEnd, _hpOf(players));
      expect(last.monsterHpAtEnd, _hpOf(monsters));
      expect(result.finalMonsterCount, _aliveOf(monsters));
    });

    test('each turn removes exactly the damage dealt by the other side', () {
      int playerHp = initialPlayerHp;
      int monsterHp = initialMonsterHp;

      for (final FightTurnSummary s in result.turnSummaries) {
        playerHp -= s.damageDealtByMonster;
        monsterHp -= s.damageDealtByPlayer;
        expect(s.playerHpAtEnd, playerHp, reason: 'turn ${s.turnNumber}');
        expect(s.monsterHpAtEnd, monsterHp, reason: 'turn ${s.turnNumber}');
      }
    });

    test('alive counts and hp totals never increase', () {
      FightTurnSummary before = result.turnSummaries.first;
      expect(before.playerAliveAtEnd, lessThanOrEqualTo(players.length));
      expect(before.monsterAliveAtEnd, lessThanOrEqualTo(monsters.length));

      for (final FightTurnSummary s in result.turnSummaries.skip(1)) {
        expect(s.playerAliveAtEnd, lessThanOrEqualTo(before.playerAliveAtEnd));
        expect(
            s.monsterAliveAtEnd, lessThanOrEqualTo(before.monsterAliveAtEnd));
        expect(s.playerHpAtEnd, lessThanOrEqualTo(before.playerHpAtEnd));
        expect(s.monsterHpAtEnd, lessThanOrEqualTo(before.monsterHpAtEnd));
        before = s;
      }
    });
  });
}
