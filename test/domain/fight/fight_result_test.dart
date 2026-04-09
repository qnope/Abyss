import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';

void main() {
  group('FightResult', () {
    final Combatant initialPlayer = Combatant(
      side: CombatSide.player,
      typeKey: 'scout',
      maxHp: 12,
      atk: 3,
      def: 1,
    );
    final Combatant finalPlayer = Combatant(
      side: CombatSide.player,
      typeKey: 'scout',
      maxHp: 12,
      atk: 3,
      def: 1,
      currentHp: 5,
    );
    const FightTurnSummary summary = FightTurnSummary(
      turnNumber: 1,
      attacksPlayed: 2,
      critCount: 0,
      damageDealtByPlayer: 5,
      damageDealtByMonster: 3,
      playerAliveAtEnd: 1,
      monsterAliveAtEnd: 0,
      playerHpAtEnd: 5,
      monsterHpAtEnd: 0,
    );

    test('constructor stores every field correctly', () {
      final FightResult result = FightResult(
        winner: CombatSide.player,
        turnCount: 4,
        turnSummaries: const <FightTurnSummary>[summary],
        initialPlayerCombatants: <Combatant>[initialPlayer],
        finalPlayerCombatants: <Combatant>[finalPlayer],
        initialMonsterCount: 3,
        finalMonsterCount: 0,
      );

      expect(result.winner, CombatSide.player);
      expect(result.turnCount, 4);
      expect(result.turnSummaries, hasLength(1));
      expect(result.turnSummaries.first, summary);
      expect(result.initialPlayerCombatants, <Combatant>[initialPlayer]);
      expect(result.finalPlayerCombatants, <Combatant>[finalPlayer]);
      expect(result.initialMonsterCount, 3);
      expect(result.finalMonsterCount, 0);
    });

    test('isVictory is true when winner is player', () {
      final FightResult result = FightResult(
        winner: CombatSide.player,
        turnCount: 2,
        turnSummaries: const <FightTurnSummary>[],
        initialPlayerCombatants: const <Combatant>[],
        finalPlayerCombatants: const <Combatant>[],
        initialMonsterCount: 1,
        finalMonsterCount: 0,
      );

      expect(result.isVictory, isTrue);
    });

    test('isVictory is false when winner is monster', () {
      final FightResult result = FightResult(
        winner: CombatSide.monster,
        turnCount: 2,
        turnSummaries: const <FightTurnSummary>[],
        initialPlayerCombatants: const <Combatant>[],
        finalPlayerCombatants: const <Combatant>[],
        initialMonsterCount: 1,
        finalMonsterCount: 1,
      );

      expect(result.isVictory, isFalse);
    });
  });
}
