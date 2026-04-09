import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/fight_turn_summary.dart';

void main() {
  group('FightTurnSummary', () {
    test('constructor stores every field correctly', () {
      const FightTurnSummary summary = FightTurnSummary(
        turnNumber: 3,
        attacksPlayed: 7,
        critCount: 2,
        damageDealtByPlayer: 15,
        damageDealtByMonster: 9,
        playerAliveAtEnd: 4,
        monsterAliveAtEnd: 2,
        playerHpAtEnd: 18,
        monsterHpAtEnd: 6,
      );

      expect(summary.turnNumber, 3);
      expect(summary.attacksPlayed, 7);
      expect(summary.critCount, 2);
      expect(summary.damageDealtByPlayer, 15);
      expect(summary.damageDealtByMonster, 9);
      expect(summary.playerAliveAtEnd, 4);
      expect(summary.monsterAliveAtEnd, 2);
      expect(summary.playerHpAtEnd, 18);
      expect(summary.monsterHpAtEnd, 6);
    });
  });
}
